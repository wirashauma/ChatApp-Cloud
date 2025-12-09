import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chatapp/models/user_model.dart';
import 'package:chatapp/services/firestore_service.dart';
import 'package:chatapp/widgets/chat_bubble.dart'; // Widget gelembung chat (kita buat)
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Untuk format tanggal/waktu
import 'package:chatapp/widgets/initial_avatar.dart';

// Simple date separator with fade-in animation
class _DateSeparator extends StatefulWidget {
  final String label;
  const _DateSeparator({Key? key, required this.label}) : super(key: key);
  @override
  State<_DateSeparator> createState() => _DateSeparatorState();
}

class _DateSeparatorState extends State<_DateSeparator> {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _opacity = 1.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _opacity,
      duration: const Duration(milliseconds: 350),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          widget.label,
          style: const TextStyle(fontSize: 12, color: Colors.black87),
        ),
      ),
    );
  }
}

class ChatDetailScreen extends StatefulWidget {
  final UserModel recipient; // Terima data user yang akan di-chat

  const ChatDetailScreen({super.key, required this.recipient});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final String _currentUserId = FirebaseAuth.instance.currentUser!.uid;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Tandai semua pesan sebagai sudah dibaca saat layar dibuka
    FirestoreService.markMessagesAsRead(widget.recipient.uid);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
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

  // scroll helper: scroll to bottom (newest message)
  void _scrollToBottom({bool animate = true}) {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    final target = position.maxScrollExtent;
    if (animate) {
      _scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _scrollController.jumpTo(target);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            InitialAvatar(
              photoUrl: widget.recipient.photoUrl,
              name: widget.recipient.displayName,
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

                // Jika ada pesan yang belum dibaca oleh user saat ini, tandai sebagai sudah dibaca.
                // Ini membantu pembaruan read-receipt (ceklis) agar pengirim melihat perubahan saat penerima
                // membuka layar atau saat chat aktif menerima pesan baru.
                final docs = snapshot.data!.docs;
                final bool hasUnreadForMe = docs.any((d) {
                  final Map<String, dynamic> m =
                      d.data() as Map<String, dynamic>;
                  return (m['recipientId'] == _currentUserId) &&
                      (m['isRead'] == false || m['isRead'] == null);
                });

                if (hasUnreadForMe) {
                  FirestoreService.markMessagesAsRead(widget.recipient.uid);
                }

                // Buat daftar widget berurutan kronologis (oldest -> newest)
                final docsDesc = snapshot.data!
                    .docs; // query mengembalikan descending (newest first)
                final docsChrono =
                    docsDesc.reversed.toList(); // now oldest -> newest

                List<Widget> children = [];
                String? lastDateKey;

                for (var doc in docsChrono) {
                  final Map<String, dynamic> data =
                      doc.data() as Map<String, dynamic>;
                  final Timestamp timestamp = data['timestamp'] as Timestamp;
                  final DateTime dt = timestamp.toDate();

                  final String dateKey = DateFormat('yyyy-MM-dd').format(dt);
                  // Jika hari berbeda dengan pesan sebelumnya, tambahkan date separator
                  if (lastDateKey == null || lastDateKey != dateKey) {
                    // Gunakan label lokal Bahasa Indonesia: "Hari Ini" / "Kemarin" jika cocok, atau tanggal lengkap jika bukan.
                    final DateTime today = DateTime.now();
                    final DateTime todayDate =
                        DateTime(today.year, today.month, today.day);
                    final DateTime msgDate =
                        DateTime(dt.year, dt.month, dt.day);
                    final int diffDays = todayDate.difference(msgDate).inDays;
                    final String label = diffDays == 0
                        ? 'Hari Ini'
                        : (diffDays == 1
                            ? 'Kemarin'
                            : DateFormat('d MMM yyyy').format(dt));
                    children.add(
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Center(
                          child: _DateSeparator(label: label),
                        ),
                      ),
                    );
                    lastDateKey = dateKey;
                  }

                  // Cek apakah pesan ini dari user saat ini
                  bool isMe = data['senderId'] == _currentUserId;

                  // Format waktu untuk menampilkan di bawah bubble
                  String formattedTime = DateFormat('hh:mm a').format(dt);

                  children.add(
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: ChatBubble(
                        message: data['text'] ?? '',
                        isMe: isMe,
                        time: formattedTime,
                        isRead: data['isRead'] ?? false,
                      ),
                    ),
                  );

                  // Tambahkan time label terpisah di bawah bubble (agar tidak mempengaruhi ukuran bubble)
                  children.add(
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 16.0, right: 16.0, bottom: 6.0),
                      child: Align(
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Text(
                          formattedTime,
                          style: TextStyle(fontSize: 11, color: Colors.black54),
                        ),
                      ),
                    ),
                  );
                }

                // Tampilkan sebagai ListView (oldest->newest) dan scroll ke bawah secara otomatis
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });

                return ListView(
                  controller: _scrollController,
                  reverse: false,
                  padding: const EdgeInsets.all(16.0),
                  children: children,
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
