import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../config.dart';
import '../neon_snake_game.dart';
import '../../state/meta_progression.dart';

enum Direction { up, down, left, right }

class Snake extends Component
    with HasGameReference<NeonSnakeGame>, KeyboardHandler {
  final SnakeConfig config;

  final List<Vector2> body = [];
  Direction currentDirection = Direction.up;
  Direction _nextDirection = Direction.up;
  double _timer = 0.0;

  bool _shouldGrow = false;

  Snake({required this.config}) {
    // Initialize with configured length
    for (int i = 0; i < config.baseLength; i++) {
      body.add(Vector2(10, 15.0 + i));
    }
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    final isKeyDown = event is KeyDownEvent;

    if (isKeyDown) {
      if (keysPressed.contains(LogicalKeyboardKey.keyW) ||
          keysPressed.contains(LogicalKeyboardKey.arrowUp)) {
        setDirection(Direction.up);
        return true;
      } else if (keysPressed.contains(LogicalKeyboardKey.keyS) ||
          keysPressed.contains(LogicalKeyboardKey.arrowDown)) {
        setDirection(Direction.down);
        return true;
      } else if (keysPressed.contains(LogicalKeyboardKey.keyA) ||
          keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
        setDirection(Direction.left);
        return true;
      } else if (keysPressed.contains(LogicalKeyboardKey.keyD) ||
          keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
        setDirection(Direction.right);
        return true;
      }
    }
    return super.onKeyEvent(event, keysPressed);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (game.isGamePaused) return;

    _timer += dt;

    // Use configured speed (lower is faster)
    if (_timer >= config.baseSpeed) {
      _timer -= config.baseSpeed;
      _move();
    }
  }

  void _move() {
    currentDirection = _nextDirection;

    Vector2 newHead = body.first.clone();
    switch (currentDirection) {
      case Direction.up:
        newHead.y -= 1;
        break;
      case Direction.down:
        newHead.y += 1;
        break;
      case Direction.left:
        newHead.x -= 1;
        break;
      case Direction.right:
        newHead.x += 1;
        break;
    }

    body.insert(0, newHead);

    if (!_shouldGrow) {
      body.removeLast();
    } else {
      _shouldGrow = false;
    }
  }

  void setDirection(Direction newDirection) {
    if (newDirection == Direction.up && currentDirection != Direction.down) {
      _nextDirection = newDirection;
    } else if (newDirection == Direction.down &&
        currentDirection != Direction.up) {
      _nextDirection = newDirection;
    } else if (newDirection == Direction.left &&
        currentDirection != Direction.right) {
      _nextDirection = newDirection;
    } else if (newDirection == Direction.right &&
        currentDirection != Direction.left) {
      _nextDirection = newDirection;
    }
  }

  void grow() {
    _shouldGrow = true;
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = Color(config.colorBody)
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 2.0); // Subtle glow

    final headPaint = Paint()
      ..color = Color(config.colorHead)
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.outer,
        4.0,
      ); // Stronger glow

    final innerPaint = Paint()..color = Color(config.colorBody);
    final innerHeadPaint = Paint()..color = Color(config.colorHead);

    for (int i = 0; i < body.length; i++) {
      final segment = body[i];

      final rect = Rect.fromLTWH(
        segment.x * GameConfig.cellSize,
        segment.y * GameConfig.cellSize,
        GameConfig.cellSize - 2, // gap
        GameConfig.cellSize - 2,
      );

      if (i == 0) {
        canvas.drawRect(rect, headPaint);
        canvas.drawRect(rect, innerHeadPaint);
      } else {
        canvas.drawRect(rect, paint);
        canvas.drawRect(rect, innerPaint);
      }
    }
  }
}
