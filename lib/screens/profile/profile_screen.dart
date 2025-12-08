import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chatapp/services/firestore_service.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        // Ambil data user yang sedang login
        future: FirestoreService.getUserProfile(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {

          // Selama loading, tampilkan spinner
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Jika error
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          // Jika data tidak ditemukan (seharusnya tidak terjadi, tapi bagus untuk dicek)
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Data user tidak ditemukan."));
          }

          // Jika sukses, ambil data
          Map<String, dynamic> userData = snapshot.data!.data() as Map<String, dynamic>;
          
          String displayName = userData['displayName'] ?? 'No Name';
          String bio = userData['bio'] ?? 'No Bio';
          String photoUrl = userData['photoUrl'] ?? 'https://ssl.gstatic.com/images/silhouette/avatar-contact.png'; // Fallback dummy

          // Tampilkan UI Sesuai Figma (Layar 4)
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Bagian Header Profil
              Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(photoUrl),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    bio,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              const Divider(),

              // Bagian Menu
              _buildMenuItem(context, 'Account', Icons.person_outline),
              _buildMenuItem(context, 'Chat Settings', Icons.chat_bubble_outline),
              _buildMenuItem(context, 'Notifications', Icons.notifications_none),
              _buildMenuItem(context, 'Storage', Icons.data_usage_outlined),
              _buildMenuItem(context, 'Help', Icons.help_outline),
              _buildMenuItem(context, 'Invite a friend', Icons.people_outline),
              
              const SizedBox(height: 30),

              // Tombol Logout
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    // Panggil fungsi logout dari Firebase Auth
                    await FirebaseAuth.instance.signOut();
                    
                    // Navigasi akan di-handle oleh AuthCheckScreen
                    // Tapi kita pastikan user kembali ke root
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[50], // Sesuai Figma
                    foregroundColor: Colors.red[700], // Warna Teks
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Logout',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Widget helper untuk membuat menu item
  Widget _buildMenuItem(BuildContext context, String title, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[700]),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      onTap: () {
        // TODO: Tambahkan aksi untuk setiap menu
      },
    );
  }
}