import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_conference/ui/ChatModule/chat_room.dart';
import 'package:video_conference/ui/ChatModule/chat_user_list.dart';

import '../Services/Functions.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late SharedPreferences _prefs;
  String? _userId, _name;
  List<Map<String, dynamic>> _userDataList = [];
  final ValueNotifier<bool> _isSearched = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() => isLoading = true);
    _prefs = await SharedPreferences.getInstance();
    _userId = _prefs.getString("userId");
    _name = _prefs.getString("name");

    if (_userId != null) {
      await _fetchChatUsers(_userId!);
    }
    setState(() => isLoading = false);
  }

  Future<void> _fetchChatUsers(String ownerId) async {
    try {
      final chatListSnapshot = await _firestore
          .collection('User')
          .doc(ownerId)
          .collection('ChatUserList')
          .get();
      final userIds =
          chatListSnapshot.docs.map((doc) => doc['userId'] as String).toList();

      final userDataList = await Future.wait(userIds.map((userId) async {
        final userSnapshot =
            await _firestore.collection('User').doc(userId).get();
        return userSnapshot.data() as Map<String, dynamic>;
      }));

      setState(() {
        _userDataList = userDataList;
      });
    } catch (e) {
      print("Error fetching chat users: $e");
    }
  }

  String _chatRoomId(String user1, String user2) {
    return (user1[0].toLowerCase().codeUnits[0] >
            user2.toLowerCase().codeUnits[0])
        ? "$user1$user2"
        : "$user2$user1";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 4,
        backgroundColor: const Color(0xff3a57e8),
        title: const Text("Chats", style: TextStyle(color: Colors.white)),
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: _isSearched,
            builder: (context, isSearched, _) {
              return IconButton(
                icon: Icon(isSearched ? Icons.close : Icons.search,
                    color: Colors.white),
                onPressed: () => _isSearched.value = !isSearched,
              );
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          ValueListenableBuilder<bool>(
            valueListenable: _isSearched,
            builder: (context, isSearched, _) => _buildSearchBar(isSearched),
          ),
          Expanded(
            child: isLoading
                ? Center(child: const CircularProgressIndicator())
                : _userDataList.isNotEmpty
                    ? ListView.builder(
                        itemCount: _userDataList.length,
                        itemBuilder: (context, index) {
                          final user = _userDataList[index];
                          if (user['name'] == _name)
                            return const SizedBox.shrink();

                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            leading: Container(
                              height: 60,
                              width: 60,
                              clipBehavior: Clip.antiAlias,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child:
                                  Functions().buildProfileImage(user['imgUrl']),
                            ),
                            title: Text(user['name'] ?? 'Unknown',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            subtitle: Text(user['email'] ?? 'No email'),
                            trailing: const Icon(Icons.arrow_forward_ios,
                                color: Colors.grey),
                            onTap: () {
                              final roomId = _chatRoomId(
                                  _auth.currentUser!.displayName!,
                                  user['name']);
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ChatRoom(
                                      chatRoomId: roomId, userMap: user),
                                ),
                              );
                            },
                          );
                        },
                      )
                    : const Center(
                        child: Text(
                          "No Chats Found",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ChatUserList()),
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isSearched) {
    return AnimatedContainer(
      duration: const Duration(seconds: 1),
      height: isSearched ? 50 : 0,
      width: double.infinity,
      curve: Curves.fastOutSlowIn,
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: isSearched
          ? TextFormField(
              controller: _searchController,
              onChanged: (value) => _filterUsers(value),
              decoration: const InputDecoration(
                labelText: "Search",
                border: OutlineInputBorder(),
              ),
            )
          : null,
    );
  }

  void _filterUsers(String query) {
    setState(() {
      _userDataList = _userDataList
          .where((user) => (user['name'] as String)
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    });
  }
}
