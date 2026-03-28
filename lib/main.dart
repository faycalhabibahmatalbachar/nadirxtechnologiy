import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'core/config/theme_config.dart';
import 'core/config/router_config.dart';
import 'firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (!DefaultFirebaseOptions.isCurrentPlatformConfigured) return;
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase + FCM uniquement si firebase_options.dart est réellement configuré.
  // Sinon Firebase.initializeApp peut bloquer ou échouer et l’app reste sur l’écran de lancement Android.
  if (DefaultFirebaseOptions.isCurrentPlatformConfigured) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      if (!kIsWeb) {
        await FirebaseMessaging.instance.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
      }
    } catch (e) {
      debugPrint('Firebase init ignorée: $e');
    }
  } else {
    debugPrint(
      'Firebase non configuré (clés YOUR_* dans firebase_options.dart). '
      'Exécutez: dart pub global activate flutterfire_cli && flutterfire configure',
    );
  }

  // L’UI s’affiche tout de suite ; Supabase + notifications sont lancés depuis le splash
  // via [bootstrapAppServices] (pas d’await bloquant avant [runApp]).
  runApp(const ProviderScope(child: NadirxApp()));
}

class NadirxApp extends ConsumerWidget {
  const NadirxApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'NADIRX TECHNOLOGY',
      theme: AppTheme.cyberTheme,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fr', 'FR'),
      ],
    );
  }
}
