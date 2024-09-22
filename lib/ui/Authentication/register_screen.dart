import 'package:flutter/material.dart';
import 'package:video_conference/validation.dart';

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
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/logos/createAccountbackground.png'),
            // Add your background image here
            fit: BoxFit.cover, // This makes the image cover the whole screen
          ),
        ),
        child: Align(
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  const SizedBox(height: 40),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
                    child: Text(
                      "Sign Up",
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.clip,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.normal,
                        fontSize: 40,
                        color: Color(0xff3a57e8),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(30, 8, 30, 30),
                    child: Text(
                      "Join us today! Create your account and start exploring.",
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.clip,
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.normal,
                        fontSize: 20,
                        color: Color(0xff818181),
                      ),
                    ),
                  ),
                  Form(
                    key: _registerFormKey,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                          child: TextFormField(
                            controller: nameController,
                            obscureText: false,
                            textAlign: TextAlign.start,
                            maxLines: 1,
                            style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.normal,
                              fontSize: 16,
                              color: Color(0xff000000),
                            ),
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return 'Please Enter Your Name';
                              }
                              if (!val.isValidName) {
                                return 'Please Enter Valid Name';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4.0),
                                borderSide: const BorderSide(
                                    color: Color(0xff9e9e9e), width: 1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4.0),
                                borderSide: const BorderSide(
                                    color: Color(0xff9e9e9e), width: 1),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4.0),
                                borderSide: const BorderSide(
                                    color: Color(0xff9e9e9e), width: 1),
                              ),
                              labelText: "Name",
                              labelStyle: const TextStyle(
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.normal,
                                fontSize: 16,
                                color: Color(0xff9e9e9e),
                              ),
                              filled: true,
                              fillColor: const Color(0x00ffffff),
                              isDense: false,
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 12),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                          child: TextFormField(
                            controller: emailController,
                            obscureText: false,
                            textAlign: TextAlign.start,
                            maxLines: 1,
                            style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.normal,
                              fontSize: 16,
                              color: Color(0xff000000),
                            ),
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return 'Please Enter Email';
                              }
                              if (!val.isValidEmail) {
                                return 'Please Enter Valid Email Id';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4.0),
                                borderSide: const BorderSide(
                                    color: Color(0xff9e9e9e), width: 1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4.0),
                                borderSide: const BorderSide(
                                    color: Color(0xff9e9e9e), width: 1),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4.0),
                                borderSide: const BorderSide(
                                    color: Color(0xff9e9e9e), width: 1),
                              ),
                              labelText: "Email",
                              labelStyle: const TextStyle(
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.normal,
                                fontSize: 16,
                                color: Color(0xff9e9e9e),
                              ),
                              filled: true,
                              fillColor: const Color(0x00ffffff),
                              isDense: false,
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 12),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                          child: TextFormField(
                            controller: passwordController,
                            obscureText: _isObscure,
                            textAlign: TextAlign.start,
                            maxLines: 1,
                            style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.normal,
                              fontSize: 16,
                              color: Color(0xff000000),
                            ),
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return 'Please Enter Password';
                              }
                              if (!val.isValidPassword) {
                                return 'Please Enter Valid Password';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              suffixIcon: IconButton(
                                icon: Icon(
                                    _isObscure
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color:
                                        Theme.of(context).colorScheme.primary),
                                onPressed: () =>
                                    setState(() => _isObscure = !_isObscure),
                              ),
                              disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4.0),
                                borderSide: const BorderSide(
                                    color: Color(0xff9e9e9e), width: 1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4.0),
                                borderSide: const BorderSide(
                                    color: Color(0xff9e9e9e), width: 1),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4.0),
                                borderSide: const BorderSide(
                                    color: Color(0xff9e9e9e), width: 1),
                              ),
                              labelText: "Password",
                              labelStyle: const TextStyle(
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.normal,
                                fontSize: 16,
                                color: Color(0xff9e9e9e),
                              ),
                              filled: true,
                              fillColor: const Color(0x00ffffff),
                              isDense: false,
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 12),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 20, 0, 30),
                          child: TextFormField(
                            controller: cPasswordController,
                            obscureText: _isObscure1,
                            textAlign: TextAlign.start,
                            maxLines: 1,
                            style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.normal,
                              fontSize: 16,
                              color: Color(0xff000000),
                            ),
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
                            decoration: InputDecoration(
                              suffixIcon: IconButton(
                                icon: Icon(
                                    _isObscure1
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color:
                                        Theme.of(context).colorScheme.primary),
                                onPressed: () =>
                                    setState(() => _isObscure1 = !_isObscure1),
                              ),
                              disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4.0),
                                borderSide: const BorderSide(
                                    color: Color(0xff9e9e9e), width: 1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4.0),
                                borderSide: const BorderSide(
                                    color: Color(0xff9e9e9e), width: 1),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4.0),
                                borderSide: const BorderSide(
                                    color: Color(0xff9e9e9e), width: 1),
                              ),
                              labelText: "Confirm Password",
                              labelStyle: const TextStyle(
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.normal,
                                fontSize: 16,
                                color: Color(0xff9e9e9e),
                              ),
                              filled: true,
                              fillColor: const Color(0x00ffffff),
                              isDense: false,
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        flex: 1,
                        child: MaterialButton(
                          onPressed: () async {
                            if (_registerFormKey.currentState!.validate()) {
                              // Store local references to avoid using context across async gaps
                              final navigator = Navigator.of(context);
                              final scaffoldMessenger =
                                  ScaffoldMessenger.of(context);

                              setState(() {
                                email = emailController.text;
                                password = passwordController.text;
                                confirmPassword = cPasswordController.text;
                              });

                              if (nameController.text.isNotEmpty &&
                                  emailController.text.isNotEmpty &&
                                  passwordController.text.isNotEmpty &&
                                  cPasswordController.text.isNotEmpty) {
                                if (passwordController.text ==
                                    cPasswordController.text) {
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) => const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );

                                  try {
                                    await Functions().registerUser(
                                        nameController.text,
                                        email,
                                        password,
                                        confirmPassword);

                                    // Check if the widget is still mounted before using context
                                    if (mounted) {
                                      scaffoldMessenger.showSnackBar(
                                        SnackBar(
                                          content: const Text(
                                              "Registration Successful"),
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                          behavior: SnackBarBehavior.floating,
                                          action: SnackBarAction(
                                            label: 'Dismiss',
                                            onPressed: () {},
                                          ),
                                        ),
                                      );

                                      navigator.pushReplacement(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const LoginScreen()),
                                      );
                                    }
                                  } catch (e) {
                                    // Handle registration failure
                                    if (mounted) {
                                      scaffoldMessenger.showSnackBar(
                                        SnackBar(
                                          content: const Text(
                                              "Registration Unsuccessful. Please Try Again!"),
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                          behavior: SnackBarBehavior.floating,
                                          action: SnackBarAction(
                                            label: 'Dismiss',
                                            onPressed: () {},
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                } else {
                                  // Handle password mismatch
                                  scaffoldMessenger.showSnackBar(
                                    SnackBar(
                                      content:
                                          const Text("Passwords do not match!"),
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      behavior: SnackBarBehavior.floating,
                                      action: SnackBarAction(
                                        label: 'Dismiss',
                                        onPressed: () {},
                                      ),
                                    ),
                                  );
                                }
                              } else {
                                // Handle missing fields
                                scaffoldMessenger.showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                        "Please fill all the fields!"),
                                    backgroundColor:
                                        Theme.of(context).colorScheme.secondary,
                                    behavior: SnackBarBehavior.floating,
                                    action: SnackBarAction(
                                      label: 'Dismiss',
                                      onPressed: () {},
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                          color: const Color(0xff3a57e8),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          padding: const EdgeInsets.all(16),
                          textColor: const Color(0xffffffff),
                          height: 40,
                          minWidth: 140,
                          child: const Text(
                            "Sign Up",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.normal,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                      Expanded(
                        flex: 1,
                        child: MaterialButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginScreen()),
                            );
                          },
                          color: const Color(0xffffffff),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            side: const BorderSide(
                                color: Color(0xff9e9e9e), width: 1),
                          ),
                          padding: const EdgeInsets.all(16),
                          textColor: const Color(0xff000000),
                          height: 40,
                          minWidth: 140,
                          child: const Text(
                            "Login",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.normal,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
