import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_conference/ui/MeetingScreens/meeting_screen.dart';

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
    _refreshUserData();
    _search.addListener(() {
      setState(() {});
    });
  }

  Future<void> _refreshUserData() async {
    pref = await SharedPreferences.getInstance();

    setState(() {
      userId = pref?.getString("userId") ?? "";
      name = pref?.getString("name") ?? "";
      email = pref?.getString("email") ?? "";
      profileImageUrl = pref?.getString("imgUrl") ?? "";
    });
  }

  String capitalizeFirstLetter(String str) {
    if (str.isEmpty) return str;
    return str[0].toUpperCase() + str.substring(1).toLowerCase();
  }

  Stream<List<Map<String, dynamic>>> _fetchMeetings(String query) {
    final firestore = FirebaseFirestore.instance.collection('meetings');

    if (query.isEmpty) {
      return firestore.snapshots().map(
            (snapshot) => snapshot.docs.map((doc) => doc.data()).toList(),
          );
    } else {
      return firestore
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThanOrEqualTo: query + '\uf8ff')
          .snapshots()
          .map(
            (snapshot) => snapshot.docs.map((doc) => doc.data()).toList(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 2,
        backgroundColor: const Color(0xff3a57e8),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Hi, ${capitalizeFirstLetter(name ?? "")}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: Row(
                children: [
                  _buildActionButton(Icons.add, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MeetingScreen(),
                      ),
                    );
                  }),
                  const SizedBox(width: 10),
                  ValueListenableBuilder(
                    valueListenable: isSearched,
                    builder: (context, value, child) {
                      return _buildActionButton(
                          value ? Icons.close : Icons.search, () {
                        if (value) {
                          _search.clear();
                          FocusScope.of(context).unfocus();
                          isSearched.value = false;
                        } else {
                          isSearched.value = true;
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ValueListenableBuilder(
              valueListenable: isSearched,
              builder: (context, value, child) {
                return animatedContainer(value ? 70 : 0, value);
              },
            ),
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _fetchMeetings(_search.text),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No meetings available.'));
                  }

                  final meetings = snapshot.data!;
                  return Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ListView.builder(
                      itemCount: meetings.length,
                      itemBuilder: (context, index) {
                        final meeting = meetings[index];
                        return MeetingCard(
                          title: meeting['title'] ?? 'No Title',
                          time: meeting['time'] ?? 'No Time',
                          date: meeting['date'] ?? 'No Date',
                          description:
                              meeting['description'] ?? 'No Description',
                          participants: '${meeting['participants'].length}+',
                          meetingId: meeting['id'] ?? '',
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget animatedContainer(double? height, bool isVisible) {
    return AnimatedOpacity(
      opacity: isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: height,
        width: double.infinity,
        curve: Curves.fastOutSlowIn,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: TextFormField(
            controller: _search,
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 16,
              color: Color(0xff000000),
            ),
            decoration: InputDecoration(
              hintText: "Search",
              hintStyle: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 16,
                color: Color(0xff9e9e9e),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide:
                    const BorderSide(color: Color(0xff9e9e9e), width: 1),
              ),
              filled: true,
              fillColor: Colors.white,
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, VoidCallback onPressed) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: Colors.black,
          size: 20,
        ),
        onPressed: onPressed,
      ),
    );
  }
}

class MeetingCard extends StatelessWidget {
  final String title;
  final String time;
  final String date;
  final String description;
  final String participants;
  final String meetingId;

  const MeetingCard({
    required this.title,
    required this.time,
    required this.date,
    required this.participants,
    required this.description,
    required this.meetingId,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MeetingCarousel(
              images: [],
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDateAndTime(date, time),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            _buildParticipants(participants),
          ],
        ),
      ),
    );
  }

  Widget _buildDateAndTime(String date, String time) {
    return Row(
      children: [
        Text(
          date,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          time,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildParticipants(String participants) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$participants participants',
          style: const TextStyle(color: Colors.black54),
        ),
        const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
      ],
    );
  }
}

class MeetingCarousel extends StatefulWidget {
  final List<String> images;

  const MeetingCarousel({Key? key, required this.images}) : super(key: key);

  @override
  _MeetingCarouselState createState() => _MeetingCarouselState();
}

class _MeetingCarouselState extends State<MeetingCarousel> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: widget.images.length, // Dynamic number of images
          options: CarouselOptions(
            height: 200.0,
            enlargeCenterPage: true,
            autoPlay: true,
            viewportFraction: 1,
            aspectRatio: 16 / 9,
            autoPlayInterval: const Duration(seconds: 3),
            onPageChanged: (index, reason) {
              setState(() {
                _current = index; // Only updates the carousel state
              });
            },
          ),
          itemBuilder: (BuildContext context, int index, int realIdx) {
            return SizedBox(
              width: MediaQuery.of(context).size.width,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.network(
                  widget.images.isNotEmpty
                      ? widget.images[index].toString()
                      : "https://picsum.photos/200", // Example image URL
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                        Icons.error); // Error handling for failed images
                  },
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.images.length, (index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _current = index; // Tap to change image manually
                });
              },
              child: Container(
                width: 8.0,
                height: 8.0,
                margin:
                    const EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _current == index
                      ? Colors.blueAccent
                      : Colors.grey, // Dot color based on current index
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
