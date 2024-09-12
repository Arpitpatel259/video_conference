import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';
  String userId = '';
  String userName = '';

  @override
  void initState() {
    _getUserDataForPass();
    super.initState();
  }

  Future<void> _getUserDataForPass() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    setState(() {
      userId = pref.getString("userId") ?? "";
      userName = pref.getString("name") ?? "";
    });
  }

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
          "Chats",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontStyle: FontStyle.normal,
            fontSize: 20,
            color: Color(0xffffffff),
          ),
        ),
      ),
      body: Column(
        children: [
          // Search bar container
          Container(
            color: Colors.grey[300],
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: "Search users...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      searchQuery = "";
                    });
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Expanded widget for ListView
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('User').snapshots(),
              builder: (ctx, AsyncSnapshot<QuerySnapshot> userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final userDocs = userSnapshot.data!.docs;

                // Filter the users based on search query
                final filteredUsers = userDocs.where((user) {
                  final userName = user['name'].toString().toLowerCase();
                  return userName.contains(searchQuery);
                }).toList();

                if (filteredUsers.isEmpty) {
                  return const Center(child: Text('No users found'));
                }

                return ListView.builder(
                  itemCount: filteredUsers.length,
                  itemBuilder: (ctx, index) {
                    final user = filteredUsers[index];
                    return Card(
                      color: Colors.white,
                      elevation: 9,
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.grey[200], // Background color
                            shape:
                                BoxShape.circle, // Make the background circular
                          ),
                          child: const Icon(
                            Icons.person_2_outlined,
                            color: Colors.black, // Icon color
                            size: 24.0, // Icon size
                          ),
                        ),
                        title: Text(user['name']),
                        trailing: InkWell(
                          onTap: () async {},
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: Colors.grey[200], // Background color
                              shape: BoxShape
                                  .circle, // Make the background circular
                            ),
                            child: const Icon(
                              Icons.arrow_forward_ios_outlined,
                              color: Colors.black, // Icon color
                              size: 24.0, // Icon size
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
