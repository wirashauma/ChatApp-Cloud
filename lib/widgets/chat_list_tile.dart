import 'package:chatapp/models/user_model.dart';
import 'package:chatapp/screens/chat/chat_detail_screen.dart';
import 'package:chatapp/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatListTile extends StatefulWidget {
  final DocumentSnapshot chatRoomDoc;
  const ChatListTile({super.key, required this.chatRoomDoc});

  @override
  State<ChatListTile> createState() => _ChatListTileState();
}

class _ChatListTileState extends State<ChatListTile> {
  UserModel? _otherUser;
  bool _isLoading = true;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId = FirebaseAuth.instance.currentUser?.uid;
    _getOtherUserDetails();
  }

  void _getOtherUserDetails() async {
    // Ambil data dari dokumen chat room
    Map<String, dynamic> data =
        widget.chatRoomDoc.data() as Map<String, dynamic>;
    List<dynamic> participants = data['participants'];

    // Temukan UID user lain (bukan user yang sedang login)
    if (_currentUserId == null) {
      // User not signed in; don't attempt to load other user details
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    String otherUserId = participants.firstWhere((uid) => uid != _currentUserId,
        orElse: () => '');

    if (otherUserId.isNotEmpty) {
      try {
        // Ambil detail data user lain dari koleksi 'users'
        UserModel user = await FirestoreService.getUserDetails(otherUserId);
        if (mounted) {
          setState(() {
            _otherUser = user;
            _isLoading = false;
          });
        }
      } catch (e) {
        // Jika terjadi error (mis. user tidak terautentikasi), tangani dengan graceful fallback
        if (mounted) {
          setState(() {
            _otherUser = null;
            _isLoading = false;
          });
        }
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
    String subtitle = lastMessageSenderId == _currentUserId
        ? 'You: $lastMessage'
        : lastMessage;

    // Tampilkan tile yang sudah berisi data — dalam container bergaya kartu agar batas user jelas
    String timeLabel = '';
    if (data['lastTimestamp'] != null) {
      try {
        final Timestamp ts = data['lastTimestamp'] as Timestamp;
        timeLabel = DateFormat('hh:mm a').format(ts.toDate());
      } catch (_) {
        timeLabel = '';
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatDetailScreen(recipient: _otherUser!),
              ),
            );
          },
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.purple.withOpacity(0.18), width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 24,
                    backgroundImage: NetworkImage(_otherUser!.photoUrl),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _otherUser!.displayName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      timeLabel,
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
