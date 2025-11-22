import 'package:flutter/material.dart';
import 'state/meta_progression.dart';
import 'ui/menu_screen.dart';
import 'package:window_manager/window_manager.dart' show windowManager, WindowListener, WindowOptions, TitleBarStyle;
import 'game/config.dart';
import 'audio/audio_manager.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'utils/error_reporter.dart';
import 'dart:async';
import 'dart:io' show exit, Platform;

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await MetaProgression.init();
      await AudioManager.init();

      if (!kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.windows ||
              defaultTargetPlatform == TargetPlatform.linux ||
              defaultTargetPlatform == TargetPlatform.macOS)) {
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

      ErrorReporter.init();
      runApp(const NeonSnakeApp());
    },
    (error, stack) {
      ErrorReporter.log(error, stack);
    },
  );
}

class _WindowCloseListener extends WindowListener {
  @override
  void onWindowClose() {
    if (!kIsWeb && Platform.isWindows) {
      exit(0);
    }
  }
}

class NeonSnakeApp extends StatelessWidget {
  const NeonSnakeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Neon Ouroboros',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.cyan,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'Courier', // Techy font
      ),
      home: const MenuScreen(),
    );
  }
}
