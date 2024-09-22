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
        elevation: 2,
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: [
          const BottomNavigationBarItem(
            label: 'Home', // Home tab
            icon: Icon(Icons.home_outlined),
          ),
          const BottomNavigationBarItem(
            label: 'Chat', // Chat tab
            icon: Icon(Icons.chat_outlined),
          ),
          BottomNavigationBarItem(
            label: 'Profile', // Settings tab
            icon: SizedBox(
              width: 24, // Define a specific size for the icon
              height: 24,
              child: ClipOval(
                clipBehavior: Clip.hardEdge,
                child: Functions().buildProfileImage(profileImageUrl),
              ),
            ),
          )
        ],
      ),
    );
  }
}
