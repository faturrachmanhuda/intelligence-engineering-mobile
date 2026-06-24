import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'services/auth_service.dart';
import 'main_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Suppress known Flutter Desktop mouse_tracker.dart assertion error.
  // This is a framework-level bug (not application code) that causes crashes
  // on Windows/macOS/Linux when widgets with hover states are removed during
  // navigation transitions while the mouse pointer is still over them.
  // This assertion is debug-only and does not exist in release builds.
  if (kDebugMode) {
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      final message = details.exceptionAsString();
      if (message.contains('_debugDuringDeviceUpdate') ||
          message.contains('mouse_tracker.dart')) {
        // Silently ignore this known framework assertion error.
        return;
      }
      // Forward all other errors to the default handler.
      originalOnError?.call(details);
    };
  }

  // Initialize sqflite FFI for desktop platforms (Windows/Linux/macOS)
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  final authService = AuthService();
  final isLoggedIn = await authService.isLoggedIn();
  runApp(IntelligenceEngineeringApp(isLoggedIn: isLoggedIn));
}
