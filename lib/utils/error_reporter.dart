import 'package:flutter/foundation.dart';

class ErrorReporter {
  static final ErrorReporter _instance = ErrorReporter._internal();
  factory ErrorReporter() => _instance;
  ErrorReporter._internal();

  static void init() {
    // Catch Flutter Errors
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      log(details.exception, details.stack);
    };

    // Catch Platform Errors
    PlatformDispatcher.instance.onError = (error, stack) {
      log(error, stack);
      return true;
    };
  }

  static void log(Object error, [StackTrace? stack]) {
    debugPrint('---------------- ERROR CAUGHT ----------------');
    debugPrint(error.toString());
    if (stack != null) {
      debugPrint(stack.toString());
    }
    debugPrint('----------------------------------------------');

    // In a real app, we would send this to Sentry/Crashlytics
  }
}
