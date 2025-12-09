import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chatapp/models/user_model.dart';
import 'package:chatapp/services/firestore_service.dart';
import 'package:chatapp/widgets/chat_bubble.dart'; // Widget gelembung chat (kita buat)
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Untuk format tanggal/waktu

class ChatDetailScreen extends StatefulWidget {
  final UserModel recipient; // Terima data user yang akan di-chat

  const ChatDetailScreen({super.key, required this.recipient});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final String _currentUserId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    // Tandai semua pesan sebagai sudah dibaca saat layar dibuka
    FirestoreService.markMessagesAsRead(widget.recipient.uid);
  }

  // Fungsi kirim pesan
  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      FirestoreService.sendMessage(
        widget.recipient.uid,
        _messageController.text.trim(),
        isRead: false, // Tambahkan parameter isRead
      );
      _messageController.clear(); // Kosongkan field
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.recipient.photoUrl),
              radius: 20,
            ),
            const SizedBox(width: 12),
            Text(widget.recipient.displayName),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // Bagian 1: Daftar Pesan (Real-time)
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirestoreService.getChatStream(widget.recipient.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Mulai percakapan!'));
                }

                // Tampilkan list pesan
                return ListView.builder(
                  reverse: true, // Mulai dari bawah
                  padding: const EdgeInsets.all(16.0),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot doc = snapshot.data!.docs[index];
                    Map<String, dynamic> data =
                        doc.data() as Map<String, dynamic>;

                    // Cek apakah pesan ini dari user saat ini
                    bool isMe = data['senderId'] == _currentUserId;

                    // Ambil timestamp dan format waktu
                    Timestamp timestamp = data['timestamp'] as Timestamp;
                    String formattedTime =
                        DateFormat('hh:mm a').format(timestamp.toDate());

                    return ChatBubble(
                      message: data['text'],
                      isMe: isMe,
                      time: formattedTime, // Tambahkan waktu ke ChatBubble
                      isRead:
                          data['isRead'] ?? false, // Tambahkan parameter isRead
                    );
                  },
                );
              },
            ),
          ),

          // Bagian 2: Input Pesan
          _buildMessageInput(),
        ],
      ),
    );
  }

  // Widget untuk input field di bagian bawah
  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2), // shadow ke atas
          ),
        ],
      ),
      child: Row(
        children: [
          // Input field
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Message...',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Tombol Kirim
          FloatingActionButton(
            onPressed: _sendMessage,
            mini: true,
            backgroundColor: Colors.purple[400],
            elevation: 0,
            child: const Icon(Icons.send, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }
}
