import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_conference/ui/ChatModule/chat_room.dart';
import 'package:video_conference/ui/ChatModule/chat_user_list.dart';
import 'package:video_conference/ui/Services/Functions.dart';

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
  List<Map<String, dynamic>> _originalUserDataList = [];
  List<Map<String, dynamic>> _filteredUserDataList = [];
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
        _originalUserDataList = userDataList;
        _filteredUserDataList = List.from(userDataList);
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
        elevation: 2,
        backgroundColor: const Color(0xff3a57e8),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
        ),
        title: const Text("Chats", style: TextStyle(color: Colors.white)),
        actions: [
          Container(
            padding: const EdgeInsets.all(6.0),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: ValueListenableBuilder(
              valueListenable: _isSearched,
              builder: (context, value, child) {
                return InkWell(
                  onTap: () {
                    if (value) {
                      _searchController.clear();
                      FocusScope.of(context).unfocus();
                      _isSearched.value = false;
                      _filteredUserDataList = List.from(_originalUserDataList);
                      setState(() {});
                    } else {
                      _isSearched.value = true;
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
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          ValueListenableBuilder(
            valueListenable: _isSearched,
            builder: (context, value, child) {
              return _buildSearchBar(value ? 60 : 0, value);
            },
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredUserDataList.isNotEmpty
                    ? ListView.builder(
                        itemCount: _filteredUserDataList.length,
                        itemBuilder: (context, index) {
                          final user = _filteredUserDataList[index];
                          if (user['name'] == _name) {
                            return const SizedBox.shrink();
                          }

                          return Column(
                            children: [
                              ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12.0, vertical: 4.0),
                                leading: Container(
                                  height: 48,
                                  width: 48,
                                  clipBehavior: Clip.antiAlias,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                  ),
                                  child: Functions()
                                      .buildProfileImage(user['imgUrl']),
                                ),
                                title: Text(user['name'] ?? 'Unknown',
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold)),
                                subtitle: Text(
                                  user['email'] ?? 'No email',
                                  style: const TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                                onTap: () {
                                  final roomId = _chatRoomId(
                                      _auth.currentUser!.displayName ??
                                          user['name'],
                                      user['name']);
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ChatRoom(
                                          chatRoomId: roomId, userMap: user),
                                    ),
                                  );
                                },
                              ),
                              const Divider(
                                color: Color(0x4d9e9e9e),
                                height: 16,
                                thickness: 1,
                              ),
                            ],
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
          padding: const EdgeInsets.all(8.0),
          child: TextFormField(
            controller: _searchController,
            maxLines: 1,
            onChanged: (value) {
              _filterUsers(value);
            },
            style: const TextStyle(
              fontWeight: FontWeight.w400,
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
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xff9e9e9e),
              ),
              filled: true,
              fillColor: Colors.white,
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            ),
          ),
        ),
      ),
    );
  }

  void _filterUsers(String query) {
    setState(() {
      _filteredUserDataList = _originalUserDataList
          .where((user) => (user['name'] as String)
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    });
  }
}
