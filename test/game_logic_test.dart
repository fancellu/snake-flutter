import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snake/game/neon_snake_game.dart';
import 'package:snake/game/entities/food.dart';
import 'package:snake/audio/audio_manager.dart';
import 'package:snake/state/meta_progression.dart';

import 'dart:io';
import 'package:hive/hive.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    AudioManager.isTesting = true;

    final tempDir = await Directory.systemTemp.createTemp();
    Hive.init(tempDir.path);

    await MetaProgression.init(testing: true);
  });
  final tester = FlameTester(NeonSnakeGame.new);

  group('NeonSnakeGame Logic', () {
    tester.testGameWidget(
      'Initial state is correct',
      setUp: (game, tester) async {
        await game.ready();
        game.update(0);
        game.update(0);
      },
      verify: (game, tester) async {
        expect(game.snake, isNotNull);
        expect(game.world.children.whereType<Food>().isNotEmpty, true);
        expect(game.firewall, isNotNull);
        expect(game.score, 0);
        expect(game.foodEaten, 0);
        expect(game.world.children.whereType<Food>().length, 1);
      },
    );

    tester.testGameWidget(
      'Eating food increments score and spawns new food',
      setUp: (game, tester) async {
        await game.ready();
        game.update(0);
        game.update(0);
      },
      verify: (game, tester) async {
        final initialFood = game.world.children.whereType<Food>().first;
        final initialFoodPos = initialFood.position.clone();

        // Simulate eating food
        game.eatFood(initialFood);

        // Advance game loop to allow snake to move and grow
        game.update(0.2);

        expect(game.score, game.scoreMultiplier); // 1 food x class multiplier
        expect(game.foodEaten, 1);
        expect(game.snake!.body.length, greaterThan(3)); // Should grow

        // Check new food spawned
        expect(game.world.children.whereType<Food>().length, 1);
        final newFood = game.world.children.whereType<Food>().first;
        expect(newFood.position, isNot(equals(initialFoodPos)));
      },
    );

    tester.testGameWidget(
      'Level progression works (eat 5 foods)',
      setUp: (game, tester) async {
        await game.ready();
        game.update(0);
        game.update(0);
      },
      verify: (game, tester) async {
        game.levelTarget = 5;

        // Eat 4 foods
        for (int i = 0; i < 4; i++) {
          final food = game.world.children.whereType<Food>().first;
          game.eatFood(food);
          game.update(0.1); // Process add/remove
          expect(
            game.world.children.whereType<Food>().isNotEmpty,
            true,
            reason: 'Food should exist after eating $i',
          );
        }

        expect(game.foodEaten, 4);
        expect(game.firewall!.isOpen, false);

        // Eat 5th food
        final lastFood = game.world.children.whereType<Food>().first;
        game.eatFood(lastFood);
        game.update(0.1);

        expect(game.foodEaten, 5);
        expect(game.firewall!.isOpen, true);
        expect(
          game.world.children.whereType<Food>().isNotEmpty,
          true,
          reason: 'Food should still exist after level completion',
        );
      },
    );
  });
}
