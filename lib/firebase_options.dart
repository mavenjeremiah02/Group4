import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw _notConfigured();
      case TargetPlatform.macOS:
        throw _notConfigured();
      case TargetPlatform.windows:
        throw _notConfigured();
      case TargetPlatform.linux:
        throw _notConfigured();
      case TargetPlatform.fuchsia:
        throw _notConfigured();
    }
  }

  static UnsupportedError _notConfigured() {
    return UnsupportedError(
      'Firebase is not configured yet. Run `flutterfire configure` to generate '
      'real Firebase options for this project.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBLj7x1nRLhV35wv7cSBdY8cgzPuLZl4h8',
    authDomain: 'medi-quick-24cb1.firebaseapp.com',
    projectId: 'medi-quick-24cb1',
    storageBucket: 'medi-quick-24cb1.firebasestorage.app',
    messagingSenderId: '1009728853141',
    appId: '1:1009728853141:web:dd19ef9ab858f268e9379c',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCU3EtHLD2HHn3yOIAXQUraRxfdhYUHYdQ',
    appId: '1:1009728853141:android:bdff5404fd579c53e9379c',
    messagingSenderId: '1009728853141',
    projectId: 'medi-quick-24cb1',
    storageBucket: 'medi-quick-24cb1.firebasestorage.app',
  );
}
