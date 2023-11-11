import 'package:cloud_firestore/cloud_firestore.dart';

class InfoUser {
  final String userId;
  final String userEmail;
  final String name;
  final String urlImage;
  final Timestamp timestamp;

  InfoUser({
    required this.name,
    required this.userEmail,
    required this.userId,
    required this.urlImage,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userEmail': userEmail,
      'name': name,
      'urlImage': urlImage,
      'timestamp': timestamp,
    };
  }
}
