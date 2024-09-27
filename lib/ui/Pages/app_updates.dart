import 'package:flutter/material.dart';

import '../../widget/common_function.dart';

class UpdateAppScreen extends StatefulWidget {
  const UpdateAppScreen({super.key});

  @override
  State<UpdateAppScreen> createState() => _UpdateAppScreenState();
}

class _UpdateAppScreenState extends State<UpdateAppScreen> {
  int _progress = 0;
  String _statusMessage = "Checking for updates...";
  bool isCheck = false;

  // Function to simulate loading from 0 to 100
  Future<void> _simulateLoading() async {
    for (int i = 0; i <= 100; i++) {
      await Future.delayed(const Duration(milliseconds: 30), () {
        setState(() {
          _progress = i;
        });
      });
    }
    // Once loading is complete, set the status message
    setState(() {
      _statusMessage = "No update available";
      isCheck = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  spreadRadius: 5,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Stack(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Close Button
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.black54),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),

                    // App Logo
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/logos/launch_icon.png',
                          // Replace with your logo asset
                          width: 80,
                          height: 80,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Title
                    const Text(
                      'Update your application to the latest version',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Description
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text(
                        'A brand new version of the FoodFuels app is available in the App Store. Please update your app to use all of our amazing features.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    isCheck
                        ? Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Update Progress: $_progress%',
                                  style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 20),
                                LinearProgressIndicator(
                                  value: _progress / 100,
                                  backgroundColor: Colors.grey[200],
                                  color: Colors.blue,
                                  minHeight: 10,
                                ),
                                const SizedBox(height: 40),
                                Text(
                                  _statusMessage,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),

                    // Update Now Button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isCheck = true;
                          });
                          _simulateLoading();
                          print("Update Now Pressed");
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: const Color(0xFF007BFF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'Check For Update',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: FutureBuilder<String>(
                        future: getAppVersion(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator(); // Show a loading indicator
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            return Text(
                              snapshot.data ?? 'Unknown version',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
