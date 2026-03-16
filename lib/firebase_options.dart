// ⚠️ IMPORTANT: Replace this file with your actual Firebase config
// Go to console.firebase.google.com → your project → </> web app → copy config
// Then paste your values below

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android: return android;
      case TargetPlatform.iOS:     return ios;
      default:                     return web;
    }
  }

  // ── Paste YOUR Firebase config values here ────────────────────────────────
  static const FirebaseOptions web = FirebaseOptions(
   apiKey: 'AIzaSyAnb7oHi58YGj2CvA8eFhlw9PVBxhunUNY',
   authDomain: 'kaamyab-97a54.firebaseapp.com',
  projectId: 'kaamyab-97a54',
  storageBucket: 'kaamyab-97a54.firebasestorage.app',
  messagingSenderId: '228596475458',
  appId: '1:228596475458:web:157175dae2162e392e2fdb',
  measurementId: 'G-G1FZWBRQEL',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey:            'YOUR_API_KEY',
    authDomain:        'YOUR_PROJECT.firebaseapp.com',
    projectId:         'YOUR_PROJECT_ID',
    storageBucket:     'YOUR_PROJECT.firebasestorage.app',
    messagingSenderId: 'YOUR_SENDER_ID',
    appId:             'YOUR_APP_ID',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey:            'YOUR_API_KEY',
    authDomain:        'YOUR_PROJECT.firebaseapp.com',
    projectId:         'YOUR_PROJECT_ID',
    storageBucket:     'YOUR_PROJECT.firebasestorage.app',
    messagingSenderId: 'YOUR_SENDER_ID',
    appId:             'YOUR_APP_ID',
  );
}
