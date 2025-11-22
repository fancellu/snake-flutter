import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../config.dart';
import '../neon_snake_game.dart';

class Firewall extends Component with HasGameReference<NeonSnakeGame> {
  Vector2 position;
  bool isOpen = false;

  Firewall({required this.position});

  void open() {
    isOpen = true;
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = isOpen ? Colors.greenAccent : Colors.redAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..maskFilter = MaskFilter.blur(BlurStyle.outer, isOpen ? 5.0 : 2.0);

    final rect = Rect.fromLTWH(
      position.x * GameConfig.cellSize,
      position.y * GameConfig.cellSize,
      GameConfig.cellSize,
      GameConfig.cellSize,
    );

    // Draw a grid or "gate" pattern
    canvas.drawRect(rect, paint);

    if (!isOpen) {
      // Draw X or bars
      canvas.drawLine(rect.topLeft, rect.bottomRight, paint);
      canvas.drawLine(rect.topRight, rect.bottomLeft, paint);
    } else {
      // Draw open glow
      final innerPaint = Paint()
        ..color = Colors.greenAccent.withValues(alpha: 0.5);
      canvas.drawRect(rect, innerPaint);
    }
  }
}
