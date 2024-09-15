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

  final TextEditingController _search = TextEditingController();
  ValueNotifier<bool> isSearched = ValueNotifier(false);

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
      backgroundColor: Colors.black12,
      appBar: AppBar(
        elevation: 4,
        backgroundColor: const Color(0xff3a57e8),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Hi, ${capitalizeFirstLetter(name ?? "")}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
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
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        // Padding around the icon
                        decoration: BoxDecoration(
                          color: Colors.grey[200], // Background color
                          shape:
                              BoxShape.circle, // Make the background circular
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MeetingScreen(),
                                ));
                          },
                          child: const Icon(
                            Icons.add,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        // Padding around the icon
                        decoration: BoxDecoration(
                          color: Colors.grey[200], // Background color
                          shape:
                              BoxShape.circle, // Make the background circular
                        ),
                        child: ValueListenableBuilder(
                          valueListenable: isSearched,
                          builder: (context, value, child) {
                            return InkWell(
                              onTap: () {
                                isSearched.value = !isSearched.value;
                              },
                              child: Icon(
                                value ? Icons.close : Icons.search,
                                color: Colors.black,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              ValueListenableBuilder(
                valueListenable: isSearched,
                builder: (context, value, child) {
                  return animatedContainer(value ? 70 : 0);
                },
              ),
              // Meeting Cards
              Expanded(
                child: ListView(
                  children: const [
                    MeetingCard(
                      title: 'Involution Project Brief',
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
                    MeetingCard(
                      title: 'Involution Project Brief',
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
    );
  }

  Widget animatedContainer(double? height) {
    return AnimatedContainer(
      duration: const Duration(seconds: 1),
      height: height,
      width: double.infinity,
      curve: Curves.fastOutSlowIn,
      decoration: BoxDecoration(
        color: Colors.grey[200], // Background color
        shape: BoxShape.rectangle, // Make the background circular
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: TextFormField(
          controller: _search,
          obscureText: false,
          textAlign: TextAlign.start,
          maxLines: 1,
          style: const TextStyle(
            fontWeight: FontWeight.w400,
            fontStyle: FontStyle.normal,
            fontSize: 16,
            color: Color(0xff000000),
          ),
          decoration: InputDecoration(
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.0),
              borderSide: const BorderSide(color: Color(0xff9e9e9e), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.0),
              borderSide: const BorderSide(color: Color(0xff9e9e9e), width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.0),
              borderSide: const BorderSide(color: Color(0xff9e9e9e), width: 1),
            ),
            labelText: "Search",
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold, // BOLD HERE
              fontStyle: FontStyle.normal,
              fontSize: 16,
              color: Color(0xff9e9e9e),
            ),
            filled: true,
            fillColor: Colors.white,
            isDense: false,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          ),
        ),
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
