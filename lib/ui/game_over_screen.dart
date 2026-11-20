import 'dart:async';
import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import '../game/neon_snake_game.dart';
import '../input/gamepad_manager.dart';
import 'menu_screen.dart';

class GameOverScreen extends StatefulWidget {
  final NeonSnakeGame game;

  const GameOverScreen({super.key, required this.game});

  @override
  State<GameOverScreen> createState() => _GameOverScreenState();
}

class _GameOverScreenState extends State<GameOverScreen> {
  int _focusedIndex = 0; // 0: Reboot, 1: Return to Root
  StreamSubscription<GamepadAction>? _gamepadSubscription;

  @override
  void initState() {
    super.initState();
    _gamepadSubscription = GamepadManager().actionStream.listen(
      _onGamepadAction,
    );
  }

  @override
  void dispose() {
    _gamepadSubscription?.cancel();
    super.dispose();
  }

  void _onGamepadAction(GamepadAction action) {
    if (!mounted) return;

    setState(() {
      switch (action) {
        case GamepadAction.up:
          _focusedIndex = (_focusedIndex - 1).clamp(0, 1);
          break;
        case GamepadAction.down:
          _focusedIndex = (_focusedIndex + 1).clamp(0, 1);
          break;
        case GamepadAction.action:
          if (_focusedIndex == 0) {
            widget.game.restartGame();
          } else {
            _returnToRoot();
          }
          break;
        default:
          break;
      }
    });
  }

  void _returnToRoot() {
    // We need to exit the game overlay and go back to MenuScreen
    // Since NeonSnakeGame is a widget in GameScreen, we likely need to pop the GameScreen
    // But GameOverScreen is an overlay ON TOP of GameScreen.

    // 1. Remove overlay
    widget.game.overlays.remove('GameOverScreen');

    // 2. Navigate back using the context of the GameWidget (if accessible) or similar
    // Since we are in an Overlay, context might be tricky.
    // However, we can try using the game's build context if available, or pass a callback.
    // For now, let's try finding the Navigator from the context.

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const MenuScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.8),
          border: Border.all(color: Colors.redAccent, width: 2),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.redAccent.withValues(alpha: 0.5),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'SYSTEM FAILURE',
              style: GoogleFonts.orbitron(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
                shadows: [
                  const Shadow(
                    blurRadius: 10,
                    color: Colors.red,
                    offset: Offset(0, 0),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Score: ${widget.game.score}',
              style: GoogleFonts.orbitron(fontSize: 24, color: Colors.white),
            ),
            const SizedBox(height: 30),

            // Reboot Button
            _buildButton(
              index: 0,
              label: 'REBOOT SYSTEM',
              onPressed: () => widget.game.restartGame(),
            ),

            const SizedBox(height: 15),

            // Return to Root Button
            _buildButton(
              index: 1,
              label: 'RETURN TO ROOT',
              onPressed: _returnToRoot,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton({
    required int index,
    required String label,
    required VoidCallback onPressed,
  }) {
    final isFocused = _focusedIndex == index;
    return SizedBox(
      width: 250,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isFocused ? Colors.white : Colors.redAccent,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          side: isFocused
              ? const BorderSide(color: Colors.redAccent, width: 3)
              : null,
          textStyle: GoogleFonts.orbitron(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        child: Text(label),
      ),
    );
  }
}
