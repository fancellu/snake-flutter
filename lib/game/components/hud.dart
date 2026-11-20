import 'dart:async';

import 'package:flame/components.dart';
import 'package:material_ui/material_ui.dart';
import '../neon_snake_game.dart';
import '../config.dart';

class Hud extends PositionComponent with HasGameReference<NeonSnakeGame> {
  TextComponent? scoreText;
  TextComponent? levelText;
  TextComponent? titleText;
  TextComponent? powersText;
  TextComponent? pausedText;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // World Space Positioning
    // The grid is from (0,0) to (gridWidth * cellSize, gridHeight * cellSize)
    // We want the HUD to be "outside" this area, but still in the world.

    final gridWidth = GameConfig.gridWidth * GameConfig.cellSize;
    final gridHeight = GameConfig.gridHeight * GameConfig.cellSize;

    // Title: Top Center, slightly above the grid
    titleText = TextComponent(
      text: 'NEON OUROBOROS',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.cyanAccent,
          fontSize: 48, // Larger since we are zoomed out
          fontWeight: FontWeight.bold,
          fontFamily: 'Courier',
          shadows: [
            Shadow(blurRadius: 20, color: Colors.cyan, offset: Offset(0, 0)),
          ],
        ),
      ),
      anchor: Anchor.bottomCenter,
      position: Vector2(gridWidth / 2, -40), // 40px above the grid
    );
    add(titleText!);

    // Snake Info: Top Center, below title
    final snakeName = game.snake?.config.name ?? 'UNKNOWN';
    final snakeLevel = game.snake?.config.level ?? 1;
    final infoText = TextComponent(
      text: '$snakeName [LVL $snakeLevel]',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 16,
          fontFamily: 'Courier',
        ),
      ),
      anchor: Anchor.topCenter,
      position: Vector2(gridWidth / 2, -10),
    );
    add(infoText);

    // Score: Top Left corner
    scoreText = TextComponent(
      text: 'SCORE: 0',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.bottomLeft,
      position: Vector2(0, -20),
    );
    add(scoreText!);

    // Level / Target: Top Right corner
    levelText = TextComponent(
      text: 'ZONE: 1',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.bottomRight,
      position: Vector2(gridWidth, -20),
    );
    add(levelText!);

    // Active Powers: Bottom Left, below the grid
    powersText = TextComponent(
      text: '',
      textRenderer: TextPaint(
        style: const TextStyle(color: Colors.yellowAccent, fontSize: 24),
      ),
      anchor: Anchor.topLeft,
      position: Vector2(0, gridHeight + 20),
    );
    add(powersText!);

    // Paused Text: Center of the grid
    pausedText = TextComponent(
      text: 'PAUSED',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 80,
          fontWeight: FontWeight.bold,
          letterSpacing: 10,
          shadows: [
            Shadow(blurRadius: 40, color: Colors.black, offset: Offset(0, 0)),
          ],
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(gridWidth / 2, gridHeight / 2),
    );
    // Initially hidden
    pausedText?.scale = Vector2.zero();
    add(pausedText!);
  }

  @override
  void update(double dt) {
    super.update(dt);
    scoreText?.text = 'SCORE: ${game.score}';
    // Show target progress
    levelText?.text = 'TARGET: ${game.foodEaten}/${game.levelTarget}';

    // Show/Hide Paused Text
    if (game.isGamePaused) {
      pausedText?.scale = Vector2.all(1.0);
    } else {
      pausedText?.scale = Vector2.zero();
    }

    // Construct powers string
    List<String> activeEffects = [];

    // Always show Length
    activeEffects.add('LENGTH: ${game.snake?.body.length ?? 0}');

    if (game.scoreMultiplier > 1) {
      activeEffects.add('x${game.scoreMultiplier} SCORE');
    }

    if (game.magnetRadius > 0) {
      activeEffects.add('MAGNET: ${game.magnetRadius.toStringAsFixed(1)}x');
    }

    if (game.shieldTimer > 0) {
      activeEffects.add('SHIELD: ${game.shieldTimer.toStringAsFixed(1)}s');
    }

    if (game.hasGhostProtocol) {
      activeEffects.add('GHOST x${game.ghostProtocolCharges}');
    }
    if (GameConfig.gameSpeed < 0.15) {
      activeEffects.add('SPEED');
    }

    if (game.comboCount > 1) {
      activeEffects.add('COMBO x${game.comboCount}');
    }

    powersText?.text = activeEffects.join(' | ');
  }
}
