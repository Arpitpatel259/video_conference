import 'package:flutter/material.dart';
import 'package:video_conference/ui/Authentication/register_screen.dart';
import 'package:video_conference/ui/Services/Functions.dart';
import 'package:video_conference/validation.dart';

import '../../widget/common_textfield.dart';
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
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Light background color
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/logos/createAccountbackground.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
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
                _headerText("Welcome Back!", 32, const Color(0xff3a57e8)),
                const SizedBox(height: 8),
                _subHeaderText("Please login to continue.", 18, Colors.grey),
                const SizedBox(height: 32),
                _loginCredential(),
                const SizedBox(height: 24),
                _forgotPasswordLink(context),
                const SizedBox(height: 24),
                _actionButtons(context),
                const SizedBox(height: 32),
                _headerText("Or continue with", 16, const Color(0xff9e9e9e)),
                const SizedBox(height: 24),
                _socialSignInButtons(context),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
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

  Widget _forgotPasswordLink(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const ForgotPassword())),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            "Forgot Password?",
            style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _loginCredential() {
    return Form(
      key: _loginFormKey,
      child: Column(
        children: [
          CommonTextfield(
              controller: emailController,
              label: "Email",
              obscureText: false,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please Enter Email';
                if (!isValidEmail(value)) return 'Please Enter Valid Email Id';
                return null;
              }),
          const SizedBox(height: 16),
          CommonTextfield(
              controller: passwordController,
              label: "Password",
              obscureText: _isObscure,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please Enter Password';
                }
                if (!isValidPassword(value)) {
                  return 'Please Enter Valid Password';
                }
                return null;
              },
              suffixIcon: _passwordVisibilityToggle()),
        ],
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
    return Row(
      children: [
        Expanded(
          child: _actionButton(
              "Sign Up",
              Colors.white,
              const Color(0xff3a57e8),
              () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const RegisterScreen()))),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _actionButton("Login", const Color(0xff3a57e8), Colors.white,
              () async {
            if (_loginFormKey.currentState!.validate()) {
              setState(() {
                isLoading = true; // Set loading state
              });
              try {
                await Functions().userLogin(
                    emailController.text, passwordController.text, context);
              } finally {
                setState(() {
                  isLoading = false; // Dismiss loading state
                });
              }
            }
          }),
        ),
      ],
    );
  }

  Widget _actionButton(String text, Color backgroundColor, Color textColor,
      VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        text,
        style: TextStyle(
            fontSize: 16, color: textColor, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _socialSignInButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _socialButton('assets/logos/google.png', "Google", () {
          Functions().signInWithGoogle(context);
        }),
        /* const SizedBox(width: 16),
        _socialButton('assets/logos/apple.png', "Apple", () {
          // Implement Apple sign-in functionality here
        }),*/
      ],
    );
  }

  Widget _socialButton(String iconPath, String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xffe0e0e0), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              iconPath,
              height: 24,
              width: 24,
            ),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
