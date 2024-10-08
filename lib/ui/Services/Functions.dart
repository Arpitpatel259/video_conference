import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_conference/MainPage.dart';
import 'package:video_conference/ui/Pages/Splash/splash_screen.dart';
import 'package:video_conference/ui/Services/under_maintainance.dart';
import 'package:video_conference/widget/common_snackbar.dart';

import '../../firebase_options.dart';
import 'DatabaseMethod.dart';

class Functions {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  var firstController = TextEditingController();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var cPasswordController = TextEditingController();

  //getting current User
  Future<User?> getCurrentUser() async {
    return _auth.currentUser;
  }

  //To check user is logged in or not
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

  // Google Login
  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      // Web specific initialization
      if (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }

      var scopes = [
        'email',
      ];

      GoogleSignIn googleSignIn = GoogleSignIn(scopes: scopes);

      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken,
        );

        UserCredential result = await _auth.signInWithCredential(credential);

        User? user = result.user;

        if (user != null) {
          Map<String, dynamic> userInfo = {
            "email": user.email,
            "name": user.displayName,
            "imgUrl": user.photoURL,
            "id": user.uid,
          };
          await DatabaseMethod()
              .addUser(user.uid, userInfo)
              .then((value) async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setBool('isLoggedIn', true);
            await prefs.setString('userId', user.uid);
            await prefs.setString('email', user.email.toString());
            await prefs.setString('name', user.displayName.toString());
            await prefs.setString('imgUrl', user.photoURL.toString());

            CustomSnackBar.show(
              context,
              'You Have Been Logged In Successfully!',
            );

            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const MainPage()),
                (route) => false);
          });
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error signing in with Google: $e');
      }
    }
  }

  //Register With Email/Password
  Future<void> registerUser(
      String name, String email, String password, String cPassword) async {
    if (password != cPassword) {
      if (kDebugMode) {
        print('Passwords do not match');
      }
      return;
    }

    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      User? user = userCredential.user;

      if (user != null) {
        DatabaseMethod databaseMethod = DatabaseMethod();

        Map<String, dynamic> userInfo = {
          'id': user.uid,
          'name': name,
          'email': email,
          'imgUrl': "",
          'password': password,
          "status": "Offline",
          "isAdded": false,
        };

        await databaseMethod.addUser(user.uid, userInfo);

        firstController.clear();
        emailController.clear();
        passwordController.clear();
        cPasswordController.clear();
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
    }
  }

  //Login with Email/Password
  Future<void> userLogin(
      String email, String password, BuildContext context) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      if (userCredential.user != null) {
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('User')
            .doc(userCredential.user!.uid)
            .get();

        if (userSnapshot.exists) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);
          await prefs.setString("email", userSnapshot['email']);
          await prefs.setString("name", userSnapshot['name']);
          await prefs.setString("userId", userSnapshot.id);
          await prefs.setString("imgUrl", userSnapshot['imgUrl'] ?? "");

          CustomSnackBar.show(
            context,
            'You Have Been Logged In Successfully!',
          );

          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const MainPage()),
            (Route<dynamic> route) => false,
          );
        } else {
          throw Exception("User data not found in Firestore");
        }
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'user-not-found') {
        errorMessage = "No User Found for that Email";
      } else if (e.code == 'wrong-password') {
        errorMessage = "Wrong Password Provided by You";
      } else if (e.code == 'invalid-email') {
        errorMessage = "Invalid Email Provided by You";
      } else {
        errorMessage = "An unknown error occurred";
      }
      CustomSnackBar.show(
        context,
        errorMessage,
      );
    } catch (e) {
      CustomSnackBar.show(
        context,
        "An error occurred while logging in. Please try again.",
      );
    }
  }

  //To show Profile images
  Widget buildProfileImage(String? base64Image) {
    if (base64Image == null || base64Image.isEmpty) {
      // Handle the case where no image is provided
      return const Icon(
        Icons.account_circle,
        size: 50,
        color: Colors.grey,
      );
    }

    // Heuristic to check if the input is a URL or Base64 string
    if (base64Image.startsWith('http') || base64Image.startsWith('https')) {
      // Use Image.network with a loading builder and error handling
      return ClipOval(
        child: Image.network(
          base64Image,
          fit: BoxFit.cover,
          width: 50,
          height: 50,
          loadingBuilder: (BuildContext context, Widget child,
              ImageChunkEvent? loadingProgress) {
            if (loadingProgress == null) {
              return child;
            } else {
              return const SizedBox(
                width: 50,
                height: 50,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
          },
          errorBuilder: (context, error, stackTrace) {
            return const Icon(
              Icons.error,
              size: 50,
              color: Colors.red,
            );
          },
        ),
      );
    } else {
      try {
        // Decode the Base64 string to bytes
        Uint8List imageBytes = base64Decode(base64Image);

        return ClipOval(
          child: Image.memory(
            imageBytes,
            fit: BoxFit.cover,
            width: 50,
            height: 50,
          ),
        );
      } catch (e) {
        // Handle errors during decoding
        return const Icon(
          Icons.error,
          size: 50,
          color: Colors.red,
        );
      }
    }
  }

  //Logout Your Session
  Future<void> logout(BuildContext context) async {
    try {
      // Sign out from Google
      await _googleSignIn.signOut();

      // Clear Shared Preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const SplashScreenPage()),
          (route) => false);
    } catch (e) {
      if (kDebugMode) {
        print('Error during logout: $e');
      }
    }
  }

  //Reset Password Using Link
  Future<void> resetPasswordAndNotify(
      String email, BuildContext context) async {
    try {
      // Directly query Firestore to check if the email exists
      QuerySnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('User')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (userSnapshot.docs.isEmpty) {
        // If no document is found, inform the user
        CustomSnackBar.show(
          context,
          'No user found for that email in Firestore.',
        );
        return;
      }

      // Since the user exists in Firestore, we can proceed to send a reset email
      // Send password reset email
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      // Update the Firestore document to indicate a password reset was requested
      DocumentReference userDocRef = userSnapshot.docs.first.reference;

      await userDocRef.update({
        'passwordResetRequested': true,
        'lastPasswordResetRequest': FieldValue.serverTimestamp(),
      });

      CustomSnackBar.show(
        context,
        'Password reset email sent! Check your inbox.',
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'invalid-email') {
        errorMessage = "Invalid Email Provided by You";
      } else if (e.code == 'user-not-found') {
        errorMessage = "No User Found for that Email";
      } else {
        errorMessage = "An unknown error occurred";
      }
      CustomSnackBar.show(
        context,
        errorMessage,
      );
    } catch (e) {
      CustomSnackBar.show(
        context,
        'An error occurred while processing your request. Please try again',
      );
    }
  }
}
