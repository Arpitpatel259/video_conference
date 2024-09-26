import 'package:flutter/material.dart';

import '../../widget/common_snackbar.dart';
import '../../widget/common_textfield.dart';
import '../Services/Functions.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _isObscure = true;
  bool _isObscure1 = true;
  final _registerFormKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final cPasswordController = TextEditingController();
  final passwordController = TextEditingController();

  var email = "", password = "", confirmPassword = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffffffff),
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

          Center(
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
                  _headerText("Sign Up!", 32, const Color(0xff3a57e8)),
                  const SizedBox(height: 8),
                  _subHeaderText(
                      "Join us today! Create your account and start exploring.",
                      18,
                      Colors.grey),
                  const SizedBox(height: 32),
                  Form(
                    key: _registerFormKey,
                    child: Column(
                      children: [
                        CommonTextfield(
                            controller: nameController,
                            label: "Name",
                            obscureText: false,
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Please Enter Your Name';
                              if (!value.isValidEmail)
                                return 'Please Enter Valid Name';
                              return null;
                            }),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                          child: CommonTextfield(
                              controller: emailController,
                              label: "Email",
                              obscureText: false,
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return 'Please Enter Email';
                                if (!value.isValidEmail)
                                  return 'Please Enter Valid Email Id';
                                return null;
                              }),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                          child: CommonTextfield(
                            controller: passwordController,
                            label: "Password",
                            obscureText: _isObscure,
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Please Enter Password';
                              ;
                              if (!value.isValidEmail)
                                return 'Please Enter Valid Password';
                              return null;
                            },
                            suffixIcon: IconButton(
                              icon: Icon(
                                  _isObscure
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Theme.of(context).colorScheme.primary),
                              onPressed: () =>
                                  setState(() => _isObscure = !_isObscure),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 20, 0, 30),
                          child: CommonTextfield(
                            controller: cPasswordController,
                            label: "Confirm Password",
                            obscureText: _isObscure1,
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return 'Please Enter Confirm Password';
                              }
                              if (!val.isValidPassword) {
                                return 'Please Enter Valid Confirm Password';
                              }
                              if (val != passwordController.text) {
                                return 'Password Do Not Match!';
                              }
                              return null;
                            },
                            suffixIcon: IconButton(
                              icon: Icon(
                                  _isObscure1
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Theme.of(context).colorScheme.primary),
                              onPressed: () =>
                                  setState(() => _isObscure1 = !_isObscure1),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _actionButtons(context),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _actionButton("Login", Colors.white, const Color(0xff3a57e8),
              () async {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          }),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _actionButton("Sign Up", const Color(0xff3a57e8), Colors.white,
              () async {
            if (_registerFormKey.currentState!.validate()) {
              // Store local references to avoid using context across async gaps
              final navigator = Navigator.of(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);

              setState(() {
                email = emailController.text;
                password = passwordController.text;
                confirmPassword = cPasswordController.text;
              });

              if (nameController.text.isNotEmpty &&
                  emailController.text.isNotEmpty &&
                  passwordController.text.isNotEmpty &&
                  cPasswordController.text.isNotEmpty) {
                if (passwordController.text == cPasswordController.text) {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );

                  try {
                    await Functions().registerUser(
                        nameController.text, email, password, confirmPassword);

                    // Check if the widget is still mounted before using context
                    if (mounted) {
                      CustomSnackBar.show(
                        context,
                        'Registration Successful!',
                      );

                      navigator.pushReplacement(
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()),
                      );
                    }
                  } catch (e) {
                    // Handle registration failure
                    if (mounted) {
                      CustomSnackBar.show(
                        context,
                        'Register Unsuccessful. Please try again!',
                      );
                    }
                  }
                } else {
                  // Handle password mismatch
                  CustomSnackBar.show(
                    context,
                    'Password Not Match',
                  );
                }
              } else {
                // Handle missing fields
                CustomSnackBar.show(
                  context,
                  'Please fill up all details!',
                );
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
}
