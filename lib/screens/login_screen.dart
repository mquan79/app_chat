import 'package:flutter/material.dart';
import 'package:project_final_mobile/components/button.dart';
import 'package:project_final_mobile/components/text_field.dart';
import 'package:project_final_mobile/services/auth_service.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  final void Function()? onTap;
  const LoginScreen({super.key, required this.onTap});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();

  void login() async {
    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      await authService.signInWithEmailAndPassword(
        email.text,
        password.text,
      );
    } catch (e) {
      if (e.toString() == 'Exception: invalid-email') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Email không đúng'),
          ),
        );
      }

      if (e.toString() == 'Exception: INVALID_LOGIN_CREDENTIALS') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sai mật khẩu'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.wechat,
                  size: 150,
                  color: Colors.blue,
                ),
                const SizedBox(height: 25),
                const Text(
                  "Đăng nhập",
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue),
                ),
                const SizedBox(height: 25),
                MyTextField(
                    controller: email, hintText: 'Email', obscureText: false),
                const SizedBox(height: 25),
                MyTextField(
                    controller: password,
                    hintText: 'Mật khẩu',
                    obscureText: true),
                const SizedBox(height: 30),
                MyButton(onTap: login, text: "Đăng nhập"),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Bạn không có tài khoản?'),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        'Đăng ký ngay',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
