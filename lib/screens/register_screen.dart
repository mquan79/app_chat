import 'package:flutter/material.dart';
import 'package:project_final_mobile/components/button.dart';
import 'package:project_final_mobile/components/image_button.dart';
import 'package:project_final_mobile/components/text_field.dart';
import 'package:project_final_mobile/services/auth_service.dart';
import 'package:project_final_mobile/services/info_user_service.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  final void Function()? onTap;

  const RegisterScreen({Key? key, required this.onTap}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController confirmPassword = TextEditingController();
  final TextEditingController name = TextEditingController();
  final UserInfoService _userInfo = UserInfoService();
  String? _selectedImagePath;

  void register() async {
    if (_selectedImagePath == null ||
        email.text.isEmpty ||
        password.text.isEmpty ||
        confirmPassword.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Vui lòng nhập đầy đủ thông tin!"),
        ),
      );
      return;
    }

    if (confirmPassword.text != password.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Mật khẩu xác nhận không trùng khớp!"),
        ),
      );
      return;
    }

    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      await authService.signUpWithEmailAndPassword(
        email.text,
        password.text,
      );
      await _userInfo.createUser(name.text, _selectedImagePath.toString());
    } catch (e) {
      if (e.toString() == 'Exception: invalid-email') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Email không đúng định dạng'),
          ),
        );
      } else if (e.toString() == 'Exception: weak-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Mật khẩu phải có ít nhất 6 ký tự'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 100),
                const Text(
                  "Đăng ký",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 30),
                MyTextField(
                  controller: name,
                  hintText: 'Tên',
                  obscureText: false,
                ),
                const SizedBox(height: 25),
                Row(
                  children: [
                    Expanded(
                      child: MyTextField(
                        controller: _selectedImagePath != null
                            ? TextEditingController(
                                text: _selectedImagePath!.length > 50
                                    ? '${_selectedImagePath!.substring(0, 50)}...'
                                    : _selectedImagePath)
                            : TextEditingController(),
                        hintText: 'Hình ảnh',
                        obscureText: false,
                      ),
                    ),
                    ImagePickerButton(
                      onImageSelected: (String? imageUrl) {
                        setState(() {
                          _selectedImagePath = imageUrl;
                        });
                      },
                    ),
                  ],
                ),
                if (_selectedImagePath != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(180),
                      child: Image.network(
                        _selectedImagePath!,
                        fit: BoxFit.fitWidth,
                        width: 200,
                        height: 200,
                      ),
                    ),
                  ),
                const SizedBox(height: 25),
                MyTextField(
                  controller: email,
                  hintText: 'Email',
                  obscureText: false,
                ),
                const SizedBox(height: 25),
                MyTextField(
                  controller: password,
                  hintText: 'Mật khẩu',
                  obscureText: true,
                ),
                const SizedBox(height: 25),
                MyTextField(
                  controller: confirmPassword,
                  hintText: 'Xác nhận mật khẩu',
                  obscureText: true,
                ),
                const SizedBox(height: 50),
                MyButton(onTap: register, text: "Đăng ký"),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Bạn đã có tài khoản?'),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        'Đăng nhập ngay',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
