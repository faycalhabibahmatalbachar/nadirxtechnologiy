import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../shared/providers/fcm_provider.dart';
import 'config/app_config.dart';

/// Initialisation réseau / plugins après le premier frame Flutter.
/// Évite de bloquer sur l’écran système Android (icône seule) avant [runApp].
Future<void>? _bootstrapFuture;

Future<void> bootstrapAppServices() {
  return _bootstrapFuture ??= _runBootstrap();
}

Future<void> _runBootstrap() async {
  try {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
    ).timeout(const Duration(seconds: 30));
  } on TimeoutException catch (e) {
    debugPrint('Supabase init timeout: $e');
  } catch (e) {
    debugPrint('Supabase init erreur: $e');
  }

  try {
    await initializeNotifications();
  } catch (e) {
    debugPrint('Notifications locales: $e');
  }
}
