import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chatapp/screens/auth/setup_profile_screen.dart';
import 'package:chatapp/screens/home_screen.dart'; // <-- Ganti ProfileScreen dengan HomeScreen
import 'package:flutter/material.dart';
// Import ProfileScreen sudah tidak diperlukan di sini

class CheckUserSetupScreen extends StatelessWidget {
  final String uid;
  const CheckUserSetupScreen({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    // Gunakan FutureBuilder untuk mengecek data user di Firestore
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        
        // Selama proses pengecekan, tampilkan loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Jika ada error
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('Terjadi kesalahan')),
          );
        }

        // Cek apakah dokumen user ada
        if (snapshot.data != null && snapshot.data!.exists) {
          // --- KASUS 1: USER LAMA ---
          // Data user SUDAH ADA di Firestore
          // Arahkan ke HomeScreen (halaman utama dengan tab)
          return const HomeScreen(); // <-- INI PERUBAHANNYA
        } else {
          // --- KASUS 2: USER BARU ---
          // Data user BELUM ADA di Firestore
          // Paksa user untuk ke SetupProfileScreen
          return const SetupProfileScreen();
        }
      },
    );
  }
}