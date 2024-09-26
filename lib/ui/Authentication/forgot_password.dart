import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:video_conference/validation.dart';

import '../../widget/common_snackbar.dart';
import '../../widget/common_textfield.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _resetFormKey = GlobalKey<FormState>();
  final emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/logos/createAccountbackground.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Back button
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(top: 40, left: 16),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
          // Forgot password form and text
          Center(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipOval(
                    child: Image.asset(
                      'assets/logos/launch_icon.png',
                      height: 80,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _headerText("Forgot Password?", 32, const Color(0xff3a57e8)),
                  const SizedBox(height: 8),
                  _subHeaderText(
                      "Don't worry! we will help you to recover your password!",
                      18,
                      Colors.grey),
                  const SizedBox(height: 32),
                  _buildForm(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerText(String text, double fontSize, Color color) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
          fontWeight: FontWeight.bold, fontSize: fontSize, color: color),
    );
  }

  Widget _subHeaderText(String text, double fontSize, Color color) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: fontSize,
        color: color,
      ),
    );
  }

  Widget _buildForm() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEmailHeader(),
          const SizedBox(height: 20),
          Form(
            key: _resetFormKey,
            child: CommonTextfield(
              controller: emailController,
              label: "Email",
              obscureText: false,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please Enter Email';
                if (!isValidEmail(value)) return 'Please Enter Valid Email Id';
                return null;
              },
              suffixIcon: IconButton(
                icon: const Icon(Icons.arrow_forward, color: Color(0xff3a57e8)),
                onPressed: () async {
                  if (_resetFormKey.currentState!.validate()) {
                    String email = emailController.text.trim();
                    try {
                      await FirebaseAuth.instance
                          .sendPasswordResetEmail(email: email);
                      CustomSnackBar.show(
                        context,
                        'Password reset email sent. Please check your inbox',
                      );
                      emailController.clear();
                    } catch (e) {
                      CustomSnackBar.show(
                        context,
                        'Error occurred ${e.toString()}',
                      );
                    }
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Row _buildEmailHeader() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          "SEND YOUR EMAIL",
          textAlign: TextAlign.start,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: Color(0xff3a57e8),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 8),
          child: Icon(Icons.mail, color: Color(0xff717171), size: 16),
        ),
      ],
    );
  }
}
