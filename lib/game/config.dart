class GameConfig {
  static const double cellSize = 40.0;
  static const int gridWidth = 20;
  static const int gridHeight = 30;
  static double gameSpeed = 0.15; // Seconds per move
  static const double minGameSpeed = 0.05;
  static const double maxGameSpeed = 0.5;

  // Colors
  static const int colorBackground = 0xFF050505;
  static const int colorSnakeHead = 0xFF00FF00;
  static const int colorSnakeBody = 0xFF00AA00;
  static const int colorFood = 0xFF00FFFF; // Neon Cyan
  static const int colorWall = 0xFF222222;
}
