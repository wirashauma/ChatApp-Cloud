// lib/screens/auth/otp_screen.dart
import 'package:chatapp/services/auth_service.dart';
import 'package:flutter/material.dart';

class OtpScreen extends StatefulWidget {
  // Kita butuh verificationId yang didapat dari LoginScreen
  final String verificationId; 
  
  const OtpScreen({super.key, required this.verificationId});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _otpController = TextEditingController();

  void _verifyOtp() {
    String otp = _otpController.text.trim();
    if (otp.length == 6) {
      // Panggil fungsi verifikasi dari AuthService
      AuthService.verifyOtp(
        context: context,
        verificationId: widget.verificationId, // Ambil dari widget
        userOtp: otp,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan 6 digit kode OTP.')),
      );
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verifikasi OTP')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Masukkan 6 digit kode',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Kami telah mengirimkan kode verifikasi ke nomor HP Anda.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 32),
            
            // Input Field untuk OTP
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6, // Hanya 6 digit
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, letterSpacing: 16),
              decoration: InputDecoration(
                hintText: '------',
                counterText: "", // Sembunyikan counter
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Tombol Verifikasi
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _verifyOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[400],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Verifikasi',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}