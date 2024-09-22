import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:video_conference/validation.dart';

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
      backgroundColor: Colors.white,
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
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 30),
                    _buildTitle(),
                    const SizedBox(height: 8),
                    _buildSubtitle(),
                    const SizedBox(height: 30),
                    _buildForm(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Text _buildTitle() {
    return const Text(
      "Forgot Password?",
      textAlign: TextAlign.start,
      style: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 40,
        color: Color(0xff3a57e8),
      ),
    );
  }

  Text _buildSubtitle() {
    return const Text(
      "Do not worry! We will help you recover your Password",
      textAlign: TextAlign.center,
      style: TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 20,
        color: Color(0xff818181),
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xfff2f2f2),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEmailHeader(),
          const SizedBox(height: 20),
          Form(
            key: _resetFormKey,
            child: TextFormField(
              controller: emailController,
              obscureText: false,
              textAlign: TextAlign.start,
              maxLines: 1,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please Enter Email';
                } else if (!value.isValidEmail) {
                  return 'Please Enter Valid Email Id';
                }
                return null;
              },
              decoration: _buildInputDecoration(),
              style: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 16,
                color: Color(0xff000000),
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

  InputDecoration _buildInputDecoration() {
    return InputDecoration(
      suffixIcon: IconButton(
        icon: const Icon(Icons.arrow_forward, color: Color(0xff3a57e8)),
        onPressed: () async {
          if (_resetFormKey.currentState!.validate()) {
            String email = emailController.text.trim();
            try {
              await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text(
                        'Password reset email sent. Please check your inbox.')),
              );
              emailController.clear();
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${e.toString()}')),
              );
            }
          }
        },
      ),
      labelText: "Email",
      labelStyle: const TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 16,
        color: Color(0xff9e9e9e),
      ),
      filled: true,
      fillColor: const Color(0x00f2f2f3),
      isDense: false,
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4.0),
        borderSide: const BorderSide(color: Color(0xff9e9e9e), width: 1),
      ),
    );
  }
}
