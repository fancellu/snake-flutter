import 'package:material_ui/material_ui.dart';
import 'state/meta_progression.dart';
import 'ui/menu_screen.dart';
import 'audio/audio_manager.dart';
import 'utils/error_reporter.dart';
import 'utils/desktop_window_stub.dart'
    if (dart.library.io) 'utils/desktop_window_io.dart';
import 'dart:async';

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await MetaProgression.init();
      await AudioManager.init();

      await setupDesktopWindow();

      ErrorReporter.init();
      runApp(const NeonSnakeApp());
    },
    (error, stack) {
      ErrorReporter.log(error, stack);
    },
  );
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
