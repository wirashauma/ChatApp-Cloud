// lib/services/auth_service.dart
import 'package:chatapp/screens/auth/otp_screen.dart'; // Nanti kita buat file ini
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService {
  // Buat instance dari FirebaseAuth
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- FUNGSI 1: MENGIRIM OTP ---
  static void sendOtp({
    required BuildContext context,
    required String phoneNumber,
  }) async {
    // Tampilkan loading dialog
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (context) => const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,

        // (A) Dipanggil jika verifikasi OTOMATIS sukses (biasanya di Android)
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          // Navigasi akan di-handle oleh AuthCheckScreen secara otomatis
        },

        // (B) Dipanggil jika verifikasi GAGAL
        verificationFailed: (FirebaseAuthException e) {
          navigator.pop(); // Tutup loading
          messenger.showSnackBar(
            SnackBar(content: Text('Gagal mengirim OTP: ${e.message}')),
          );
        },

        // (C) Dipanggil saat OTP SUKSES terkirim ke HP
        codeSent: (String verificationId, int? resendToken) {
          navigator.pop(); // Tutup loading
          // Arahkan ke Halaman OTP
          navigator.push(
            MaterialPageRoute(
              builder: (context) => OtpScreen(verificationId: verificationId),
            ),
          );
        },

        // (D) Dipanggil saat auto-retrieval timeout
        codeAutoRetrievalTimeout: (String verificationId) {
          // Bisa diabaikan untuk saat ini
        },
        timeout: const Duration(seconds: 60), // Waktu tunggu
      );
    } catch (e) {
      navigator.pop(); // Tutup loading
      messenger.showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: ${e.toString()}')),
      );
    }
  }

  // --- FUNGSI 2: MEMVERIFIKASI OTP ---
  static void verifyOtp({
    required BuildContext context,
    required String verificationId,
    required String userOtp,
  }) async {
    // Tampilkan loading
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (context) => const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      // Buat kredensial menggunakan verificationId dan kode OTP dari user
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: userOtp,
      );

      // Sign in user-nya
      await _auth.signInWithCredential(credential);

      // JANGAN navigasi dari sini.
      // Cukup tutup loading. AuthCheckScreen akan mendeteksi
      // perubahan status login dan mengarahkan ke ChatListScreen.
      navigator.pop(); // Tutup loading
    } catch (e) {
      navigator.pop(); // Tutup loading
      messenger.showSnackBar(
        const SnackBar(content: Text('Kode OTP salah atau tidak valid.')),
      );
    }
  }
}
