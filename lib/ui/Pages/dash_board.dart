import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_conference/ui/ChatModule/home_screen.dart';
import 'package:video_conference/ui/Pages/profile_setting_screen.dart';

import '../MeetingScreens/today_meeting.dart';
import '../Services/Functions.dart';

class DashBoard extends StatefulWidget {
  final int initialIndex;

  const DashBoard({super.key, required this.initialIndex});

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  SharedPreferences? pref;

  String? userId;
  String? profileImageUrl;
  String? name;
  String? email;

  int _currentIndex = 0;

  final List<Widget> _screens = [
    const TodayMeetingsScreen(),
    const HomeScreen(),
    const ProfileSettingScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    pref = await SharedPreferences.getInstance();

    setState(() {
      userId = pref?.getString("userId") ?? "";
      name = pref?.getString("name") ?? "N/A";
      email = pref?.getString("email") ?? "";
      profileImageUrl = pref?.getString("imgUrl") ?? "";
    });
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xff3a57e8),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey.shade400,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        elevation: 10,
        // Increased elevation for a shadow effect
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: [
          const BottomNavigationBarItem(
            label: 'Meetings', // Renamed for clarity
            icon: Icon(
                Icons.event_outlined), // Changed icon for better representation
          ),
          const BottomNavigationBarItem(
            label: 'Chat',
            icon: Icon(Icons.chat_outlined),
          ),
          BottomNavigationBarItem(
            label: 'Profile',
            icon: SizedBox(
              width: 30, // Increased size for a more balanced look
              height: 30,
              child: ClipOval(
                clipBehavior: Clip.hardEdge,
                child: Functions().buildProfileImage(profileImageUrl),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
