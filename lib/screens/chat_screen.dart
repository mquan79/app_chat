import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project_final_mobile/components/border_chat.dart';
import 'package:project_final_mobile/components/image_button.dart';
import 'package:project_final_mobile/components/text_field.dart';
import 'package:project_final_mobile/services/chat_service.dart';
import 'package:project_final_mobile/services/info_user_service.dart';

class ChatScreen extends StatefulWidget {
  final String userEmail;
  final String userID;
  const ChatScreen({
    super.key,
    required this.userEmail,
    required this.userID,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final ScrollController _scrollController = ScrollController();
  final UserInfoService _userInfoService = UserInfoService();
  String? nameUser;
  String? _selectedImagePath = '';

  void sendMessage() async {
    String messageText = _messageController.text.trim();
    String imagePath = _selectedImagePath?.trim() ?? '';

    if (messageText.isNotEmpty && imagePath.isNotEmpty) {
      await _chatService.sendMessage(widget.userID, messageText);
      await _chatService.sendMessage(widget.userID, imagePath);
      setState(() {
        _selectedImagePath = '';
        _messageController.clear();
      });
    } else if (messageText.isNotEmpty || imagePath.isNotEmpty) {
      await _chatService.sendMessage(
          widget.userID, imagePath.isNotEmpty ? imagePath : messageText);
      setState(() {
        _selectedImagePath = '';
        _messageController.clear();
      });
    }
  }

  StreamBuilder<Object> getNameById() {
    return StreamBuilder<QuerySnapshot>(
        stream: _userInfoService.getInfoUser(widget.userID),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: getNameById(),
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildMessageList(),
          ),
          _buildMessageInput(),
          const SizedBox(height: 25)
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder(
      stream: _chatService.getMessage(
          widget.userID, _firebaseAuth.currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Error');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        });

        return ListView(
          controller: _scrollController,
          children: snapshot.data!.docs
              .map((document) => _buildMessagItem(document))
              .toList(),
        );
      },
    );
  }

  Widget _buildMessagItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    return Container(
      alignment: (data['senderId'] == _firebaseAuth.currentUser!.uid)
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment:
              (data['senderId'] == _firebaseAuth.currentUser!.uid)
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
          mainAxisAlignment:
              (data['senderId'] == _firebaseAuth.currentUser!.uid)
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
          children: [
            BorderChat(
              message: data['message'],
              isSender: data['senderId'] == _firebaseAuth.currentUser!.uid,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Column(
        children: [
          if (_selectedImagePath.toString().isNotEmpty)
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    _selectedImagePath!,
                    fit: BoxFit.fitWidth,
                    width: 80,
                    height: 80,
                  ),
                ),
                Column(
                  children: [
                    GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedImagePath = '';
                          });
                        },
                        child: const Icon(Icons.cancel)),
                    const SizedBox(
                      height: 80,
                    )
                  ],
                )
              ],
            ),
          Row(
            children: [
              Expanded(
                child: MyTextField(
                  controller: _messageController,
                  hintText: 'Enter message',
                  obscureText: false,
                ),
              ),
              ImagePickerButton(
                onImageSelected: (String? imagePath) {
                  setState(() {
                    _selectedImagePath = imagePath;
                  });
                },
              ),
              IconButton(
                onPressed: sendMessage,
                icon: const Icon(
                  Icons.send,
                  size: 40,
                  color: Colors.blue,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
