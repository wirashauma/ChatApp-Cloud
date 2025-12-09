import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

/// Simple Cloudinary upload helper.
///
/// This uses an unsigned upload preset configured in your Cloudinary dashboard.
/// Set the values below before running the app.
class CloudinaryService {
  // TODO: replace with your Cloudinary cloud name
  static const String _cloudName = 'YOUR_CLOUD_NAME';
  // TODO: replace with your unsigned upload preset
  static const String _uploadPreset = 'YOUR_UPLOAD_PRESET';

  /// Uploads [file] to Cloudinary and returns the `secure_url`.
  ///
  /// Throws an exception if the upload fails.
  static Future<String> uploadProfileImage(String uid, File file) async {
    final uri =
        Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/upload');

    final request = http.MultipartRequest('POST', uri);
    request.fields['upload_preset'] = _uploadPreset;
    // optional: you can add a folder or public_id
    request.fields['folder'] = 'chatapp/profile_images';
    request.fields['public_id'] = uid;

    final multipartFile = await http.MultipartFile.fromPath('file', file.path);
    request.files.add(multipartFile);

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final secureUrl = data['secure_url'] as String?;
      if (secureUrl != null && secureUrl.isNotEmpty) return secureUrl;
      throw Exception('Cloudinary: missing secure_url in response');
    } else {
      throw Exception(
          'Cloudinary upload failed: ${response.statusCode} ${response.body}');
    }
  }
}
