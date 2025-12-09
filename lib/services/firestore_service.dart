import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chatapp/models/user_model.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  // Variabel _currentUser yang tidak terpakai telah dihapus

  // --- FUNGSI PROFIL ---
  static Future<void> saveUserProfile({
    required String displayName,
    required String bio,
  }) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;
    String uid = currentUser.uid;
    String email = currentUser.email ?? '';
    String dummyPhotoUrl =
        "https://ssl.gstatic.com/images/silhouette/avatar-contact.png";

    Map<String, dynamic> userData = {
      'uid': uid,
      'displayName': displayName,
      'bio': bio,
      'photoUrl': dummyPhotoUrl,
      'email': email.toLowerCase(), // Simpan email sebagai lowercase
      'lastSeen': FieldValue.serverTimestamp(),
    };
    await _db.collection('users').doc(uid).set(userData);
  }

  static Future<DocumentSnapshot> getUserProfile() {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception("User not logged in");
    }
    return _db.collection('users').doc(currentUser.uid).get();
  }

  static Future<UserModel> getUserDetails(String uid) async {
    DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
    return UserModel.fromFirestore(doc);
  }

  // --- FUNGSI BARU UNTUK MENCARI USER ---
  static Future<UserModel?> findUserByEmail(String email) async {
    final String currentUserEmail =
        FirebaseAuth.instance.currentUser?.email ?? '';

    // 1. Cek jika user mencari emailnya sendiri
    if (email.toLowerCase() == currentUserEmail.toLowerCase()) {
      throw Exception('Anda tidak bisa memulai chat dengan diri sendiri.');
    }

    // 2. Cari di koleksi 'users'
    final querySnapshot = await _db
        .collection('users')
        .where('email', isEqualTo: email.toLowerCase())
        .limit(1) // Hanya butuh 1 hasil
        .get();

    // 3. Kembalikan hasilnya
    if (querySnapshot.docs.isNotEmpty) {
      // User ditemukan
      return UserModel.fromFirestore(querySnapshot.docs.first);
    } else {
      // User tidak ditemukan
      return null;
    }
  }

  // --- FUNGSI CHAT ---

  // 1. Helper untuk membuat ID chat room
  static String getChatRoomId(String user1Id, String user2Id) {
    List<String> ids = [user1Id, user2Id];
    ids.sort();
    return ids.join('_');
  }

  // 2. Mengirim pesan
  static Future<void> sendMessage(String recipientId, String messageText,
      {bool isRead = false}) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final String chatRoomId = getChatRoomId(currentUser.uid, recipientId);
    final Timestamp timestamp = Timestamp.now();

    Map<String, dynamic> newMessage = {
      'senderId': currentUser.uid,
      'recipientId': recipientId,
      'text': messageText,
      'timestamp': timestamp,
      'isRead': isRead, // Tambahkan properti isRead
    };

    // Tambahkan pesan ke sub-koleksi 'messages'
    await _db
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(newMessage);

    // Perbarui dokumen 'chat_rooms' induk
    Map<String, dynamic> chatRoomData = {
      'participants': [currentUser.uid, recipientId],
      'lastMessage': messageText,
      'lastMessageSenderId': currentUser.uid,
      'lastTimestamp': timestamp,
    };

    await _db
        .collection('chat_rooms')
        .doc(chatRoomId)
        .set(chatRoomData, SetOptions(merge: true));
  }

  // 3. Mengambil stream pesan dari chat room
  static Stream<QuerySnapshot> getChatStream(String recipientId) {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return Stream.empty();

    final String chatRoomId = getChatRoomId(currentUser.uid, recipientId);

    return _db
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // 4. Mengambil stream DAFTAR CHAT
  static Stream<QuerySnapshot> getChatRoomsStream() {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return Stream.empty();

    return _db
        .collection('chat_rooms')
        .where('participants', arrayContains: currentUser.uid)
        .orderBy('lastTimestamp', descending: true)
        .snapshots();
  }

  // Tandai semua pesan sebagai sudah dibaca
  static Future<void> markMessagesAsRead(String recipientId) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final String chatRoomId = getChatRoomId(currentUser.uid, recipientId);

    final QuerySnapshot messages = await _db
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .where('recipientId', isEqualTo: currentUser.uid)
        .where('isRead', isEqualTo: false)
        .get();

    for (var doc in messages.docs) {
      await doc.reference.update({'isRead': true});
    }
  }
}
