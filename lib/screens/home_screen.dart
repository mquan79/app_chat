import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project_final_mobile/screens.dart';
import 'package:project_final_mobile/services/chat_service.dart';
import 'package:project_final_mobile/services/info_user_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ChatService _chatService = ChatService();
  final UserInfoService _userInfoService = UserInfoService();
  String? nameUser;

  StreamBuilder<Object> getNameById(String uid) {
    return StreamBuilder<QuerySnapshot>(
        stream: _userInfoService.getInfoUser(uid),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            if (userSnapshot.hasData && userSnapshot.data!.docs.isNotEmpty) {
              final userData =
                  userSnapshot.data!.docs.first.data() as Map<String, dynamic>;
              final userName = userData['name'];
              nameUser = userName;
              return Text(
                userName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              );
            } else {
              return const Text('Không có dữ liệu');
            }
          }
        });
  }

  StreamBuilder<Object> getImageById(String uid) {
    return StreamBuilder<QuerySnapshot>(
        stream: _userInfoService.getInfoUser(uid),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            if (userSnapshot.hasData && userSnapshot.data!.docs.isNotEmpty) {
              final userData =
                  userSnapshot.data!.docs.first.data() as Map<String, dynamic>;
              final userImage = userData['urlImage'];
              return ClipRRect(
                borderRadius: BorderRadius.circular(90),
                child: Image.network(
                  userImage,
                  fit: BoxFit.fitWidth,
                  width: 50,
                  height: 50,
                ),
              );
            } else {
              return Text('Không có dữ liệu');
            }
          }
        });
  }

  bool isUrl(String message) {
    return message.startsWith('https://firebasestorage');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang chủ'),
      ),
      body: _buildUserList(),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Error');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final users = snapshot.data!.docs;

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index].data() as Map<String, dynamic>;
            final userEmail = user['email'] as String;
            final userUid = user['uid'] as String;

            if (_auth.currentUser!.email != userEmail) {
              return StreamBuilder<QuerySnapshot>(
                stream:
                    _chatService.getMessage(_auth.currentUser!.uid, userUid),
                builder: (context, messageSnapshot) {
                  if (messageSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return ListTile(
                      title: getNameById(userUid),
                      subtitle:
                          const Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (messageSnapshot.hasError) {
                    return ListTile(
                      title: getNameById(userUid),
                      subtitle: const Text("Error loading messages"),
                    );
                  }

                  final messages = messageSnapshot.data!.docs;
                  if (messages.isNotEmpty) {
                    final lastMessage =
                        messages.last.data() as Map<String, dynamic>;
                    final messageText = lastMessage['message'] as String;
                    final userId = lastMessage['senderId'] as String;

                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.grey),
                          ),
                        ),
                        child: Row(
                          children: [
                            getImageById(userUid),
                            Expanded(
                              child: Container(
                                child: ListTile(
                                  title: getNameById(userUid),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      !isUrl(messageText)
                                          ? Text(
                                              userId == _auth.currentUser!.uid
                                                  ? 'Bạn: $messageText'
                                                  : messageText,
                                              overflow: TextOverflow.ellipsis,
                                            )
                                          : Text(
                                              userId == _auth.currentUser!.uid
                                                  ? 'Bạn: [Hình ảnh]'
                                                  : '[Hình ảnh]',
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                    ],
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
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.grey),
                          ),
                        ),
                        child: Row(
                          children: [
                            getImageById(userUid),
                            Expanded(
                              child: Container(
                                child: ListTile(
                                  title: getNameById(userUid),
                                  subtitle: const Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text("Bạn chưa nhắn tin với người này"),
                                    ],
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
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                },
              );
            } else {
              return Container();
            }
          },
        );
      },
    );
  }
}
