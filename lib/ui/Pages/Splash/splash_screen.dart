import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_conference/MainPage.dart';
import 'package:video_conference/ui/Authentication/login_screen.dart';
import 'package:video_conference/ui/Services/under_maintainance.dart';

import '../../../firebase_options.dart'; // Path to your UnderMaintenance

class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({super.key});

  @override
  State<SplashScreenPage> createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage> {
  @override
  void initState() {
    super.initState();

    // Call login check after splash screen delay
    Timer(const Duration(seconds: 3), () {
      checkIfAlreadyLogin();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.primaryColorLight,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/logos/LOGO2.png",
              width: 160,
              height: 135,
            ),
            const SizedBox(height: 6),
            Text(
              "SWANPAIR",
              style: context.textTheme.displaySmall
                  ?.copyWith(color: context.theme.scaffoldBackgroundColor),
            ),
          ],
        ),
      ),
    );
  }

  // Function to check login status and navigate accordingly
  Future<void> checkIfAlreadyLogin() async {
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
        // Navigate to maintenance screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const UnderMaintainance()),
        );
      } else {
        // Check login status
        SharedPreferences prefs = await SharedPreferences.getInstance();
        bool? isLoggedIn = prefs.getBool('isLoggedIn');

        if (isLoggedIn == true) {
          // If logged in, navigate to MainPage (dashboard)
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainPage()),
          );
        } else {
          // If not logged in, navigate to LoginScreen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error checking login status: $e');
      }

      // Navigate to error screen or handle error here
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Center(
              child: Text(
                'An error occurred. Please try again.',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ),
        ),
      );
    }
  }
}
