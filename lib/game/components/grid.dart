import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../config.dart';

class GridComponent extends PositionComponent {
  GridComponent()
    : super(
        size: Vector2(
          GameConfig.gridWidth * GameConfig.cellSize,
          GameConfig.gridHeight * GameConfig.cellSize,
        ),
      );

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw Vertical Lines
    for (int x = 0; x <= GameConfig.gridWidth; x++) {
      canvas.drawLine(
        Offset(x * GameConfig.cellSize, 0),
        Offset(
          x * GameConfig.cellSize,
          GameConfig.gridHeight * GameConfig.cellSize,
        ),
        gridPaint,
      );
    }

    // Draw Horizontal Lines
    for (int y = 0; y <= GameConfig.gridHeight; y++) {
      canvas.drawLine(
        Offset(0, y * GameConfig.cellSize),
        Offset(
          GameConfig.gridWidth * GameConfig.cellSize,
          y * GameConfig.cellSize,
        ),
        gridPaint,
      );
    }

    // Draw Border
    final borderPaint = Paint()
      ..color = Colors.cyanAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 10.0);

    canvas.drawRect(
      Rect.fromLTWH(
        0,
        0,
        GameConfig.gridWidth * GameConfig.cellSize,
        GameConfig.gridHeight * GameConfig.cellSize,
      ),
      borderPaint,
    );
  }
}
