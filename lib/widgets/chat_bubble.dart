import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final String time; // Tambahkan properti untuk waktu
  final bool isRead; // Tambahkan properti untuk status baca

  const ChatBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.time, // Tambahkan parameter waktu
    required this.isRead, // Tambahkan parameter status baca
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: isMe
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start, // Atur alignment kolom
      children: [
        Row(
          mainAxisAlignment:
              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: isMe ? Colors.purple[300] : Colors.grey[300],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: isMe ? Radius.circular(16) : Radius.circular(0),
                  bottomRight: isMe ? Radius.circular(0) : Radius.circular(16),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              margin: const EdgeInsets.symmetric(vertical: 4),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              child: Text(
                message,
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black,
                ),
              ),
            ),
            if (isMe) // Tampilkan ikon ceklis hanya untuk pengirim
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Icon(
                  Icons.done_all,
                  size: 16,
                  color: isRead
                      ? Colors.blue
                      : Colors
                          .grey, // Warna biru jika sudah dibaca, abu-abu jika belum
                ),
              ),
          ],
        ),
        const SizedBox(height: 4), // Jarak antara bubble dan waktu
        Text(
          time,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
