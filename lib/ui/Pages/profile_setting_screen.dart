import 'dart:convert';
import 'dart:io';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_conference/ui/Authentication/forgot_password.dart';
import 'package:video_conference/ui/Pages/about_us.dart';
import 'package:video_conference/ui/Pages/app_updates.dart';
import 'package:video_conference/ui/Pages/upgrade_plans.dart';
import 'package:video_conference/widget/custom_tile.dart';

import '../Services/Functions.dart';

class ProfileSettingScreen extends StatefulWidget {
  const ProfileSettingScreen({super.key});

  @override
  State<ProfileSettingScreen> createState() => _ProfileSettingScreenState();
}

class _ProfileSettingScreenState extends State<ProfileSettingScreen> {
  late SharedPreferences pref;
  bool isLoading = false;

  String? userId;
  String? profileImageUrl;
  String? name;
  String? email;
  File? _mediaFile;

  @override
  void initState() {
    super.initState();
    _getUserDataFromLocal();
  }

  Future<void> _getUserDataFromLocal() async {
    setState(() {
      isLoading = true;
    });
    pref = await SharedPreferences.getInstance();

    userId = pref.getString("userId") ?? "";
    name = pref.getString("name") ?? "";
    email = pref.getString("email") ?? "";
    profileImageUrl = pref.getString("imgUrl") ?? "";

    setState(() {
      isLoading = false;
    });
  }

  Future<File?> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    return pickedFile != null ? File(pickedFile.path) : null;
  }

  Future<void> _uploadProfileImage(File? image) async {
    String userId = pref.getString("userId") ?? "";

    if (userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID is not set.')),
      );
      return;
    }

    if (image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No image file selected.')),
      );
      return;
    }

    try {
      String base64Image = await _convertImageToBase64(image);

      await FirebaseFirestore.instance.collection('User').doc(userId).update({
        'imgUrl': base64Image,
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('imgUrl', base64Image);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile image uploaded successfully')),
      );

      setState(() {
        profileImageUrl = base64Image;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload profile image')),
      );
    }
  }

  Future<String> _convertImageToBase64(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    return base64Encode(bytes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffffffff),
      appBar: AppBar(
        elevation: 2,
        backgroundColor: const Color(0xff3a57e8),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
        ),
        title: const Text(
          "My Profile",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontStyle: FontStyle.normal,
            fontSize: 20,
            color: Color(0xffffffff),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () async {
                      File? imageFile = await _pickImage();
                      if (imageFile != null) {
                        setState(() {
                          _mediaFile = imageFile;
                        });
                        await _uploadProfileImage(_mediaFile);
                      }
                    },
                    child: AvatarGlow(
                      endRadius: 70.0,
                      glowColor: Colors.blue,
                      duration: const Duration(milliseconds: 2000),
                      repeat: true,
                      showTwoGlows: true,
                      child: ClipOval(
                        clipBehavior: Clip.hardEdge,
                        child: SizedBox(
                          width: 60,
                          height: 60,
                          child: Functions().buildProfileImage(profileImageUrl),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name ?? "",
                            textAlign: TextAlign.start,
                            maxLines: 1,
                            overflow: TextOverflow.clip,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontStyle: FontStyle.normal,
                              fontSize: 18,
                              color: Color(0xff000000),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 4, 0, 0),
                            child: Text(
                              email ?? "",
                              textAlign: TextAlign.start,
                              maxLines: 1,
                              overflow: TextOverflow.clip,
                              style: const TextStyle(
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.normal,
                                fontSize: 14,
                                color: Color(0xff9e9e9e),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(
                color: Color(0x4d9e9e9e),
                height: 16,
                thickness: 1,
              ),
              CustomTile(
                icon: Icons.lock,
                title: "Change Password",
                iconBackgroundColor: Colors.blue.shade50,
                iconColor: Colors.blue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ForgotPassword(),
                    ),
                  );
                },
              ),
              const Divider(
                color: Color(0x4d9e9e9e),
                height: 16,
                thickness: 1,
              ),
              CustomTile(
                icon: Icons.info_outline,
                title: "About Us",
                iconBackgroundColor: Colors.blue.shade50,
                iconColor: Colors.blue,
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AboutUsPage(),
                      ));
                },
              ),
              const Divider(
                color: Color(0x4d9e9e9e),
                height: 16,
                thickness: 1,
              ),
              CustomTile(
                icon: Icons.upgrade,
                title: "Upgrade Plans",
                iconBackgroundColor: Colors.blue.shade50,
                iconColor: Colors.blue,
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UpgradePlans(),
                      ));
                },
              ),
              const Divider(
                color: Color(0x4d9e9e9e),
                height: 16,
                thickness: 1,
              ),
              CustomTile(
                icon: Icons.update,
                title: "App Updates",
                iconBackgroundColor: Colors.blue.shade50,
                iconColor: Colors.blue,
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UpdateAppScreen(),
                      ));
                },
              ),
              const Divider(
                color: Color(0x4d9e9e9e),
                height: 16,
                thickness: 1,
              ),
              CustomTile(
                icon: Icons.power_settings_new,
                title: "Logout",
                iconBackgroundColor: Colors.red.shade50,
                iconColor: Colors.red,
                onTap: () {
                  showConfirmationDialog(
                      context: context,
                      title: "Logout?",
                      onPressed: () {
                        Functions().logout(context);
                      });
                },
              ),
              const Divider(
                color: Color(0x4d9e9e9e),
                height: 16,
                thickness: 1,
              ),
              CustomTile(
                icon: Icons.update,
                title: "Delete Your Account",
                iconBackgroundColor: Colors.red.shade50,
                iconColor: Colors.red,
                onTap: () {
                  showConfirmationDialog(
                      context: context,
                      title: "Delete Your Account?",
                      onPressed: () {
                        Functions().logout(context);
                      });
                },
              ),
              const Divider(
                color: Color(0x4d9e9e9e),
                height: 16,
                thickness: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void showConfirmationDialog(
    {required BuildContext context,
    required String title,
    required VoidCallback onPressed}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text('Are you sure you want to $title'),
        backgroundColor: Colors.white,
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _actionButton("No", Colors.grey, Colors.white, () {
                Navigator.pop(context);
              }),
              const SizedBox(width: 10),
              _actionButton(
                  "Yes", const Color(0xff3a57e8), Colors.white, onPressed),
            ],
          ),
        ],
      );
    },
  );
}

Widget _actionButton(String text, Color backgroundColor, Color textColor,
    VoidCallback onPressed) {
  return SizedBox(
    width: 75,
    height: 50,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}
