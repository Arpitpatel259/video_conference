import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

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
                  // GestureDetector to handle tap on the profile picture
                  GestureDetector(
                    onTap: () {
                      // Navigate to ProfileViewPage when the profile picture is tapped
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProfileViewPage(userMap: widget.userMap),
                        ),
                      );
                    },
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(profileImage),
                      radius: 18,
                    ),
                  ),
                  const SizedBox(width: 10), // Spacing between image and text
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.userMap['name'],
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      Text(
                        status,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.white),
                      ),
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
              // Call functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () {
              // Video call functionality
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
                      style: const TextStyle(
                        color: Colors.black,
                      ),
                      decoration: const InputDecoration(
                        hintText: "Type a message",
                        hintStyle: TextStyle(
                          color: Colors.black,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 10.0,
                          horizontal: 20.0,
                        ),
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
            padding: const EdgeInsets.all(0),
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
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
            child: Text(
              timeString,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
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
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: isCurrentUser ? Colors.blue : Colors.grey.shade200,
      ),
      child: Text(
        message,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isCurrentUser ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  // Build image message widget
  Widget _buildImageMessage(
      String imageUrl, bool isCurrentUser, String timeString) {
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ShowImage(imageUrl: imageUrl),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          height: MediaQuery.of(context).size.height / 2.5,
          width: MediaQuery.of(context).size.width / 1.5,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(10),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                          child: Icon(Icons.error, color: Colors.red));
                    },
                  )
                : const Center(child: CircularProgressIndicator()),
          ),
        ),
      ),
    );
  }
}

class ShowImage extends StatelessWidget {
  final String imageUrl;

  const ShowImage({required this.imageUrl, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(),
      body: Center(
        child: Image.network(imageUrl, fit: BoxFit.contain),
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
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: const Color(0xff3a57e8),
        elevation: 0,
      ),
      backgroundColor: Colors.white, // Set background to white
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // Profile Image with elevation
            Center(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.4),
                      blurRadius: 10,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  backgroundImage: NetworkImage(
                      userMap['imgUrl'] ?? 'default_profile_image_url'),
                  radius: 60, // Larger for profile view
                ),
              ),
            ),
            const SizedBox(height: 20),
            // User Name
            Text(
              userMap['name'] ?? 'Name not available',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            // Status
            Text(
              userMap['status'] ?? 'Offline',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 30),
            // Divider for better layout structure
            const Divider(thickness: 1, color: Colors.grey),
            const SizedBox(height: 20),
            // Call and Video Call Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // Call functionality
                  },
                  icon: const Icon(Icons.phone, size: 24),
                  label: const Text('Call'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff3a57e8),
                    // Call button color
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
                    // Video call functionality
                  },
                  icon: const Icon(Icons.videocam, size: 24),
                  label: const Text('Video Call'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff3a57e8),
                    // Video call button color
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
}
