import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_conference/ui/Services/Functions.dart';

import 'meeting_screen.dart';

class TodayMeetingsScreen extends StatefulWidget {
  const TodayMeetingsScreen({super.key});

  @override
  State<TodayMeetingsScreen> createState() => _TodayMeetingsScreenState();
}

class _TodayMeetingsScreenState extends State<TodayMeetingsScreen> {
  SharedPreferences? pref;

  String? userId;
  String? profileImageUrl;
  String? name;
  String? email;

  @override
  void initState() {
    super.initState();
    _refreshBlogs();
  }

  String capitalizeFirstLetter(String str) {
    if (str.isEmpty) return str; // Check for empty string
    return str[0].toUpperCase() + str.substring(1).toLowerCase();
  }

  Future<void> _refreshBlogs() async {
    pref = await SharedPreferences.getInstance();

    setState(() {
      userId = pref?.getString("userId") ?? "";
      name = pref?.getString("name") ?? "";
      email = pref?.getString("email") ?? "";
      profileImageUrl = pref?.getString("imgUrl") ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Hi, ${capitalizeFirstLetter(name ?? "")}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  ClipOval(
                    clipBehavior: Clip.hardEdge,
                    child: SizedBox(
                      width: 50,
                      height: 50,
                      child: Functions().buildProfileImage(profileImageUrl),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Title Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Today\nMeetings',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    // Padding around the icon
                    decoration: BoxDecoration(
                      color: Colors.grey[200], // Background color
                      shape: BoxShape.circle, // Make the background circular
                    ),
                    child: const Icon(
                      Icons.search_outlined,
                      color: Colors.black, // Icon color
                      size: 24.0, // Icon size
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Meeting Cards
              Expanded(
                child: ListView(
                  children: const [
                    MeetingCard(
                      title: 'Invomoon Project Brief',
                      time: 'Starts in 7h 25m',
                      date: '17 Jul 2023, 21:00 PM - 21:30 PM',
                      participants: '3+',
                    ),
                    MeetingCard(
                      title: 'Hatypo Studio Weekly Meeting',
                      time: 'Starts in 7h 25m',
                      date: '17 Jul 2023, 21:00 PM - 21:30 PM',
                      participants: '5+',
                    ),
                    MeetingCard(
                      title: 'Marketing Team Discussion',
                      time: 'Starts in 7h 25m',
                      date: '17 Jul 2023, 21:00 PM - 21:30 PM',
                      participants: '2+',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MeetingScreen(),
              ));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class MeetingCard extends StatelessWidget {
  final String title;
  final String time;
  final String date;
  final String participants;

  const MeetingCard({
    required this.title,
    required this.time,
    required this.date,
    required this.participants,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 3,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Meeting Details
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                time,
                style: const TextStyle(
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                date,
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const CircleAvatar(
                    radius: 10,
                    backgroundColor: Colors.blueAccent,
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(participants),
                ],
              ),
            ],
          ),

          // Action Button
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.deepPurple,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.play_arrow,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
