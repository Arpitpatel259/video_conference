import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_conference/ui/Pages/dash_board.dart';

import '../Services/Functions.dart';

class ChatUserList extends StatefulWidget {
  const ChatUserList({super.key});

  @override
  State<ChatUserList> createState() => _ChatUserListState();
}

class _ChatUserListState extends State<ChatUserList> {
  final _search = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

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

  Future<void> fetchAllUsers() async {
    try {
      final snapshot = await _firestore.collection('User').get();
      final allUsers = snapshot.docs
          .map((doc) => doc.data())
          .where((data) => data['isAdded'] == false)
          .toList();

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

  Future<void> addUserToChatList(String userIdToAdd) async {
    final batch = _firestore.batch();

    _updateChatList(userId!, userIdToAdd, batch);
    _updateChatList(userIdToAdd, userId!, batch);

    await batch.commit();
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
      appBar: _buildAppBar(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildUserList(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text("Add Person", style: TextStyle(color: Colors.white)),
      backgroundColor: const Color(0xff3a57e8),
      iconTheme: const IconThemeData(color: Colors.white),
      automaticallyImplyLeading: false,
      // Removes the back arrow
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: () => showSearchDialog(context),
        ),
      ],
    );
  }

  Widget _buildUserList() {
    return ListView.builder(
      itemCount: filteredUsers.length,
      itemBuilder: (context, index) {
        final user = filteredUsers[index];
        if (user['name'] == name) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: ListTile(
            leading: Container(
              height: 60,
              width: 60,
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: Functions().buildProfileImage(user['imgUrl']),
            ),
            title: Text(user['name'],
                style:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
            trailing: IconButton(
              icon: const Icon(Icons.add, color: Colors.green, size: 30),
              onPressed: () async {
                await addUserToChatList(user['id']);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${user['name']} added!')),
                );

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DashBoard(
                        initialIndex: 1), // Set to HomeScreen tab (index 1)
                  ),
                  (Route<dynamic> route) => false, // Remove all previous routes
                );
              },
            ),
          ),
        );
      },
    );
  }

  void showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Users'),
        content: TextFormField(
          controller: _search,
          onChanged: onSearch,
          decoration: const InputDecoration(labelText: 'Enter name'),
        ),
      ),
    );
  }
}
