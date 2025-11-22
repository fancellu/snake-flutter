import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../config.dart';
import '../neon_snake_game.dart';

enum PowerUpType {
  slowMo, // Slows down time
  nuke, // Clears all enemies
  shield, // Protects from one hit
}

class PowerUp extends Component with HasGameReference<NeonSnakeGame> {
  Vector2 position;
  final PowerUpType type;

  PowerUp({required this.position, required this.type});

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 4.0);

    Color color;
    switch (type) {
      case PowerUpType.slowMo:
        color = Colors.blueAccent;
        break;
      case PowerUpType.nuke:
        color = Colors.orangeAccent;
        break;
      case PowerUpType.shield:
        color = Colors.purpleAccent;
        break;
    }
    paint.color = color;

    final rect = Rect.fromLTWH(
      position.x * GameConfig.cellSize + 5,
      position.y * GameConfig.cellSize + 5,
      GameConfig.cellSize - 10,
      GameConfig.cellSize - 10,
    );

    // Draw a diamond shape or just a smaller rect
    canvas.drawRect(rect, paint);

    // Inner indicator
    final innerPaint = Paint()..color = Colors.white.withValues(alpha: 0.8);
    canvas.drawCircle(rect.center, 5, innerPaint);
  }
}
