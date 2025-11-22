import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';

class AudioManager {
  static bool isTesting = false;

  static Future<void> init() async {
    if (isTesting) return;
    try {
      await FlameAudio.audioCache.loadAll([
        'food.mp3',
        'gameover.mp3',
        'snake-bgm.mp3',
      ]);
    } catch (e) {
      debugPrint('Audio Init Error: $e');
    }
  }

  static void playEat() {
    if (isTesting) return;
    try {
      FlameAudio.play('food.mp3');
      debugPrint('Audio: Eat');
    } catch (e) {
      debugPrint('Audio Error: $e');
    }
  }

  static void playDie() {
    if (isTesting) return;
    try {
      FlameAudio.play('gameover.mp3');
      debugPrint('Audio: Die');
    } catch (e) {
      debugPrint('Audio Error: $e');
    }
  }

  static void playBgm() {
    if (isTesting) return;
    try {
      if (!FlameAudio.bgm.isPlaying) {
        FlameAudio.bgm.play('snake-bgm.mp3', volume: 0.3);
      }
    } catch (e) {
      debugPrint("Error playing BGM: $e");
    }
  }

  static void pauseBgm() {
    if (isTesting) return;
    try {
      FlameAudio.bgm.pause();
    } catch (e) {
      debugPrint("Error pausing BGM: $e");
    }
  }

  static void resumeBgm() {
    if (isTesting) return;
    try {
      FlameAudio.bgm.resume();
    } catch (e) {
      debugPrint("Error resuming BGM: $e");
    }
  }
}
