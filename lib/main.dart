import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_conference/ui/Pages/Splash/splash_screen.dart';
import 'package:video_conference/ui/Services/under_maintainance.dart';

import 'MainPage.dart';
import 'firebase_options.dart'; // Ensure you have this file set up correctly

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background message
  print('Handling a background message: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Set up the background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  final Functions authMethods = Functions();
  Widget homeWidget = await authMethods.checkIfAlreadyLogin();

  runApp(MyApp(homeWidget: homeWidget));
}

class MyApp extends StatelessWidget {
  final Widget homeWidget;

  const MyApp({super.key, required this.homeWidget});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Swan Pair',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      home: homeWidget,
    );
  }
}

// Functions class with FCM integration
class Functions {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initializeFCM() async {
    // Request permission for iOS
    NotificationSettings settings =
        await _firebaseMessaging.requestPermission();

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else {
      print('User declined or has not accepted permission');
    }

    // Get the FCM token
    String? token = await _firebaseMessaging.getToken();
    print('FCM Token: $token');

    // Save the token to SharedPreferences
    if (token != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcmToken', token);
      print('FCM Token saved to SharedPreferences');
    }

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received a message while in the foreground: ${message.messageId}');
      // You can show a dialog or a notification here
    });

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  Future<Widget> checkIfAlreadyLogin() async {
    try {
      // Initialize Firebase
      if (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }

      // Check if the app is under maintenance
      DocumentSnapshot maintenanceSnapshot = await FirebaseFirestore.instance
          .collection('settings')
          .doc('appStatus')
          .get();

      bool isAppUnderMaintenance =
          maintenanceSnapshot['isAppUnderMaintenance'] ?? false;

      if (isAppUnderMaintenance) {
        return const UnderMaintainance(); // Define this screen to show maintenance message
      } else {
        // Check login status if app is not under maintenance
        SharedPreferences prefs = await SharedPreferences.getInstance();
        bool? isLoggedIn = prefs.getBool('isLoggedIn');

        await initializeFCM();
        // Return the appropriate widget based on the login status
        if (isLoggedIn == true) {
          return const MainPage();
        } else {
          return const SplashScreenPage();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error checking login status: $e');
      }

      // Return an error screen or a default screen
      return const Scaffold(
        body: Center(
          child: Text(
            'An error occurred while checking login status. Please try again.',
            style: TextStyle(color: Colors.red),
          ),
        ),
      );
    }
  }
}
