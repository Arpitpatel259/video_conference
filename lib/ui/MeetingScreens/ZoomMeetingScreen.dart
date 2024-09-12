import 'package:flutter/material.dart';

class ZoomMeetingScreen extends StatefulWidget {
  @override
  _ZoomMeetingScreenState createState() => _ZoomMeetingScreenState();
}

class _ZoomMeetingScreenState extends State<ZoomMeetingScreen> {
  bool isMuted = false;
  bool isVideoOff = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 4,
        centerTitle: false,
        backgroundColor: const Color(0xff3a57e8),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        title: const Text(
          "Meeting",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontStyle: FontStyle.normal,
            fontSize: 20,
            color: Color(0xffffffff),
          ),
        ),
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Video Grid
          GridView.builder(
            itemCount: 4, // number of participants
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // number of columns
            ),
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    'Participant ${index + 1}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              );
            },
          ),
          // Bottom Controls
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Mute/Unmute Button
                  IconButton(
                    icon: Icon(
                      isMuted ? Icons.mic_off : Icons.mic,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        isMuted = !isMuted;
                      });
                    },
                  ),
                  // Video On/Off Button
                  IconButton(
                    icon: Icon(
                      isVideoOff ? Icons.videocam_off : Icons.videocam,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        isVideoOff = !isVideoOff;
                      });
                    },
                  ),
                  // Screen Share Button
                  IconButton(
                    icon: const Icon(
                      Icons.screen_share,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      // Implement screen share functionality
                    },
                  ),
                  // Chat Button
                  IconButton(
                    icon: const Icon(
                      Icons.chat,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      // Implement chat functionality
                    },
                  ),
                  // Participants Button
                  IconButton(
                    icon: const Icon(
                      Icons.people,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      // Show participants list
                    },
                  ),
                  // End Call Button
                  IconButton(
                    icon: const Icon(
                      Icons.call_end,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      // End the call
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
