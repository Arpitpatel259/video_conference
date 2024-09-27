import 'dart:io';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:video_conference/ui/ZegoCloud/zego_audio_call.dart';

import '../Services/Functions.dart';
import '../ZegoCloud/zego_video_call.dart';

class ChatRoom extends StatefulWidget {
  final Map<String, dynamic> userMap;
  final String chatRoomId;

  const ChatRoom({super.key, required this.chatRoomId, required this.userMap});

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ScrollController _scrollController = ScrollController();
  File? _imageFile;

  // Fetch image from gallery
  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
      await _uploadImage();
    }
  }

  @override
  void initState() {
    _initializeData();
    super.initState();
  }

  bool isLoading = false;
  late SharedPreferences _prefs;
  String? _userId, _name;

  Future<void> _initializeData() async {
    setState(() => isLoading = true);
    _prefs = await SharedPreferences.getInstance();
    _userId = _prefs.getString("userId");
    _name = _prefs.getString("name");

    setState(() => isLoading = false);
  }

  // Upload image to Firestore
  Future<void> _uploadImage() async {
    if (_imageFile == null) return;
    final fileName = Uuid().v1();
    final imageRef =
        FirebaseStorage.instance.ref().child('images/$fileName.jpg');

    try {
      await _firestore
          .collection('chatroom')
          .doc(widget.chatRoomId)
          .collection('chats')
          .doc(fileName)
          .set({
        "sendby": _auth.currentUser!.displayName,
        "message": "",
        "type": "img",
        "time": FieldValue.serverTimestamp(),
      });
      final uploadTask = imageRef.putFile(_imageFile!);
      final imageUrl = await (await uploadTask).ref.getDownloadURL();

      await _firestore
          .collection('chatroom')
          .doc(widget.chatRoomId)
          .collection('chats')
          .doc(fileName)
          .update({
        "message": imageUrl,
      });
    } catch (error) {
      await _firestore
          .collection('chatroom')
          .doc(widget.chatRoomId)
          .collection('chats')
          .doc(fileName)
          .delete();
    }
  }

  // Send text message
  Future<void> _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _firestore
          .collection('chatroom')
          .doc(widget.chatRoomId)
          .collection('chats')
          .add({
        "sendby": _auth.currentUser!.displayName,
        "message": _messageController.text,
        "type": "text",
        "time": FieldValue.serverTimestamp(),
      });
      _messageController.clear();
      _scrollToBottom();
    }
  }

  // Automatically scroll to the latest message
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  String _generateRoomId(String user1, String user2) {
    List<String> users = [user1, user2];
    users.sort();
    return users.join('_');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 4,
        backgroundColor: const Color(0xff3a57e8),
        iconTheme: const IconThemeData(color: Colors.white),
        title: StreamBuilder<DocumentSnapshot>(
          stream: _firestore
              .collection("User")
              .doc(widget.userMap['id'])
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final data = snapshot.data!.data() as Map<String, dynamic>?;
              final status = data?['status'] ?? 'Offline';
              final profileImage =
                  data?['imgUrl'] ?? 'default_profile_image_url';

              return Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProfileViewPage(userMap: widget.userMap),
                        ),
                      );
                    },
                    child: Container(
                      height: 50,
                      width: 50,
                      clipBehavior: Clip.antiAlias,
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      child: Functions().buildProfileImage(profileImage),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.userMap['name'],
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16)),
                      Text(status,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.white)),
                    ],
                  ),
                ],
              );
            }
            return Container();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ZegoAudioCall(
                    callId: _generateRoomId(
                        _name.toString(), widget.userMap['name']),
                    userId: _userId.toString(),
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ZegoVideoCall(
                    callId: widget.chatRoomId,
                    userId: widget.userMap['id'],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chatroom')
                  .doc(widget.chatRoomId)
                  .collection('chats')
                  .orderBy("time")
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final docs = snapshot.data!.docs;
                  WidgetsBinding.instance
                      .addPostFrameCallback((_) => _scrollToBottom());

                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final map = docs[index].data() as Map<String, dynamic>;
                      return _buildMessage(size, map);
                    },
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
          _buildMessageInput(size),
        ],
      ),
    );
  }

  // Build message input widget
  Widget _buildMessageInput(Size size) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25.0),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: const TextStyle(color: Colors.black),
                      decoration: const InputDecoration(
                        hintText: "Type a message",
                        hintStyle: TextStyle(color: Colors.black),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 20.0),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _getImage,
                    icon: const Icon(Icons.camera_alt, color: Colors.blue),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration:
                const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  // Build message widget
  Widget _buildMessage(Size size, Map<String, dynamic> map) {
    final isCurrentUser = map['sendby'] == _auth.currentUser!.displayName;
    final timestamp = map['time'] as Timestamp?;
    String timeString = "";

    if (timestamp != null) {
      final dateTime = timestamp.toDate();
      timeString = DateFormat('hh:mm a').format(dateTime);
    }

    final messageWidget = map['type'] == "text"
        ? _buildTextMessage(map['message'], isCurrentUser, timeString)
        : _buildImageMessage(map['message'], isCurrentUser, timeString);

    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          messageWidget,
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, top: 4),
            child: Text(timeString,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  // Build text message widget
  Widget _buildTextMessage(
      String message, bool isCurrentUser, String timeString) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
        color:
            isCurrentUser ? const Color(0xff3a57e8) : const Color(0xffe1ffc7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(message,
          style: TextStyle(color: isCurrentUser ? Colors.white : Colors.black)),
    );
  }

  // Build image message widget
  Widget _buildImageMessage(
      String imageUrl, bool isCurrentUser, String timeString) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
      decoration: BoxDecoration(
        color:
            isCurrentUser ? const Color(0xff3a57e8) : const Color(0xffe1ffc7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ShowImage(imageUrl: imageUrl),
                  ));
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(imageUrl,
                  fit: BoxFit.cover, height: 200, width: 150,
                  loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                    child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                (loadingProgress.expectedTotalBytes ?? 1)
                            : null));
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class ShowImage extends StatefulWidget {
  final String imageUrl;

  const ShowImage({required this.imageUrl, Key? key}) : super(key: key);

  @override
  _ShowImageState createState() => _ShowImageState();
}

