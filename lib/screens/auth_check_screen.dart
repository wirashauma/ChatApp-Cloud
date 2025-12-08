import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth/login_screen.dart';
import 'check_user_setup_screen.dart'; // Import file "pintar" kita

class AuthCheckScreen extends StatelessWidget {
  const AuthCheckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          
          // Jika masih loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Jika ada data user (snapshot.hasData == true)
          // Artinya user sudah login
          if (snapshot.hasData) {
            
            // --- INI PERUBAHANNYA ---
            // Jangan langsung arahkan
            // Lempar ke 'CheckUserSetupScreen' untuk dicek ke Firestore
            return CheckUserSetupScreen(uid: snapshot.data!.uid);
          
          }

          // Jika tidak ada data user (belum login)
          return LoginScreen();
        },
      ),
    );
  }
}