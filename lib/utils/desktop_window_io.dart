import 'dart:io' show exit, Platform;

import 'package:flutter/painting.dart' show Size;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:window_manager/window_manager.dart'
    show SizeToNative, TitleBarStyle, WindowCloseRequestedEvent, WindowManager;

import '../game/config.dart';

/// Sizes, centres and shows the desktop window. Not used on web.
Future<void> setupDesktopWindow() async {
  if (defaultTargetPlatform != TargetPlatform.windows &&
      defaultTargetPlatform != TargetPlatform.linux &&
      defaultTargetPlatform != TargetPlatform.macOS) {
    return;
  }

  final window = WindowManager.instance.getCurrent();
  if (window == null) return;

  const double width = GameConfig.gridWidth * GameConfig.cellSize + 20;
  const double height = GameConfig.gridHeight * GameConfig.cellSize + 60;

  window
    ..title = 'Neon Ouroboros'
    ..titleBarStyle = TitleBarStyle.normal
    ..setSize(const Size(width, height).toNative(), false)
    ..center()
    ..show()
    ..focus();

  // Force exit on window close
  window.addListener((event) {
    if (event is WindowCloseRequestedEvent && Platform.isWindows) {
      exit(0);
    }
  });
}
