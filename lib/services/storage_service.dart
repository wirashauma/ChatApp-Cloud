import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload profile image and return download URL
  static Future<String> uploadProfileImage(String uid, File file) async {
    final ref = _storage.ref().child('profile_images').child('$uid.jpg');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }
}
