import 'package:chatapp/screens/home_screen.dart'; // <-- 1. UBAH IMPORT DARI PROFILE KE HOME
import 'package:chatapp/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/widgets/initial_avatar.dart';

class SetupProfileScreen extends StatefulWidget {
  const SetupProfileScreen({super.key});

  @override
  State<SetupProfileScreen> createState() => _SetupProfileScreenState();
}

class _SetupProfileScreenState extends State<SetupProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama tidak boleh kosong.')),
      );
      return;
    }

    final navigator = Navigator.of(context);

    setState(() {
      _isLoading = true;
    });

    try {
      await FirestoreService.saveUserProfile(
        displayName: _nameController.text.trim(),
        bio: _bioController.text.trim(),
      );

      if (mounted) {
        // --- 2. INI DIA PERBAIKANNYA ---
        // Arahkan ke HomeScreen, bukan ProfileScreen
        navigator.pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false, // Hapus semua riwayat navigasi
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan profil: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lengkapi Profil Anda'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Foto Dummy
              // show initial avatar (no name yet)
              SizedBox(
                width: 120,
                height: 120,
                child: Center(
                  child: InitialAvatar(
                    name: '',
                    photoUrl: null,
                    radius: 60,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Pilih Foto (Nanti)",
                style: TextStyle(color: Colors.purple[700]),
              ),
              const SizedBox(height: 40),

              // Input Nama
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'NAMA LENGKAP (Wajib)',
                  hintText: 'Mis: Jane Doe',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Input Bio
              TextField(
                controller: _bioController,
                decoration: InputDecoration(
                  labelText: 'BIO',
                  hintText: 'Bio singkat tentang Anda...',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Tombol Simpan
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[400],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Simpan & Lanjutkan',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
