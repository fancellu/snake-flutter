import 'dart:async';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:material_ui/material_ui.dart';
import 'config.dart';
import 'entities/snake.dart';
import 'entities/food.dart';
import 'entities/firewall.dart';
import 'entities/enemy.dart';
import 'entities/powerup.dart';
import 'components/particles.dart';
import 'components/hud.dart';
import 'components/grid.dart';
import 'effects/shake_effect.dart';
import '../audio/audio_manager.dart';
import 'upgrades/upgrade.dart';
import 'upgrades/upgrade_manager.dart';
import '../state/meta_progression.dart';

import 'package:flame/events.dart';
import 'package:flutter/services.dart';
import '../input/gamepad_manager.dart';
import '../utils/error_reporter.dart';

class NeonSnakeGame extends FlameGame
    with HasKeyboardHandlerComponents, DragCallbacks {
  @override
  Color backgroundColor() => const Color(GameConfig.colorBackground);

  Snake? snake;

  bool _isSpawningFood = false;

  // Level State
  int foodEaten = 0;
  int levelTarget = 5; // Eat 5 to open exit
  Firewall? firewall;
  bool isLevelComplete = false;

  bool isGamePaused = false;

  int score = 0;
  double shieldTimer = 0.0;
  double _slowMoTimer = 0.0;
  double _slowMoOriginalSpeed = 0.15;
  int comboCount = 0;
  double comboTimer = 0.0;
  static const double comboWindow = 2.0; // 2 seconds to maintain combo

  late StreamSubscription<GamepadAction> _gamepadSubscription;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Initialize Score Multiplier from Class Config
    final selectedClass = MetaProgression.selectedClass;
    final config = MetaProgression.getConfigForClass(selectedClass);
    scoreMultiplier = config.scoreMultiplier.toInt();

    startLevel();

    // Add Grid (Background)
    world.add(GridComponent());

    // Set visible game size to match grid dimensions PLUS HUD padding
    // Grid is 800x1200. HUD is at -40 (top) and +20 (bottom).
    // We add padding to the height to ensure HUD is visible.
    const double hudPadding = 100.0;
    camera.viewfinder.visibleGameSize = Vector2(
      GameConfig.gridWidth * GameConfig.cellSize,
      (GameConfig.gridHeight * GameConfig.cellSize) + (hudPadding * 2),
    );
    camera.viewfinder.anchor = Anchor.center;
    camera.viewfinder.position = Vector2(
      GameConfig.gridWidth * GameConfig.cellSize / 2,
      GameConfig.gridHeight * GameConfig.cellSize / 2,
    );

    // Add HUD to World (so it scales with camera)
    world.add(Hud());

    // Start BGM
    AudioManager.playBgm();

    // Init Gamepad

    await GamepadManager().init();
    _gamepadSubscription = GamepadManager().actionStream.listen(
      _onGamepadAction,
    );
  }

  @override
  void onRemove() {
    _cleanup();
    super.onRemove();
  }

  void _cleanup() {
    try {
      _gamepadSubscription.cancel();
    } catch (e) {
      debugPrint('Cleanup error: $e');
    }
  }

  void _onGamepadAction(GamepadAction action) {
    if (action == GamepadAction.pause) {
      _togglePause();
      return;
    }

    if (isGamePaused) return;

    switch (action) {
      case GamepadAction.up:
        snake?.setDirection(Direction.up);
        break;
      case GamepadAction.down:
        snake?.setDirection(Direction.down);
        break;
      case GamepadAction.left:
        snake?.setDirection(Direction.left);
        break;
      case GamepadAction.right:
        snake?.setDirection(Direction.right);
        break;
      default:
        break;
    }
  }

  void _togglePause() {
    isGamePaused = !isGamePaused;
    if (isGamePaused) {
      AudioManager.pauseBgm();
    } else {
      AudioManager.resumeBgm();
    }
  }

  void startLevel() {
    // Cleanup previous level
    world.children.whereType<Food>().forEach((e) => e.removeFromParent());
    world.children.whereType<Firewall>().forEach((e) => e.removeFromParent());
    world.children.whereType<Enemy>().forEach((e) => e.removeFromParent());
    world.children.whereType<PowerUp>().forEach((e) => e.removeFromParent());
    world.children.whereType<TextComponent>().forEach(
      (e) => e.removeFromParent(),
    );
    if (snake != null && snake!.isMounted) snake!.removeFromParent();

    // Reset state
    foodEaten = 0;
    isLevelComplete = false;

    firewall = null;

    // Spawn entities
    final selectedClass = MetaProgression.selectedClass;
    final config = MetaProgression.getConfigForClass(selectedClass);

    snake = Snake(config: config);
    world.add(snake!);

    // Spawn Firewall at random location (not on snake)
    spawnFirewall();

    // Spawn Enemies and get their positions
    final enemyPositions = spawnEnemies();

    // Spawn Food, avoiding snake, firewall, and the new enemies
    spawnFood(additionalObstacles: enemyPositions);
  }

  void spawnFirewall() {
    final random = Random();
    int x = random.nextInt(GameConfig.gridWidth);
    int y = random.nextInt(GameConfig.gridHeight);
    Vector2 pos = Vector2(x.toDouble(), y.toDouble());

    // Ensure not on snake
    while (snake!.body.contains(pos)) {
      x = random.nextInt(GameConfig.gridWidth);
      y = random.nextInt(GameConfig.gridHeight);
      pos = Vector2(x.toDouble(), y.toDouble());
    }

    firewall = Firewall(position: pos);
    world.add(firewall!);
  }

  void spawnFood({List<Vector2>? additionalObstacles}) {
    if (_isSpawningFood) return;
    _isSpawningFood = true;

    try {
      // Remove existing food
      world.children.whereType<Food>().toList().forEach(
        (f) => f.removeFromParent(),
      );

      // Build available cells list
      final occupied = <Vector2>{};
      occupied.addAll(snake!.body);
      if (firewall != null) occupied.add(firewall!.position);
      occupied.addAll(world.children.whereType<Enemy>().map((e) => e.position));
      if (additionalObstacles != null) occupied.addAll(additionalObstacles);

      final available = <Vector2>[];
      for (int x = 0; x < GameConfig.gridWidth; x++) {
        for (int y = 0; y < GameConfig.gridHeight; y++) {
          final pos = Vector2(x.toDouble(), y.toDouble());
          if (!occupied.contains(pos)) available.add(pos);
        }
      }

      if (available.isEmpty) {
        debugPrint("CRITICAL: No valid spawn position!");
        return;
      }

      final pos = available[Random().nextInt(available.length)];
      world.add(Food(position: pos));
    } catch (e, stack) {
      onError(e, stack);
    } finally {
      _isSpawningFood = false;
    }
  }

  double _foodCheckTimer = 0.0;

  @override
  void update(double dt) {
    super.update(dt);

    if (isGamePaused) return;

    // Update Shield Timer
    if (shieldTimer > 0) {
      shieldTimer -= dt;
      if (shieldTimer < 0) shieldTimer = 0;
    }

    // Update Combo Timer
    if (comboTimer > 0) {
      comboTimer -= dt;
      if (comboTimer <= 0) {
        comboCount = 0;
      }
    }

    // Update Slow-Mo Timer
    if (_slowMoTimer > 0) {
      _slowMoTimer -= dt;
      if (_slowMoTimer <= 0) {
        GameConfig.gameSpeed = _slowMoOriginalSpeed;
        _slowMoTimer = 0;
      }
    }

    checkCollisions();

    // Food Watchdog
    _foodCheckTimer += dt;
    if (_foodCheckTimer >= 1.0) {
      _foodCheckTimer = 0.0;
      // Only spawn if NO food exists and we aren't currently spawning
      final foodCount = world.children.whereType<Food>().length;
      if (foodCount == 0 && !_isSpawningFood) {
        debugPrint("WATCHDOG: Food missing! Forcing spawn...");
        spawnFood();
      }
    }
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    if (snake == null || paused) return;

    final velocity = event.velocity;
    if (velocity.x.abs() > velocity.y.abs()) {
      // Horizontal
      if (velocity.x > 0) {
        snake!.setDirection(Direction.right);
      } else {
        snake!.setDirection(Direction.left);
      }
    } else {
      // Vertical
      if (velocity.y > 0) {
        snake!.setDirection(Direction.down);
      } else {
        snake!.setDirection(Direction.up);
      }
    }
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.keyP) {
        _togglePause();
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.keyF) {
        debugPrint("Force Spawning Food...");
        spawnFood();
        return KeyEventResult.handled;
      }
    }
    return super.onKeyEvent(event, keysPressed);
  }

  List<Vector2> spawnEnemies() {
    // Spawn 1-3 enemies based on level?
    final random = Random();
    int count = 1 + (score ~/ 10); // More enemies as score increases
    if (count > 5) count = 5;

    List<Vector2> spawnedPositions = [];

    for (int i = 0; i < count; i++) {
      int x = random.nextInt(GameConfig.gridWidth);
      int y = random.nextInt(GameConfig.gridHeight);
      Vector2 pos = Vector2(x.toDouble(), y.toDouble());

      // Avoid snake, firewall, and food (if exists)
      bool hitsFood = false;
      for (final f in world.children.whereType<Food>()) {
        if (f.position == pos) hitsFood = true;
      }

      while (snake!.body.contains(pos) ||
          (firewall != null && firewall!.position == pos) ||
          hitsFood ||
          spawnedPositions.contains(pos)) {
        x = random.nextInt(GameConfig.gridWidth);
        y = random.nextInt(GameConfig.gridHeight);
        pos = Vector2(x.toDouble(), y.toDouble());
      }

      world.add(Enemy(position: pos));
      spawnedPositions.add(pos);
    }

    // Chance to spawn PowerUp
    if (random.nextDouble() < 0.3) {
      // 30% chance per level
      spawnPowerUp();
    }

    return spawnedPositions;
  }

  void spawnPowerUp() {
    final random = Random();
    int x = random.nextInt(GameConfig.gridWidth);
    int y = random.nextInt(GameConfig.gridHeight);
    Vector2 pos = Vector2(x.toDouble(), y.toDouble());

    // Avoid snake, firewall, food
    bool hitsFood = false;
    for (final f in world.children.whereType<Food>()) {
      if (f.position == pos) hitsFood = true;
    }

    while (snake!.body.contains(pos) ||
        (firewall != null && firewall!.position == pos) ||
        hitsFood) {
      x = random.nextInt(GameConfig.gridWidth);
      y = random.nextInt(GameConfig.gridHeight);
      pos = Vector2(x.toDouble(), y.toDouble());
    }

    final type = PowerUpType.values[random.nextInt(PowerUpType.values.length)];
    world.add(PowerUp(position: pos, type: type));
  }

  void checkCollisions() {
    if (isLevelComplete || snake == null || snake!.body.isEmpty) return;

    final head = snake!.body.first;

    // Check Food (with Magnetize)
    final foods = world.children.whereType<Food>().toList();
    for (final f in foods) {
      if (magnetRadius > 0) {
        final distance = head.distanceTo(f.position);
        if (distance <= magnetRadius) {
          eatFood(f);
        }
      } else {
        if (head == f.position) {
          eatFood(f);
        }
      }
    }

    // Check Enemies
    for (final enemy in world.children.whereType<Enemy>()) {
      if (head == enemy.position) {
        takeDamage(3); // Lose 3 segments
        enemy.position = Vector2(-100, -100); // Move off-screen immediately
        enemy.removeFromParent();
      }
    }

    // Check PowerUps
    for (final powerUp in world.children.whereType<PowerUp>()) {
      if (head == powerUp.position) {
        collectPowerUp(powerUp);
        powerUp.position = Vector2(-100, -100); // Move off-screen immediately
        powerUp.removeFromParent();
      }
    }

    // Check Firewall
    if (firewall != null && head == firewall!.position) {
      if (firewall!.isOpen) {
        completeLevel();
      } else {
        if (ghostProtocolCharges > 0) {
          ghostProtocolCharges--;
          if (ghostProtocolCharges == 0) hasGhostProtocol = false;
          debugPrint("Ghost Protocol Activated! ($ghostProtocolCharges left)");
        } else {
          takeDamage(1); // Hitting closed firewall hurts
        }
      }
    }

    // Check wall collision
    if (head.x < 0 ||
        head.x >= GameConfig.gridWidth ||
        head.y < 0 ||
        head.y >= GameConfig.gridHeight) {
      if (ghostProtocolCharges > 0) {
        ghostProtocolCharges--;
        if (ghostProtocolCharges == 0) hasGhostProtocol = false;
        debugPrint(
          "Ghost Protocol Activated (Wall)! ($ghostProtocolCharges left)",
        );
        if (head.x < 0) snake!.body.first.x = GameConfig.gridWidth - 1;
        if (head.x >= GameConfig.gridWidth) snake!.body.first.x = 0;
        if (head.y < 0) snake!.body.first.y = GameConfig.gridHeight - 1;
        if (head.y >= GameConfig.gridHeight) snake!.body.first.y = 0;
      } else {
        takeDamage(1); // Wall hits hurt
        // Bounce back? Or just clamp?
        // For now, clamp to avoid infinite loop of damage if stuck
        snake!.body.first.x = snake!.body.first.x.clamp(
          0,
          GameConfig.gridWidth - 1,
        );
        snake!.body.first.y = snake!.body.first.y.clamp(
          0,
          GameConfig.gridHeight - 1,
        );
      }
    }

    // Check self collision
    for (int i = 1; i < snake!.body.length; i++) {
      if (head == snake!.body[i]) {
        takeDamage(1);
      }
    }
  }

  void takeDamage(int amount) {
    if (shieldTimer > 0) {
      debugPrint("Shield blocked damage!");
      return;
    }
    debugPrint("Taking Damage: $amount");
    AudioManager.playDie(); // Play hurt sound
    world.add(CameraShaker(camera, amplitude: 10));

    // Reduce length
    if (snake!.body.length > amount) {
      for (int i = 0; i < amount; i++) {
        snake!.body.removeLast();
      }
    } else {
      gameOver();
    }
  }

  void eatFood(Food f) {
    try {
      debugPrint("Eating food at ${f.position}");
      f.removeFromParent();

      // Combo system
      comboCount++;
      comboTimer = comboWindow;
      final comboBonus = comboCount > 1 ? comboCount : 1;

      score += comboBonus * scoreMultiplier;
      foodEaten++;
      snake!.grow();
      if (snake!.config.ability == SnakeAbility.doubleGrowth) {
        snake!.grow();
      }

      AudioManager.playEat();

      // Particle effect
      final effect = ParticleHelper.createEatEffect(
        f.position * GameConfig.cellSize + Vector2.all(GameConfig.cellSize / 2),
      );
      world.add(effect);

      // Combo text
      if (comboCount > 1) {
        world.add(
          TextComponent(
            text: 'x$comboCount COMBO!',
            textRenderer: TextPaint(
              style: const TextStyle(
                color: Colors.orange,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    blurRadius: 10,
                    color: Colors.deepOrange,
                    offset: Offset(0, 0),
                  ),
                ],
              ),
            ),
            position:
                f.position * GameConfig.cellSize +
                Vector2(GameConfig.cellSize / 2, -20),
            anchor: Anchor.center,
          )..add(RemoveEffect(delay: 1.0)),
        );
      }

      if (foodEaten >= levelTarget) {
        firewall?.open();
        world.add(
          TextComponent(
            text: 'EXIT OPEN',
            textRenderer: TextPaint(
              style: const TextStyle(
                color: Colors.greenAccent,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    blurRadius: 10,
                    color: Colors.green,
                    offset: Offset(0, 0),
                  ),
                ],
              ),
            ),
            position: Vector2(
              GameConfig.gridWidth * GameConfig.cellSize / 2,
              GameConfig.gridHeight * GameConfig.cellSize / 4,
            ),
            anchor: Anchor.center,
          ),
        );
      }

      spawnFood();
    } catch (e, stack) {
      onError(e, stack);
    }
  }

  void collectPowerUp(PowerUp powerUp) {
    debugPrint("Collected PowerUp: ${powerUp.type}");
    AudioManager.playEat(); // Reuse eat sound for now

    switch (powerUp.type) {
      case PowerUpType.slowMo:
        _slowMoOriginalSpeed = GameConfig.gameSpeed;
        GameConfig.gameSpeed = (GameConfig.gameSpeed * 1.5).clamp(
          GameConfig.minGameSpeed,
          GameConfig.maxGameSpeed,
        );
        _slowMoTimer = 5.0;
        break;
      case PowerUpType.nuke:
        // Clear all enemies
        world.children.whereType<Enemy>().forEach((e) {
          e.removeFromParent();
          // Explosion effect?
          world.add(
            ParticleHelper.createEatEffect(e.position * GameConfig.cellSize),
          );
        });
        world.add(CameraShaker(camera, amplitude: 15));
        break;
      case PowerUpType.shield:
        // Give temporary invulnerability
        shieldTimer = 10.0; // 10 seconds of shield
        break;
    }
  }

  // Upgrades
  List<Upgrade> currentUpgrades = [];

  void completeLevel() {
    isLevelComplete = true;
    debugPrint("Level Complete! Drafting Phase...");

    // Generate random upgrades
    currentUpgrades = UpgradeManager.getRandomUpgrades(3);

    // Pause game and show overlay
    pauseEngine();
    overlays.add('UpgradeScreen');
  }

  // Upgrade Effects
  int scoreMultiplier = 1;
  bool hasGhostProtocol = false;
  int ghostProtocolCharges = 0;
  double magnetRadius = 0.0; // 0 means exact match

  void applyUpgrade(Upgrade upgrade) {
    debugPrint("Applying Upgrade: ${upgrade.name}");

    // Apply effects
    switch (upgrade.type) {
      case UpgradeType.speedDemon:
        GameConfig.gameSpeed = (GameConfig.gameSpeed * 0.8).clamp(
          GameConfig.minGameSpeed,
          GameConfig.maxGameSpeed,
        );
        break;
      case UpgradeType.cryptoMiner:
        scoreMultiplier *= 2;
        break;
      case UpgradeType.magnetize:
        magnetRadius += 1.5; // Increase pickup radius
        break;
      case UpgradeType.ghostProtocol:
        hasGhostProtocol = true;
        ghostProtocolCharges = 3; // Multi-use
        break;
      default:
        break;
    }

    // Resume game
    overlays.remove('UpgradeScreen');
    resumeEngine();

    // Next Level
    levelTarget += 2;
    startLevel();
  }

  void gameOver() {
    AudioManager.playDie();
    // Shake effect
    world.add(CameraShaker(camera, amplitude: 20));

    // Save Progress
    MetaProgression.saveScore(score);
    MetaProgression.addDataShards(score); // Currency = Score for now

    // Show Game Over Screen
    pauseEngine();
    overlays.add('GameOverScreen');
  }

  void restartGame() {
    // Reset
    score = 0;
    currentUpgrades.clear();
    GameConfig.gameSpeed = 0.15; // Reset speed

    // Reset Multiplier to Class Default
    final selectedClass = MetaProgression.selectedClass;
    final config = MetaProgression.getConfigForClass(selectedClass);
    scoreMultiplier = config.scoreMultiplier.toInt();

    magnetRadius = 0.0;
    hasGhostProtocol = false;
    ghostProtocolCharges = 0;
    levelTarget = 5;
    comboCount = 0;
    comboTimer = 0.0;
    _slowMoTimer = 0.0;

    overlays.remove('GameOverScreen');
    resumeEngine();
    startLevel();
  }

  void onError(Object error, StackTrace stack) {
    ErrorReporter.log(error, stack);

    world.add(
      TextComponent(
        text: 'ERROR: $error',
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.red,
            fontSize: 16,
            backgroundColor: Colors.black,
          ),
        ),
        position: Vector2(10, 10),
        priority: 100, // On top of everything
      ),
    );
  }
}