class _ShowImageState extends State<ShowImage> {
  double _scale = 1.0;
  double _previousScale = 1.0;

  void _onDoubleTap() {
    setState(() {
      // Toggle zoom between 1.0 and 2.0
      _scale = _scale == 1.0 ? 2.0 : 1.0;
    });
  }

  void _onScaleStart(ScaleStartDetails details) {
    _previousScale = _scale;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      _scale = _previousScale * details.scale;
      // Constrain the scale to a reasonable range
      _scale = _scale.clamp(1.0, 3.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: GestureDetector(
          onDoubleTap: _onDoubleTap,
          onScaleStart: _onScaleStart,
          onScaleUpdate: _onScaleUpdate,
          child: SingleChildScrollView(
            child: Transform.scale(
              scale: _scale,
              child: SingleChildScrollView(
                child: Image.network(
                  widget.imageUrl,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ProfileViewPage extends StatelessWidget {
  final Map<String, dynamic> userMap;

  const ProfileViewPage({Key? key, required this.userMap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Dark background color
      appBar: AppBar(
        elevation: 2,
        backgroundColor: const Color(0xff3a57e8),
        iconTheme: const IconThemeData(color: Colors.white),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
        ),
        title: const Text(
          "Profile",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontStyle: FontStyle.normal,
            fontSize: 20,
            color: Color(0xffffffff),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // Profile Image with circular border
            AvatarGlow(
              endRadius: 70.0,
              glowColor: Colors.blue,
              duration: const Duration(milliseconds: 2000),
              repeat: true,
              showTwoGlows: true,
              child: ClipOval(
                clipBehavior: Clip.hardEdge,
                child: SizedBox(
                  width: 120,
                  height: 120,
                  child: Functions().buildProfileImage(userMap['imgUrl']),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // User Name
            Text(
              userMap['name'] ?? '',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            // About section
            _buildProfileDetail(
              value: userMap['email'] ?? 'At the movies',
            ),
            const SizedBox(height: 30),
            // Call and Video Call Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // Voice Call functionality
                  },
                  icon: const Icon(
                    Icons.phone,
                    size: 24,
                    color: Colors.blueAccent,
                  ),
                  label: const Text(
                    'Voice',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    // Video Call functionality
                  },
                  icon: const Icon(
                    Icons.videocam,
                    size: 24,
                    color: Colors.blueAccent,
                  ),
                  label: const Text(
                    'Video',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build profile detail without icon
  Widget _buildProfileDetail({
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
