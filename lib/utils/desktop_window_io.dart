import 'dart:io' show exit, Platform;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:window_manager/legacy.dart'
    show windowManager, WindowListener, WindowOptions, TitleBarStyle;

import '../game/config.dart';

/// Sizes, centres and shows the desktop window. Not used on web.
Future<void> setupDesktopWindow() async {
  if (defaultTargetPlatform != TargetPlatform.windows &&
      defaultTargetPlatform != TargetPlatform.linux &&
      defaultTargetPlatform != TargetPlatform.macOS) {
    return;
  }
  await windowManager.ensureInitialized();

  const double width = GameConfig.gridWidth * GameConfig.cellSize + 20;
  const double height = GameConfig.gridHeight * GameConfig.cellSize + 60;

  WindowOptions windowOptions = const WindowOptions(
    size: Size(width, height),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
    title: 'Neon Ouroboros',
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
    await windowManager.setTitle('Neon Ouroboros');
  });

  // Force exit on window close
  windowManager.addListener(_WindowCloseListener());
}

class _WindowCloseListener extends WindowListener {
  @override
  void onWindowClose() {
    if (Platform.isWindows) {
      exit(0);
    }
  }
}
