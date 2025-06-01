import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // Web configuration
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDdPkp43jbkVXvxHolTF8fhO5Sb7GcuGus',
    appId: '1:843509906849:web:sample-web-appid', // Replace with actual web appId if available
    messagingSenderId: '843509906849',
    projectId: 'virtual-visiting-card-mvvm',
    authDomain: 'virtual-visiting-card-mvvm.firebaseapp.com',
    storageBucket: 'virtual-visiting-card-mvvm.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCqOi7OvggmZpJKZMH1lowuOnU5HTKb6Pk',
    appId: '1:843509906849:android:1fcdf6f990698b36205fe0',
    messagingSenderId: '843509906849',
    projectId: 'virtual-visiting-card-mvvm',
    storageBucket: 'virtual-visiting-card-mvvm.firebasestorage.app',
  );

  // iOS configuration (matches your plist)
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDdPkp43jbkVXvxHolTF8fhO5Sb7GcuGus',
    appId: '1:843509906849:ios:fcde54d0e97935a4205fe0',
    messagingSenderId: '843509906849',
    projectId: 'virtual-visiting-card-mvvm',
    storageBucket: 'virtual-visiting-card-mvvm.firebasestorage.app',
    iosClientId: 'YOUR_IOS_CLIENT_ID', // Replace with the actual iOS client ID, if available.
    iosBundleId: 'com.example.virtualVisitingCard',
  );
}
