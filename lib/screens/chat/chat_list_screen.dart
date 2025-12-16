import 'package:chatapp/models/user_model.dart';
import 'package:chatapp/screens/chat/chat_detail_screen.dart';
import 'package:chatapp/services/firestore_service.dart';
import 'package:chatapp/widgets/chat_list_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// Hapus import 'new_chat_screen.dart' karena kita tidak membutuhkannya lagi

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  // FUNGSI BARU UNTUK MENAMPILKAN DIALOG PENCARIAN
  void _showSearchUserDialog(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    bool isLoading = false;
    String? errorText;

    showDialog(
      context: context,
      builder: (dialogContext) {
        // Gunakan StatefulBuilder agar kita bisa update UI di dalam dialog
        return StatefulBuilder(
          builder: (stfContext, stfSetState) {
            return AlertDialog(
              title: const Text('Mulai Chat Baru'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Masukkan email user yang sudah terdaftar:'),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'user@example.com',
                      border: OutlineInputBorder(),
                      errorText: errorText, // Tampilkan error di sini
                    ),
                  ),
                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 16.0),
                      child: CircularProgressIndicator(),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext), // Tutup dialog
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          // 1. Mulai Loading
                          stfSetState(() {
                            isLoading = true;
                            errorText = null;
                          });

                          final navigator = Navigator.of(context);
                          final dialogNavigator = Navigator.of(dialogContext);

                          try {
                            // 2. Panggil service
                            UserModel? user =
                                await FirestoreService.findUserByEmail(
                                    emailController.text.trim().toLowerCase());

                            // 3. Cek hasil
                            if (user != null) {
                              // User DITEMUKAN
                              dialogNavigator.pop(); // Tutup dialog
                              // Langsung navigasi ke Chat Detail
                              navigator.push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ChatDetailScreen(recipient: user),
                                ),
                              );
                            } else {
                              // User TIDAK ditemukan
                              stfSetState(() {
                                isLoading = false;
                                errorText = 'User tidak ditemukan.';
                              });
                            }
                          } catch (e) {
                            // Tangani error (misal: chat dengan diri sendiri)
                            stfSetState(() {
                              isLoading = false;
                              errorText =
                                  e.toString().replaceFirst("Exception: ", "");
                            });
                          }
                        },
                  child: const Text('Cari'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chats',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.purple[600],
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirestoreService.getChatRoomsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'Anda belum punya percakapan.\nTekan + untuk memulai chat!',
                textAlign: TextAlign.center,
              ),
            );
          }

          final chatDocs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: chatDocs.length,
            itemBuilder: (context, index) {
              return ChatListTile(chatRoomDoc: chatDocs[index]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        // INI PERUBAHANNYA: Panggil dialog pencarian
        onPressed: () => _showSearchUserDialog(context),
        backgroundColor: Colors.purple[400],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
