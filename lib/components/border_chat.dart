import 'package:flutter/material.dart';

class BorderChat extends StatelessWidget {
  final String message;
  final bool isSender;
  const BorderChat({
    super.key,
    required this.message,
    required this.isSender,
  });

  bool isUrl(String message) {
    return message.startsWith('https://firebasestorage.googleapis.com/');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isSender ? Colors.blue : Colors.white,
          border: isSender
              ? Border.all(color: Colors.white)
              : Border.all(color: Colors.grey),
        ),
        child: isUrl(message.toString())
            ? (ClipRRect(
                child: Image.network(
                  message,
                  fit: BoxFit.fitWidth,
                  width: 200,
                  height: 200,
                ),
              ))
            : (Text(
                message,
                style: isSender
                    ? const TextStyle(fontSize: 16, color: Colors.white)
                    : const TextStyle(fontSize: 16, color: Colors.black),
              )));
  }
}
