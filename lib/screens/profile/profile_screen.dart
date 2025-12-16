import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chatapp/services/firestore_service.dart';
import 'package:chatapp/screens/profile/account_screen.dart';
import 'package:chatapp/screens/profile/chat_settings_screen.dart';
import 'package:chatapp/screens/profile/notifications_screen.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:chatapp/services/cloudinary_service.dart';
import 'package:chatapp/widgets/initial_avatar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoggingOut = false;
  bool _isUploading = false;
  File? _imageFile;

  @override
  Widget build(BuildContext context) {
    if (_isLoggingOut) {
      // Saat proses logout, tampilkan loading sederhana sehingga FutureBuilder tidak dipanggil ulang
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.black,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

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
          Map<String, dynamic> userData =
              snapshot.data!.data() as Map<String, dynamic>;

          String displayName = userData['displayName'] ?? 'No Name';
          String bio = userData['bio'] ?? 'No Bio';
          String photoUrl = userData['photoUrl'] ??
              'https://ssl.gstatic.com/images/silhouette/avatar-contact.png'; // Fallback dummy

          // Tampilkan UI Sesuai Figma (Layar 4)
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Bagian Header Profil dengan avatar modern dan tombol camera
              Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      InitialAvatar(
                        photoUrl: photoUrl,
                        imageFile: _imageFile,
                        name: displayName,
                        radius: 56,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: GestureDetector(
                          onTap: _showPickOptions,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.purple[400],
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 6,
                                )
                              ],
                            ),
                            padding: const EdgeInsets.all(10),
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    bio,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[700],
                    ),
                  ),
                  if (_isUploading) ...[
                    const SizedBox(height: 12),
                    const LinearProgressIndicator(),
                  ],
                ],
              ),
              const SizedBox(height: 30),
              const Divider(),

              // Bagian Menu
              ListTile(
                leading: const Icon(Icons.person_outline, color: Colors.grey),
                title: const Text('Account'),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const AccountScreen()));
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.chat_bubble_outline, color: Colors.grey),
                title: const Text('Chat Settings'),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ChatSettingsScreen()));
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.notifications_none, color: Colors.grey),
                title: const Text('Notifications'),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const NotificationsScreen()));
                },
              ),
              _buildMenuItem(context, 'Help', Icons.help_outline),

              const SizedBox(height: 30),

              // Tombol Logout
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleLogout,
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

  Future<void> _handleLogout() async {
    setState(() {
      _isLoggingOut = true;
    });

    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      // log but don't rethrow
      debugPrint('Logout error: $e');
    } finally {
      // Pastikan kembali ke root; AuthCheckScreen akan menangani route setelah sign out
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }
  }

  void _showPickOptions() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take photo'),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 1200,
        imageQuality: 85,
      );
      if (picked == null) return;

      final file = File(picked.path);
      setState(() {
        _imageFile = file; // preview immediately
      });

      await _uploadAndSave(file);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memilih gambar: $e')),
      );
    }
  }

  Future<void> _uploadAndSave(File file) async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isUploading = true);

    try {
      // Upload ke Cloudinary
      final url = await CloudinaryService.uploadImage(file);

      // Ambil data saat ini untuk tidak menimpa displayName/bio
      final snapshot = await FirestoreService.getUserProfile();
      final userData = snapshot.data() as Map<String, dynamic>;
      final currentName = userData['displayName'] ?? '';
      final currentBio = userData['bio'] ?? '';

      await FirestoreService.saveUserProfile(
        displayName: currentName,
        bio: currentBio,
        photoUrl: url,
      );

      messenger.showSnackBar(
          const SnackBar(content: Text('Foto profil diperbarui')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Upload gagal: $e')));
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
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
