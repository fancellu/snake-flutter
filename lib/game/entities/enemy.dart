import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../components/particles.dart';
import '../config.dart';
import '../neon_snake_game.dart';

class Enemy extends Component with HasGameReference<NeonSnakeGame> {
  Vector2 position;
  double moveTimer = 0.0;
  Vector2 direction = Vector2(1, 0);
  late double speedJitter;

  Enemy({required this.position}) {
    // 10% chance to move vertically
    if (Random().nextDouble() < 0.1) {
      direction = Vector2(0, 1); // Down
    } else {
      direction = Vector2(1, 0); // Right
    }
    // Speed Jitter: 0.9 to 1.1 (±10%)
    speedJitter = 0.9 + Random().nextDouble() * 0.2;
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.redAccent
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 5.0);

    final rect = Rect.fromLTWH(
      position.x * GameConfig.cellSize,
      position.y * GameConfig.cellSize,
      GameConfig.cellSize,
      GameConfig.cellSize,
    );

    canvas.drawRect(rect, paint);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (game.isGamePaused) return;

    moveTimer += dt;
    if (moveTimer >= GameConfig.gameSpeed * 1.5 * speedJitter) {
      moveTimer = 0.0;
      // Simple bounce logic
      position += direction;

      if (position.x < 0 ||
          position.x >= GameConfig.gridWidth ||
          position.y < 0 ||
          position.y >= GameConfig.gridHeight) {
        position -= direction;
        direction.negate();
      }
    }

    // Trail Effect
    if (game.isMounted) {
      game.world.add(
        ParticleHelper.createEnemyTrail(
          position * GameConfig.cellSize + Vector2.all(GameConfig.cellSize / 2),
        ),
      );
    }
  }
}
