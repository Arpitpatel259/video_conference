import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_conference/ui/Pages/dash_board.dart';
import 'package:video_conference/widget/common_snackbar.dart';

import '../Services/Functions.dart';

class ChatUserList extends StatefulWidget {
  const ChatUserList({super.key});

  @override
  State<ChatUserList> createState() => _ChatUserListState();
}

class _ChatUserListState extends State<ChatUserList> {
  final ValueNotifier<bool> _search = ValueNotifier(false);
  var searchController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> filteredUsers = [];
  bool isLoading = true;
  String? name, userId;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final pref = await SharedPreferences.getInstance();
    name = pref.getString("name");
    userId = pref.getString("userId");
    fetchAllUsers();
  }

  String _chatRoomId(String user1, String user2) {
    return (user1[0].toLowerCase().codeUnits[0] >
            user2.toLowerCase().codeUnits[0])
        ? "$user1$user2"
        : "$user2$user1";
  }

  Future<void> fetchAllUsers() async {
    try {
      final snapshot = await _firestore.collection('User').get();
      final allUsers = snapshot.docs.map((doc) => doc.data()).toList();

      setState(() {
        users = allUsers;
        filteredUsers = allUsers;
        isLoading = false;
      });
    } catch (_) {
      setState(() => isLoading = false);
    }
  }

  void onSearch(String value) {
    setState(() {
      filteredUsers = users
          .where((user) =>
              user['name'].toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

  /*Future<void> addUserToChatList(String userIdToAdd) async {
    final userDoc = _firestore
        .collection('User')
        .doc(userId!)
        .collection('ChatUserList')
        .doc(userIdToAdd);

    final docSnapshot = await userDoc.get();

    if (docSnapshot.exists) {
      CustomSnackBar.show(context, "Already Added!");
    } else {
      final batch = _firestore.batch();

      _updateChatList(userId!, userIdToAdd, batch);
      _updateChatList(userIdToAdd, userId!, batch);

      await batch.commit();
      CustomSnackBar.show(context, "Added to Chat!");

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const DashBoard(initialIndex: 1),
        ),
        (Route<dynamic> route) => false,
      );
    }
  }

  void _updateChatList(String ownerId, String userId, WriteBatch batch) {
    final chatUserData = {'userId': userId};
    final ref = _firestore
        .collection('User')
        .doc(ownerId)
        .collection('ChatUserList')
        .doc(userId);
    batch.set(ref, chatUserData);
  }*/

  Future<void> addUserToChatList(
      String userIdToAdd, String chatRoomName) async {
    final userDoc = _firestore
        .collection('User')
        .doc(userId!)
        .collection('ChatUserList')
        .doc(userIdToAdd);

    final docSnapshot = await userDoc.get();

    if (docSnapshot.exists) {
      CustomSnackBar.show(context, "Already Added!");
    } else {
      final batch = _firestore.batch();

      // Generate a unique callId
      String callId = await _generateUniqueCallId();

      // Update the chat list with the new user
      _updateChatList(userId!, userIdToAdd, batch);
      _updateChatList(userIdToAdd, userId!, batch);

      // Update the callId in the specified chat room
      _updateChatRoomWithCallId(chatRoomName, callId, batch);

      await batch.commit();
      CustomSnackBar.show(context, "Added to Chat!");

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const DashBoard(initialIndex: 1),
        ),
        (Route<dynamic> route) => false,
      );
    }
  }

  Future<String> _generateUniqueCallId() async {
    int callId;
    bool isUnique = false;

    callId = 0;

    while (!isUnique) {
      callId = Random().nextInt(9000) +
          1000; // Generates a 4-digit number (1000 to 9999)

      // Check if this callId already exists in the Firestore
      final callIdQuery = await _firestore
          .collection('chatroom')
          .where('callId', isEqualTo: callId.toString())
          .get();

      if (callIdQuery.docs.isEmpty) {
        isUnique = true; // Unique callId found
      }
    }

    return callId.toString();
  }

  void _updateChatRoomWithCallId(
      String chatRoomName, String callId, WriteBatch batch) {
    final chatRoomDoc = _firestore.collection('chatroom').doc(chatRoomName);

    batch.set(
        chatRoomDoc,
        {
          'callId': callId,
        },
        SetOptions(merge: true));
  }

  void _updateChatList(String ownerId, String userId, WriteBatch batch) {
    final chatUserData = {'userId': userId};
    final ref = _firestore
        .collection('User')
        .doc(ownerId)
        .collection('ChatUserList')
        .doc(userId);
    batch.set(ref, chatUserData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          ValueListenableBuilder(
            valueListenable: _search,
            builder: (context, value, child) {
              return _buildSearchBar(value ? 60 : 0, value);
            },
          ),
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildUserList(),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text("Add Person", style: TextStyle(color: Colors.white)),
      backgroundColor: const Color(0xff3a57e8),
      iconTheme: const IconThemeData(color: Colors.white),
      actions: [
        IconButton(
          icon: ValueListenableBuilder(
            valueListenable: _search,
            builder: (context, value, child) {
              return Icon(value ? Icons.close : Icons.search,
                  color: Colors.white);
            },
          ),
          onPressed: () {
            if (_search.value) {
              searchController.clear();
              FocusScope.of(context).unfocus();
              _search.value = false;
              filteredUsers = List.from(users);
            } else {
              _search.value = true;
            }
          },
        ),
      ],
    );
  }

  Widget _buildUserList() {
    if (filteredUsers.isEmpty) {
      return const Center(
        child: Text(
          'No users found',
          style: TextStyle(fontSize: 18, color: Colors.black54),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        itemCount: filteredUsers.length,
        itemBuilder: (context, index) {
          final user = filteredUsers[index];
          return Column(
            children: [
              const SizedBox(height: 5),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 10.0),
                leading: Container(
                  height: 50,
                  width: 50,
                  clipBehavior: Clip.antiAlias,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: Functions().buildProfileImage(user['imgUrl']),
                ),
                title: Text(user['name'],
                    style: const TextStyle(
                        fontSize: 17,
                        color: Colors.black,
                        fontWeight: FontWeight.w500)),
                trailing: IconButton(
                  icon: const Icon(Icons.add, color: Colors.green, size: 25),
                  onPressed: () async {
                    final roomId = _chatRoomId(name!, user['name']);
                    await addUserToChatList(user['id'], roomId);
                  },
                ),
              ),
              const Divider(
                color: Color(0x4d9e9e9e),
                height: 16,
                thickness: 1,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchBar(double? height, bool isVisible) {
    return AnimatedOpacity(
      opacity: isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: isVisible ? height : 0,
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextFormField(
            controller: searchController,
            maxLines: 1,
            onChanged: (value) {
              onSearch(value);
            },
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xff000000),
            ),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
                borderSide:
                    const BorderSide(color: Color(0xff9e9e9e), width: 1),
              ),
              labelText: "Search",
              labelStyle: const TextStyle(
                fontSize: 16,
                color: Color(0xff9e9e9e),
              ),
              filled: true,
              fillColor: Colors.white,
              isDense: true,
            ),
          ),
        ),
      ),
    );
  }
}
