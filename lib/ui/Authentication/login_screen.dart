import 'package:flutter/material.dart';
import 'package:video_conference/ui/Authentication/register_screen.dart';
import 'package:video_conference/validation.dart';

import '../Services/Functions.dart';
import 'forgot_password.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isObscure = true;
  final _loginFormKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/logos/createAccountbackground.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Align(
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  _headerText("Sign In", 40, const Color(0xff3a57e8)),
                  _headerText("Welcome back! Let's get you signed in.", 20,
                      const Color(0xff818181)),
                  _loginCredential(),
                  _forgotPasswordLink(context),
                  _actionButtons(context),
                  _headerText("Or Continue with", 16, const Color(0xff9e9e9e)),
                  _googleSignInButton(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _headerText(String text, double fontSize, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
            fontWeight: FontWeight.bold, fontSize: fontSize, color: color),
      ),
    );
  }

  Widget _forgotPasswordLink(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const ForgotPassword())),
        child: _headerText("Forgot Password?", 16, const Color(0xff9e9e9e)),
      ),
    );
  }

  Widget _loginCredential() {
    return Form(
      key: _loginFormKey,
      child: Column(
        children: [
          _inputField(emailController, "Email", false, (value) {
            if (value == null || value.isEmpty) return 'Please Enter Email';
            if (!value.isValidEmail) return 'Please Enter Valid Email Id';
            return null;
          }),
          _inputField(passwordController, "Password", _isObscure, (value) {
            if (value == null || value.isEmpty) return 'Please Enter Password';
            if (!value.isValidPassword) return 'Please Enter Valid Password';
            return null;
          }, suffixIcon: _passwordVisibilityToggle()),
        ],
      ),
    );
  }

  Widget _inputField(TextEditingController controller, String label,
      bool obscureText, String? Function(String?) validator,
      {Widget? suffixIcon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        validator: validator,
        style: const TextStyle(
          color: Colors.black,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Color(0xff9e9e9e), width: 1)),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }

  Widget _passwordVisibilityToggle() {
    return IconButton(
      icon: Icon(_isObscure ? Icons.visibility : Icons.visibility_off,
          color: Theme.of(context).colorScheme.primary),
      onPressed: () => setState(() => _isObscure = !_isObscure),
    );
  }

  Widget _actionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 15, 0, 16),
      child: Row(
        children: [
          _actionButton(
              "Sign Up",
              const Color(0xffffffff),
              Colors.black,
              () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const RegisterScreen()))),
          const SizedBox(width: 16),
          _actionButton("Login", const Color(0xff3a57e8), Colors.white,
              () async {
            if (_loginFormKey.currentState!.validate()) {
              setState(() {
                _isLoading = true; // Set loading state
              });
              try {
                await Functions().userLogin(
                    emailController.text, passwordController.text, context);
              } finally {
                setState(() {
                  _isLoading = false; // Dismiss loading state
                });
              }
            }
          }),
        ],
      ),
    );
  }

  Widget _actionButton(
      String text, Color color, Color? colors, VoidCallback onPressed) {
    return Expanded(
      child: MaterialButton(
        onPressed: onPressed,
        color: color,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xff9e9e9e), width: 1)),
        padding: const EdgeInsets.all(16),
        child: Text(
          text,
          style: TextStyle(
              fontSize: 16, color: colors, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _googleSignInButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Functions().signInWithGoogle(context),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xffffffff),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xff9e9e9e), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logos/google.png', height: 25, width: 25),
            const Padding(
              padding: EdgeInsets.only(left: 16),
              child: Text(
                "Google",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
