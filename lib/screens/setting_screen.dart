import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_final_mobile/components/button.dart';
import 'package:project_final_mobile/components/text_field.dart';
import 'package:project_final_mobile/services/auth_service.dart';
import 'package:project_final_mobile/services/info_user_service.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserInfoService _userInfoService = UserInfoService();
  final newPass = TextEditingController();
  final confirmPass = TextEditingController();
  final oldPass = TextEditingController();
  String? _selectedImagePath;
  bool isChange = false;
  bool isChangeProfile = false;

  void _signOut() {
    final authService = Provider.of<AuthService>(context, listen: false);
    authService.signOut();
  }

  void changeInfo(String uid, String name, String urlImage) {
    if (urlImage != 'null') {
      _userInfoService.updateUserName(uid, name);
      _userInfoService.updateUserImage(uid, urlImage);
    } else {
      _userInfoService.updateUserName(uid, name);
    }

    setState(() {
      isChangeProfile = false;
    });
  }

  final ImagePicker _imagePicker = ImagePicker();

  Future<void> _pickImage() async {
    XFile? pickedImage =
        await _imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      File imageFile = File(pickedImage.path);

      firebase_storage.Reference storageReference = firebase_storage
          .FirebaseStorage.instance
          .ref()
          .child('images/${DateTime.now().millisecondsSinceEpoch}.png');

      await storageReference.putFile(imageFile);

      String downloadURL = await storageReference.getDownloadURL();

      setState(() {
        _selectedImagePath = downloadURL;
      });
    }
  }

  Future<void> changePassword() async {
    User? user = _auth.currentUser;
    AuthCredential credential = EmailAuthProvider.credential(
      email: user!.email!,
      password: oldPass.text,
    );

    if (newPass.text != confirmPass.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mật khẩu xác nhận không trùng khớp')),
      );
      return;
    }

    try {
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPass.text);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã đổi mật khẩu thành công.')),
      );
      setState(() {
        isChange = !isChange;
      });
      newPass.clear();
      oldPass.clear();
      confirmPass.clear();
    } catch (e) {
      print(e);
      if (e.toString() ==
          '[firebase_auth/INVALID_LOGIN_CREDENTIALS] An internal error has occurred. [ INVALID_LOGIN_CREDENTIALS ]') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sai mật khẩu')),
        );
      }
    }
  }

  StreamBuilder<QuerySnapshot> _buildProfile() {
    return StreamBuilder<QuerySnapshot>(
      stream: _userInfoService.getInfoUser(_auth.currentUser!.uid),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else {
          if (userSnapshot.hasData && userSnapshot.data!.docs.isNotEmpty) {
            final userData =
                userSnapshot.data!.docs.first.data() as Map<String, dynamic>;
            final userName = userData['name'];
            final urlImg = userData['urlImage'];
            return Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(90),
                      child: Image.network(
                        urlImg,
                        fit: BoxFit.fitWidth,
                        width: 100,
                        height: 100,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 220,
                    child: Text(
                      userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isChangeProfile = true;
                      });
                    },
                    child: const Icon(Icons.edit),
                  ),
                ],
              ),
            );
          } else {
            return const Text('Không có dữ liệu');
          }
        }
      },
    );
  }

  StreamBuilder<QuerySnapshot> _buildEditProfile() {
    return StreamBuilder<QuerySnapshot>(
      stream: _userInfoService.getInfoUser(_auth.currentUser!.uid),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else {
          if (userSnapshot.hasData && userSnapshot.data!.docs.isNotEmpty) {
            final userData =
                userSnapshot.data!.docs.first.data() as Map<String, dynamic>;
            final userName = userData['name'];
            final urlImg = userData['urlImage'];
            var newName = TextEditingController(text: userName);
            return Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: _pickImage,
                          child: _selectedImagePath != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(90),
                                  child: Image.network(
                                    _selectedImagePath!,
                                    fit: BoxFit.fitWidth,
                                    width: 100,
                                    height: 100,
                                  ),
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(90),
                                  child: Image.network(
                                    urlImg,
                                    fit: BoxFit.fitWidth,
                                    width: 80,
                                    height: 80,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 200,
                    child: TextField(
                      controller: newName,
                    ),
                  ),
                  Container(
                    child: GestureDetector(
                      onTap: () {
                        changeInfo(_auth.currentUser!.uid, newName.text,
                            _selectedImagePath.toString());
                      },
                      child: const Icon(
                        Icons.check_box,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Text('Không có dữ liệu');
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin cá nhân'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              if (!isChangeProfile) _buildProfile(),
              if (isChangeProfile) _buildEditProfile(),
              const SizedBox(height: 10),
              if (isChange)
                MyTextField(
                  controller: oldPass,
                  hintText: 'Mật khẩu cũ',
                  obscureText: true,
                ),
              const SizedBox(height: 10),
              if (isChange)
                MyTextField(
                  controller: newPass,
                  hintText: 'Mật khẩu mới',
                  obscureText: true,
                ),
              const SizedBox(height: 10),
              if (isChange)
                MyTextField(
                  controller: confirmPass,
                  hintText: 'Xác nhận mật khẩu',
                  obscureText: true,
                ),
              const SizedBox(height: 10),
              if (isChange)
                MyButton(
                  onTap: changePassword,
                  text: 'Xác nhận đổi mật khẩu',
                ),
              const SizedBox(height: 10),
              MyButton(
                onTap: () {
                  setState(() {
                    isChange = !isChange;
                  });
                },
                text: isChange ? 'Hủy thay đổi' : 'Đổi mật khẩu',
              ),
              const SizedBox(height: 10),
              Container(
                child: MyButton(
                  onTap: _signOut,
                  text: 'Đăng xuất',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
