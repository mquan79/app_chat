import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project_final_mobile/model/info_user.dart';

class UserInfoService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  Future<void> createUser(String name, String urlImage) async {
    final String currentUserId = _firebaseAuth.currentUser!.uid;
    final String currentUserEmail = _firebaseAuth.currentUser!.email.toString();
    final Timestamp timestamp = Timestamp.now();

    InfoUser newUser = InfoUser(
      userId: currentUserId,
      userEmail: currentUserEmail,
      name: name,
      urlImage: urlImage,
      timestamp: timestamp,
    );
    List<String> ids = [currentUserId];
    ids.sort();

    await _fireStore.collection('info_user').add(newUser.toMap());
  }

  Stream<QuerySnapshot<Object?>> getInfoUser(String userId) {
    return _fireStore
        .collection('info_user')
        .where('userId', isEqualTo: userId)
        .snapshots();
  }

  Future<void> updateUserName(String userId, String newName) async {
    QuerySnapshot<Object?> userInfoSnapshot = await _fireStore
        .collection('info_user')
        .where('userId', isEqualTo: userId)
        .get();

    userInfoSnapshot.docs.forEach((doc) async {
      await _fireStore
          .collection('info_user')
          .doc(doc.id)
          .update({'name': newName});
    });
  }

  Future<void> updateUserImage(String userId, String newUrlImage) async {
    QuerySnapshot<Object?> userInfoSnapshot = await _fireStore
        .collection('info_user')
        .where('userId', isEqualTo: userId)
        .get();

    userInfoSnapshot.docs.forEach((doc) async {
      await _fireStore.collection('info_user').doc(doc.id).update({
        'urlImage': newUrlImage,
      });
    });
  }
}
