import 'package:flame/components.dart';
import 'package:material_ui/material_ui.dart';
import '../config.dart';
import '../neon_snake_game.dart';

class Food extends Component with HasGameReference<NeonSnakeGame> {
  Vector2 position;

  Food({required this.position});

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = const Color(GameConfig.colorFood)
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 5.0); // Glow

    final innerPaint = Paint()..color = const Color(GameConfig.colorFood);

    final rect = Rect.fromLTWH(
      position.x * GameConfig.cellSize,
      position.y * GameConfig.cellSize,
      GameConfig.cellSize - 4,
      GameConfig.cellSize - 4,
    );

    // Draw glow then inner circle
    canvas.drawOval(rect, paint);
    canvas.drawOval(rect, innerPaint);
  }
}
