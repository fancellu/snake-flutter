import 'dart:async';
import 'package:gamepads/gamepads.dart';
import 'package:flutter/foundation.dart';

enum GamepadAction {
  up,
  down,
  left,
  right,
  action, // A / Cross
  back, // B / Circle
  pause, // Start / Options
}

class GamepadManager {
  static final GamepadManager _instance = GamepadManager._internal();
  factory GamepadManager() => _instance;
  GamepadManager._internal();

  StreamSubscription<GamepadEvent>? _subscription;
  final _actionController = StreamController<GamepadAction>.broadcast();
  Stream<GamepadAction> get actionStream => _actionController.stream;

  bool _isListening = false;

  Future<void> init() async {
    if (_isListening) return;

    try {
      _subscription = Gamepads.events.listen(_onGamepadEvent);
      _isListening = true;
      debugPrint('GamepadManager initialized');
    } catch (e) {
      debugPrint('Error initializing GamepadManager: $e');
    }
  }

  void dispose() {
    // Don't actually dispose the singleton, just clean up
    // Multiple screens may be using it
  }

  void _onGamepadEvent(GamepadEvent event) {
    debugPrint('Gamepad Event: ${event.key} ${event.type} ${event.value}');

    // Simple mapping for now.
    // Note: Key codes vary by controller and OS.
    // We'll implement a basic mapping for common controllers (Xbox/PS).

    // Analog Sticks (Axis)
    if (event.type == KeyType.analog) {
      // Threshold for stick drift
      const double threshold = 0.5;

      // Left Stick X
      if (event.key == 'lx' || event.key == 'analog 0') {
        if (event.value > threshold) {
          _emit(GamepadAction.right);
        } else if (event.value < -threshold) {
          _emit(GamepadAction.left);
        }
      }
      // Left Stick Y
      else if (event.key == 'ly' || event.key == 'analog 1') {
        if (event.value > threshold) {
          _emit(GamepadAction.down); // Y is usually down-positive
        } else if (event.value < -threshold) {
          _emit(GamepadAction.up);
        }
      }

      // D-Pad (Hat) - often mapped as axis on some platforms or buttons on others
      // Windows XInput often maps D-Pad as buttons, but let's check keys

      // Windows Specific Analog (XInput)
      if (event.key == 'dwXpos') {
        // 0..65535, center ~32768
        double normalized = (event.value - 32768) / 32768.0;
        if (normalized > 0.5) {
          _emit(GamepadAction.right);
        }
        if (normalized < -0.5) {
          _emit(GamepadAction.left);
        }
      }
      if (event.key == 'dwYpos') {
        // 0..65535, center ~32768. 0 is Top (Up), 65535 is Bottom (Down)
        double normalized = (event.value - 32768) / 32768.0;
        if (normalized > 0.5) {
          _emit(GamepadAction.down);
        }
        if (normalized < -0.5) {
          _emit(GamepadAction.up);
        }
      }

      if (event.key == 'pov') {
        // 0 = Up, 9000 = Right, 18000 = Down, 27000 = Left
        // 65535 = Center
        if (event.value == 0) {
          _emit(GamepadAction.up);
        }
        if (event.value == 9000) {
          _emit(GamepadAction.right);
        }
        if (event.value == 18000) {
          _emit(GamepadAction.down);
        }
        if (event.value == 27000) {
          _emit(GamepadAction.left);
        }
      }
    }

    // Buttons
    if (event.type == KeyType.button && event.value == 1.0) {
      switch (event.key) {
        case 'button-0': // Windows
        case 'button 0': // Web
          _emit(GamepadAction.action);
          break;
        case 'button-1': // Windows
        case 'button 1': // Web
          _emit(GamepadAction.back);
          break;
        case 'button-6': // Windows Back/Select
        case 'button-7': // Windows Start
        case 'button 7': // Web
        case 'button 9': // Web Start
          _emit(GamepadAction.pause);
          break;
        case 'button-12': // Windows D-Pad Up
        case 'button 12': // Web
        case 'dpad-up':
          _emit(GamepadAction.up);
          break;
        case 'button-13': // Windows D-Pad Down
        case 'button 13': // Web
        case 'dpad-down':
          _emit(GamepadAction.down);
          break;
        case 'button-14': // Windows D-Pad Left
        case 'button 14': // Web
        case 'dpad-left':
          _emit(GamepadAction.left);
          break;
        case 'button-15': // Windows D-Pad Right
        case 'button 15': // Web
        case 'dpad-right':
          _emit(GamepadAction.right);
          break;
      }
    }
  }

  void _emit(GamepadAction action) {
    if (!_actionController.isClosed) {
      _actionController.add(action);
    }
  }
}
