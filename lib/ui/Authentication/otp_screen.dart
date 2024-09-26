import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../MainPage.dart';

class OtpVerificationScreen extends StatefulWidget {
  final User user;

  const OtpVerificationScreen({Key? key, required this.user}) : super(key: key);

  @override
  _OtpVerificationScreenState createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  bool isVerified = false;

  @override
  void initState() {
    super.initState();
    checkEmailVerified();
  }

  // Check if the user's email is verified
  Future<void> checkEmailVerified() async {
    await widget.user.reload(); // Reload the user state
    if (widget.user.emailVerified) {
      setState(() {
        isVerified = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email successfully verified!")),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainPage()),
        // Navigate to your dashboard
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Email not verified yet. Please check your inbox.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Email OTP Verification")),
      body: Center(
        child: isVerified
            ? const Text("Your email is verified!")
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("We have sent an OTP to your email."),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      await checkEmailVerified();
                    },
                    child: const Text("I have verified"),
                  ),
                ],
              ),
      ),
    );
  }
}
