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
      setState(
          () {}); // This will trigger a rebuild when the search text changes
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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MeetingScreen(),
                        ),
                      );
                    },
                    child: const Icon(
                      Icons.add,
                      color: Colors.black,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  child: ValueListenableBuilder(
                    valueListenable: isSearched,
                    builder: (context, value, child) {
                      return InkWell(
                        onTap: () {
                          if (value) {
                            _search.clear();
                            FocusScope.of(context).unfocus();
                            isSearched.value = false;
                            setState(() {});
                          } else {
                            isSearched.value = true;
                          }
                        },
                        child: Icon(
                          value ? Icons.close : Icons.search,
                          color: Colors.black,
                          size: 24,
                        ),
                      );
                    },
                  ),
                ),
              ],
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
                return animatedContainer(value ? 70 : 0, value ? true : false);
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
                          meetingId: meeting['id'] ?? '', // Pass the meeting ID
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
            obscureText: false,
            textAlign: TextAlign.start,
            maxLines: 1,
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 16,
              color: Color(0xff000000),
            ),
            decoration: InputDecoration(
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
                borderSide:
                    const BorderSide(color: Color(0xff9e9e9e), width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
                borderSide:
                    const BorderSide(color: Color(0xff9e9e9e), width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
                borderSide:
                    const BorderSide(color: Color(0xff9e9e9e), width: 1),
              ),
              labelText: "Search",
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xff9e9e9e),
              ),
              filled: true,
              fillColor: Colors.white,
              isDense: false,
            ),
          ),
        ),
      ),
    );
  }
}

/// setState
/// getx
/// bloc -> blocs, model, repository, authrepo, apiservice, event, state ->
/// provider

class MeetingCard extends StatelessWidget {
  final String title;
  final String time;
  final String date;
  final String description;
  final String participants;
  final String meetingId; // Added meetingId field

  const MeetingCard({
    required this.title,
    required this.time,
    required this.date,
    required this.participants,
    required this.description,
    required this.meetingId, // Updated constructor
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                MeetingDetailsPage(meetingId: meetingId), // Pass meetingId
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.8),
              spreadRadius: 3,
              blurRadius: 7,
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
                Text(
                  date,
                  style: const TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  time,
                  style: const TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              overflow: TextOverflow.fade,
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
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Stack(
                  clipBehavior: Clip.none,
                  children: <Widget>[
                    Positioned(
                      left: 20,
                      child: CircleAvatar(
                        radius: 15,
                        backgroundImage:
                            NetworkImage('https://picsum.photos/200'),
                      ),
                    ),
                    Positioned(
                      left: 10,
                      child: CircleAvatar(
                        radius: 15,
                        backgroundImage:
                            NetworkImage('https://picsum.photos/200'),
                      ),
                    ),
                    CircleAvatar(
                      radius: 15,
                      backgroundImage:
                          NetworkImage('https://picsum.photos/200'),
                    ),
                  ],
                ),
                const SizedBox(width: 25),
                Text(
                  participants,
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MeetingDetailsPage extends StatefulWidget {
  final String meetingId;

  const MeetingDetailsPage({Key? key, required this.meetingId})
      : super(key: key);

  @override
  _MeetingDetailsPageState createState() => _MeetingDetailsPageState();
}

class _MeetingDetailsPageState extends State<MeetingDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 2,
        backgroundColor: const Color(0xff3a57e8),
        iconTheme: const IconThemeData(color: Colors.white),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
        ),
        title: const Text(
          'Meeting Details',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('meetings')
            .doc(widget.meetingId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Meeting not found.'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final images = List<String>.from(
              data['images'] ?? []); // Convert to List<String>

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  MeetingCarousel(images: images), // Pass the converted list
                  Text(
                    data['title'],
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Row for Date and Time with spaceBetween
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Date: ${data['date']}',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'Time: ${data['time']}',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    data['description'],
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
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
