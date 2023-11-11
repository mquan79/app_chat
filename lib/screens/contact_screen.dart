import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project_final_mobile/screens.dart';
import 'package:project_final_mobile/services/info_user_service.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({Key? key}) : super(key: key);

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserInfoService _userInfoService = UserInfoService();
  String searchQuery = '';

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        onChanged: (value) {
          setState(() {
            searchQuery = value;
          });
        },
        decoration: const InputDecoration(
          hintText: 'Tìm kiếm',
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh bạ'),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('Error');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final users = snapshot.data!.docs;
                final filteredUsers = users.where((user) {
                  final userEmail = user['email'] as String;
                  return userEmail.contains(searchQuery) &&
                      _auth.currentUser!.email != userEmail;
                }).toList();

                return ListView.builder(
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user =
                        filteredUsers[index].data() as Map<String, dynamic>;
                    final userEmail = user['email'] as String;
                    final userUid = user['uid'] as String;

                    return ListTile(
                      title: StreamBuilder<QuerySnapshot>(
                        stream: _userInfoService.getInfoUser(userUid),
                        builder: (context, userSnapshot) {
                          if (userSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else {
                            if (userSnapshot.hasData &&
                                userSnapshot.data!.docs.isNotEmpty) {
                              final userData = userSnapshot.data!.docs.first
                                  .data() as Map<String, dynamic>;
                              final userName = userData['name'] as String;
                              return Text(
                                userName,
                              );
                            } else {
                              return const Text('Không có dữ liệu');
                            }
                          }
                        },
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(
                              userID: userUid,
                              userEmail: userEmail,
                            ),
                          ),
                        );
                      },
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
