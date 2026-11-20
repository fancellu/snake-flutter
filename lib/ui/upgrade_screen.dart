import 'dart:async';
import 'package:material_ui/material_ui.dart';
import '../game/upgrades/upgrade.dart';
import '../input/gamepad_manager.dart';

class UpgradeScreen extends StatefulWidget {
  final List<Upgrade> upgrades;
  final Function(Upgrade) onUpgradeSelected;

  const UpgradeScreen({
    super.key,
    required this.upgrades,
    required this.onUpgradeSelected,
  });

  @override
  State<UpgradeScreen> createState() => _UpgradeScreenState();
}

class _UpgradeScreenState extends State<UpgradeScreen> {
  int _focusedIndex = 0;
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
        case GamepadAction.left:
          _focusedIndex = (_focusedIndex - 1).clamp(
            0,
            widget.upgrades.length - 1,
          );
          break;
        case GamepadAction.right:
          _focusedIndex = (_focusedIndex + 1).clamp(
            0,
            widget.upgrades.length - 1,
          );
          break;
        case GamepadAction.action:
          widget.onUpgradeSelected(widget.upgrades[_focusedIndex]);
          break;
        default:
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.85),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'SYSTEM UPGRADE AVAILABLE',
              style: TextStyle(
                color: Colors.cyanAccent,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    blurRadius: 10,
                    color: Colors.cyan,
                    offset: Offset(0, 0),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Wrap(
              spacing: 20,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: widget.upgrades
                  .asMap()
                  .entries
                  .map(
                    (entry) => _buildUpgradeCard(
                      context,
                      entry.value,
                      entry.key == _focusedIndex,
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpgradeCard(
    BuildContext context,
    Upgrade upgrade,
    bool isFocused,
  ) {
    return GestureDetector(
      onTap: () => widget.onUpgradeSelected(upgrade),
      child: Container(
        width: 250,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border.all(
            color: isFocused ? Colors.yellowAccent : Colors.cyanAccent,
            width: isFocused ? 4 : 2,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: (isFocused ? Colors.yellowAccent : Colors.cyanAccent)
                  .withValues(alpha: 0.3),
              blurRadius: isFocused ? 20 : 10,
              spreadRadius: isFocused ? 4 : 2,
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              Icons.memory,
              size: 50,
              color: isFocused ? Colors.yellowAccent : Colors.cyanAccent,
            ),
            const SizedBox(height: 15),
            Text(
              upgrade.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              upgrade.description,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
