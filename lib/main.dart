import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // File ini dibuat otomatis oleh FlutterFire
import 'screens/auth_check_screen.dart'; // Halaman pengecek login kita

void main() async {
  // Pastikan semua binding Flutter siap sebelum menjalankan kode async
  WidgetsFlutterBinding.ensureInitialized(); 
  
  // Inisialisasi Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Menjalankan aplikasi
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      theme: ThemeData(
        // Kita set warna utama ungu agar sesuai dengan desain
        primarySwatch: Colors.purple, 
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      // Halaman pertama yang dibuka adalah 'AuthCheckScreen'
      home: AuthCheckScreen(), 
    );
  }
}