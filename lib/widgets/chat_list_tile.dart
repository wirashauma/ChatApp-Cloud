import 'package:chatapp/models/user_model.dart';
import 'package:chatapp/screens/chat/chat_detail_screen.dart';
import 'package:chatapp/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatListTile extends StatefulWidget {
  final DocumentSnapshot chatRoomDoc;
  const ChatListTile({super.key, required this.chatRoomDoc});

  @override
  State<ChatListTile> createState() => _ChatListTileState();
}

class _ChatListTileState extends State<ChatListTile> {
  UserModel? _otherUser;
  bool _isLoading = true;
  final String _currentUserId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _getOtherUserDetails();
  }

  void _getOtherUserDetails() async {
    // Ambil data dari dokumen chat room
    Map<String, dynamic> data =
        widget.chatRoomDoc.data() as Map<String, dynamic>;
    List<dynamic> participants = data['participants'];

    // Temukan UID user lain (bukan user yang sedang login)
    String otherUserId =
        participants.firstWhere((uid) => uid != _currentUserId, orElse: () => '');

    if (otherUserId.isNotEmpty) {
      // Ambil detail data user lain dari koleksi 'users'
      UserModel user = await FirestoreService.getUserDetails(otherUserId);
      if (mounted) {
        setState(() {
          _otherUser = user;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Selama loading, tampilkan placeholder
    if (_isLoading) {
      return const ListTile(
        leading: CircleAvatar(),
        title: Text('Loading...'),
        subtitle: Text('...'),
      );
    }

    // Jika user lain tidak ditemukan (misal: chat grup nanti)
    if (_otherUser == null) {
      return const SizedBox.shrink(); // Sembunyikan tile
    }

    // Ambil data pesan terakhir
    Map<String, dynamic> data =
        widget.chatRoomDoc.data() as Map<String, dynamic>;
    String lastMessage = data['lastMessage'] ?? '';
    String lastMessageSenderId = data['lastMessageSenderId'] ?? '';

    // Tampilkan "You: " jika pengirim terakhir adalah kita
    String subtitle =
        lastMessageSenderId == _currentUserId ? 'You: $lastMessage' : lastMessage;

    // Tampilkan tile yang sudah berisi data
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(_otherUser!.photoUrl),
      ),
      title: Text(_otherUser!.displayName, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(
        subtitle, // Tampilkan pesan terakhir (sesuai Figma)
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        "10:00 AM", // TODO: Format timestamp
        style: TextStyle(color: Colors.grey, fontSize: 12),
      ),
      onTap: () {
        // Buka halaman chat detail
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetailScreen(recipient: _otherUser!),
          ),
        );
      },
    );
  }
}