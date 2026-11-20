import 'package:flame/game.dart';
import 'package:material_ui/material_ui.dart';
import '../game/neon_snake_game.dart';
import 'upgrade_screen.dart';
import 'game_over_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final NeonSnakeGame _game;

  @override
  void initState() {
    super.initState();
    _game = NeonSnakeGame();
  }

  @override
  void dispose() {
    _game.onRemove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GameWidget(
      game: _game,
      overlayBuilderMap: {
        'UpgradeScreen': (BuildContext context, NeonSnakeGame game) {
          return UpgradeScreen(
            upgrades: game.currentUpgrades,
            onUpgradeSelected: (upgrade) {
              game.applyUpgrade(upgrade);
            },
          );
        },
        'GameOverScreen': (BuildContext context, NeonSnakeGame game) {
          return GameOverScreen(game: game);
        },
      },
    );
  }
}
