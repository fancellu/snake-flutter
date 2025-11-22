import 'package:flutter/material.dart';
import '../state/meta_progression.dart';
import 'dart:async';
import '../input/gamepad_manager.dart';
import 'game_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  int _focusedIndex = 0;
  StreamSubscription<GamepadAction>? _gamepadSubscription;

  @override
  void initState() {
    super.initState();
    _initGamepad();
  }

  Future<void> _initGamepad() async {
    await GamepadManager().init();
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
    debugPrint('Menu received action: $action');

    switch (action) {
      case GamepadAction.up:
        setState(() {
          _focusedIndex = (_focusedIndex - 1).clamp(0, SnakeClass.values.length);
        });
        break;
      case GamepadAction.down:
        setState(() {
          _focusedIndex = (_focusedIndex + 1).clamp(0, SnakeClass.values.length);
        });
        break;
      case GamepadAction.action:
        _handleAction();
        break;
      case GamepadAction.pause:
        _startGame();
        break;
      default:
        break;
    }
  }

  void _handleAction() {
    if (_focusedIndex == SnakeClass.values.length) {
      _startGame();
      return;
    }

    final type = SnakeClass.values[_focusedIndex];
    final isUnlocked = MetaProgression.unlockedClasses.contains(type);
    final isSelected = MetaProgression.selectedClass == type;

    if (isUnlocked) {
      if (!isSelected) {
        MetaProgression.selectClass(type);
      } else {
        // Upgrade?
        _upgradeSnake(type);
      }
    } else {
      _unlockClass(type);
    }
    setState(() {});
  }

  Future<void> _upgradeSnake(SnakeClass type) async {
    final success = await MetaProgression.upgradeSnake(type);
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Not enough Data Shards!'),
          backgroundColor: Colors.red,
        ),
      );
    }
    setState(() {});
  }

  Future<void> _unlockClass(SnakeClass type) async {
    final cost = type == SnakeClass.viper
        ? 0
        : (type == SnakeClass.python ? 100 : 500);
    if (await MetaProgression.spendDataShards(cost)) {
      await MetaProgression.unlockClass(type);
      await MetaProgression.selectClass(type);
    } else if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Not enough Data Shards!')));
    }
    setState(() {});
  }

  void _startGame() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const GameScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shards = MetaProgression.dataShards;
    final selectedClass = MetaProgression.selectedClass;
    final unlockedClasses = MetaProgression.unlockedClasses;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Center(
                child: Text(
                  'NEON OUROBOROS',
                  style: TextStyle(
                    color: Colors.cyanAccent,
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Courier',
                    shadows: [
                      Shadow(
                        blurRadius: 20,
                        color: Colors.cyan,
                        offset: Offset(0, 0),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  'SYSTEM ROOT',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 16,
                    letterSpacing: 4,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Currency
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(Icons.memory, color: Colors.purpleAccent),
                  const SizedBox(width: 8),
                  Text(
                    '$shards SHARDS',
                    style: const TextStyle(
                      color: Colors.purpleAccent,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Class Selection
              const Text(
                'SELECT CLASS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: SnakeClass.values.length,
                  itemBuilder: (context, index) {
                    final type = SnakeClass.values[index];
                    final config = MetaProgression.getConfigForClass(type);
                    final isUnlocked = unlockedClasses.contains(type);
                    final isSelected = selectedClass == type;
                    final cost = type == SnakeClass.viper
                        ? 0
                        : (type == SnakeClass.python ? 100 : 500);

                    return Card(
                      color: isSelected
                          ? Colors.cyan.withValues(alpha: 0.2)
                          : (_focusedIndex == index
                                ? Colors.grey[800]
                                : Colors.grey[900]),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: _focusedIndex == index
                              ? Colors
                                    .yellowAccent // Focus color
                              : (isSelected
                                    ? Colors.cyanAccent
                                    : (isUnlocked ? Colors.grey : Colors.red)),
                          width: _focusedIndex == index
                              ? 3
                              : (isSelected ? 2 : 1),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(
                          config.name,
                          style: TextStyle(
                            color: Color(config.colorHead),
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              config.description,
                              style: const TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'LVL: ${config.level} | SPD: ${(1.0 / config.baseSpeed).toStringAsFixed(1)}x | LEN: ${config.baseLength} | MULT: ${config.scoreMultiplier.toStringAsFixed(1)}x',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 10),
                            // Upgrade Button
                            if (isUnlocked)
                              ElevatedButton(
                                onPressed: () async {
                                  final success =
                                      await MetaProgression.upgradeSnake(type);
                                  if (success) {
                                    setState(() {});
                                  } else if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Not enough Data Shards!',
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orangeAccent,
                                  foregroundColor: Colors.black,
                                ),
                                child: Text(
                                  'UPGRADE (500) - LVL ${config.level}',
                                ),
                              ),
                          ],
                        ),
                        trailing: isUnlocked
                            ? (isSelected
                                  ? const Icon(
                                      Icons.check_circle,
                                      color: Colors.cyanAccent,
                                    )
                                  : ElevatedButton(
                                      onPressed: () {
                                        MetaProgression.selectClass(type);
                                        setState(() {});
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.grey[800],
                                      ),
                                      child: const Text('SELECT'),
                                    ))
                            : ElevatedButton(
                                onPressed: () async {
                                  if (await MetaProgression.spendDataShards(
                                    cost,
                                  )) {
                                    await MetaProgression.unlockClass(type);
                                    await MetaProgression.selectClass(type);
                                    setState(() {});
                                  } else if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Not enough Data Shards!',
                                        ),
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red[900],
                                ),
                                child: Text('UNLOCK ($cost)'),
                              ),
                      ),
                    );
                  },
                ),
              ),

              // Start Button
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const GameScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _focusedIndex == SnakeClass.values.length
                        ? Colors.yellowAccent
                        : Colors.cyanAccent,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                      side: _focusedIndex == SnakeClass.values.length
                          ? const BorderSide(color: Colors.white, width: 3)
                          : BorderSide.none,
                    ),
                  ),
                  child: const Text(
                    'INITIATE SEQUENCE',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
