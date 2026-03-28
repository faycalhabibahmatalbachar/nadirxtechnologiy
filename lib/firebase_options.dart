import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Configuration Firebase par défaut.
/// Remplacez les valeurs par celles de votre projet Firebase.
/// Pour générer ce fichier automatiquement: flutterfire configure
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return ios;
    }
    return android;
  }

  /// Indique si les options Firebase de la plateforme courante sont renseignées
  /// (pas les placeholders `YOUR_*` du template).
  static bool get isCurrentPlatformConfigured {
    final opts = currentPlatform;
    return opts.apiKey.isNotEmpty &&
        !opts.apiKey.startsWith('YOUR_') &&
        opts.appId.isNotEmpty &&
        !opts.appId.startsWith('YOUR_');
  }

  /// Configuration Firebase pour Android.
  /// Remplacez les valeurs par celles de votre projet Firebase Console.
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_ANDROID_API_KEY',
    appId: 'YOUR_ANDROID_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_STORAGE_BUCKET',
  );

  /// Configuration Firebase pour iOS.
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_STORAGE_BUCKET',
    iosClientId: 'YOUR_IOS_CLIENT_ID',
    iosBundleId: 'com.nadirx.nadirxTechnologie',
  );

  /// Configuration Firebase pour Web.
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_WEB_API_KEY',
    appId: 'YOUR_WEB_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_STORAGE_BUCKET',
  );
}
