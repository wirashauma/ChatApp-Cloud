import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isMe;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      // Atur alignment ke kanan jika 'isMe', ke kiri jika bukan
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            // Atur warna sesuai desain (ungu jika 'isMe', abu-abu jika bukan)
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
            // Batasi lebar bubble agar tidak terlalu panjang
            maxWidth: MediaQuery.of(context).size.width * 0.7, 
          ),
          child: Text(
            message,
            style: TextStyle(
              color: isMe ? Colors.white : Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}