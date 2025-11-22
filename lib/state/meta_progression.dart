import 'package:hive_flutter/hive_flutter.dart';

enum SnakeClass { viper, python, hydra }

enum StatType {
  speed, // Start with speed boost
  length, // Start with extra length
  luck, // Higher chance for rare powerups
}

enum SnakeAbility { none, doubleGrowth }

class MetaProgression {
  static const String _boxName = 'neon_ouroboros_meta';
  static const String _keyHighScore = 'high_score';
  static const String _keyDataShards = 'data_shards';
  static const String _keyUnlockedClasses = 'unlocked_classes';
  static const String _keySelectedClass = 'selected_class';
  static const String _keyStatUpgrades = 'stat_upgrades';
  static const String _keySnakeLevels = 'snake_levels';

  static late Box _box;

  static Future<void> init({bool testing = false}) async {
    if (!testing) {
      await Hive.initFlutter();
    }
    _box = await Hive.openBox(_boxName);
  }

  // Currency
  static int get highScore => _box.get(_keyHighScore, defaultValue: 0);
  static int get dataShards => _box.get(_keyDataShards, defaultValue: 0);

  static Future<void> saveScore(int score) async {
    if (score > highScore) {
      await _box.put(_keyHighScore, score);
    }
  }

  static Future<void> addDataShards(int amount) async {
    final current = dataShards;
    await _box.put(_keyDataShards, current + amount);
  }

  static Future<bool> spendDataShards(int amount) async {
    final current = dataShards;
    if (current >= amount) {
      await _box.put(_keyDataShards, current - amount);
      return true;
    }
    return false;
  }

  // Classes
  static List<SnakeClass> get unlockedClasses {
    final List<dynamic> stored = _box.get(
      _keyUnlockedClasses,
      defaultValue: [SnakeClass.viper.index],
    );
    return stored.map((e) => SnakeClass.values[e as int]).toList();
  }

  static SnakeClass get selectedClass {
    final int index = _box.get(
      _keySelectedClass,
      defaultValue: SnakeClass.viper.index,
    );
    return SnakeClass.values[index];
  }

  static Future<void> unlockClass(SnakeClass classType) async {
    final current = unlockedClasses;
    if (!current.contains(classType)) {
      current.add(classType);
      await _box.put(_keyUnlockedClasses, current.map((e) => e.index).toList());
    }
  }

  static Future<void> selectClass(SnakeClass classType) async {
    if (unlockedClasses.contains(classType)) {
      await _box.put(_keySelectedClass, classType.index);
    }
  }

  // Stats
  static int getStatLevel(StatType stat) {
    final Map<dynamic, dynamic> upgrades = _box.get(
      _keyStatUpgrades,
      defaultValue: {},
    );
    return upgrades[stat.index] as int? ?? 0;
  }

  static Future<void> upgradeStat(StatType stat) async {
    final Map<dynamic, dynamic> upgrades = Map.from(
      _box.get(_keyStatUpgrades, defaultValue: {}),
    );
    final currentLevel = upgrades[stat.index] as int? ?? 0;
    upgrades[stat.index] = currentLevel + 1;
    await _box.put(_keyStatUpgrades, upgrades);
  }

  // Snake Levels
  static int getSnakeLevel(SnakeClass classType) {
    final Map<dynamic, dynamic> levels = _box.get(
      _keySnakeLevels,
      defaultValue: {},
    );
    return levels[classType.index] as int? ?? 1; // Start at Level 1
  }

  static Future<bool> upgradeSnake(SnakeClass classType) async {
    const cost = 500;
    if (dataShards >= cost) {
      await spendDataShards(cost);
      final Map<dynamic, dynamic> levels = Map.from(
        _box.get(_keySnakeLevels, defaultValue: {}),
      );
      final currentLevel = levels[classType.index] as int? ?? 1;
      levels[classType.index] = currentLevel + 1;
      await _box.put(_keySnakeLevels, levels);
      return true;
    }
    return false;
  }

  // Helper to get config for a class
  static SnakeConfig getConfigForClass(SnakeClass type) {
    final int level = getSnakeLevel(type);
    final double speedBonus = (level - 1) * 0.01; // 1% faster per level
    final int lengthBonus = (level - 1); // +1 length per level
    final double scoreBonus = (level - 1) * 0.1; // +0.1 multiplier per level

    switch (type) {
      case SnakeClass.viper:
        return SnakeConfig(
          name: 'The Viper',
          description: 'Fast and agile. High score multiplier.',
          baseSpeed: 0.12 - speedBonus, // Lower is faster
          baseLength: 3 + lengthBonus,
          colorBody: 0xFF00FF00, // Green
          colorHead: 0xFFCCFF00,
          scoreMultiplier: 2.0 + scoreBonus,
          ability: SnakeAbility.none,
          level: level,
        );
      case SnakeClass.python:
        return SnakeConfig(
          name: 'The Python',
          description: 'Slow but tough. Starts massive.',
          baseSpeed: 0.20 - speedBonus,
          baseLength: 8 + lengthBonus,
          colorBody: 0xFF0000FF, // Blue
          colorHead: 0xFF0088FF,
          scoreMultiplier: 1.0 + scoreBonus,
          ability: SnakeAbility.none,
          level: level,
        );
      case SnakeClass.hydra:
        return SnakeConfig(
          name: 'The Hydra',
          description: 'Two heads are better than one. Grows twice as fast.',
          baseSpeed: 0.15 - speedBonus,
          baseLength: 5 + lengthBonus,
          colorBody: 0xFFFF0000, // Red
          colorHead: 0xFFFF8800,
          scoreMultiplier: 1.5 + scoreBonus,
          ability: SnakeAbility.doubleGrowth,
          level: level,
        );
    }
  }
}

class SnakeConfig {
  final String name;
  final String description;
  final double baseSpeed;
  final int baseLength;
  final int colorBody;
  final int colorHead;
  final double scoreMultiplier;
  final SnakeAbility ability;
  final int level;

  SnakeConfig({
    required this.name,
    required this.description,
    required this.baseSpeed,
    required this.baseLength,
    required this.colorBody,
    required this.colorHead,
    required this.scoreMultiplier,
    required this.ability,
    required this.level,
  });
}
