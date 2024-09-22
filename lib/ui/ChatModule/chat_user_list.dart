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
  final ValueNotifier<bool> _search = ValueNotifier(false);
  var searchController = TextEditingController();
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

  List<Map<String, dynamic>> _originalUserDataList = [];
  List<Map<String, dynamic>> _filteredUserDataList = [];

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
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          ValueListenableBuilder(
            valueListenable: _search,
            builder: (context, value, child) {
              return _buildSearchBar(value ? 70 : 0, value);
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
      automaticallyImplyLeading: true,
      // Removes the back arrow
      actions: [
        Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            shape: BoxShape.circle,
          ),
          child: ValueListenableBuilder(
            valueListenable: _search,
            builder: (context, value, child) {
              return InkWell(
                onTap: () {
                  if (value) {
                    searchController.clear();
                    FocusScope.of(context).unfocus();
                    _search.value = false;
                    _filteredUserDataList = List.from(
                        _originalUserDataList); // Reset the filtered list
                    setState(() {});
                  } else {
                    _search.value = true;
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
                style: const TextStyle(
                    fontSize: 17,
                    color: Colors.black,
                    fontWeight: FontWeight.w500)),
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

  Widget _buildSearchBar(double? height, bool isVisible) {
    return AnimatedOpacity(
      opacity: isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: isVisible ? height : 0,
        width: double.infinity,
        curve: Curves.fastOutSlowIn,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: TextFormField(
            controller: searchController,
            obscureText: false,
            textAlign: TextAlign.start,
            maxLines: 1,
            onChanged: (value) {
              onSearch(value);
            },
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
