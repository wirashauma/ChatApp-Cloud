import 'dart:io';
import 'dart:convert';

import 'package:http/http.dart' as http;

/// Simple Cloudinary upload helper.
///
/// IMPORTANT: Replace `cloudName` and `uploadPreset` with your own values from
/// your Cloudinary dashboard (unsigned preset) before using.
class CloudinaryService {
  // TODO: update with your Cloudinary settings
  static const String cloudName = 'YOUR_CLOUD_NAME';
  static const String uploadPreset = 'YOUR_UPLOAD_PRESET';

  /// Uploads [file] to Cloudinary (unsigned) and returns the secure URL.
  /// Optional [publicId] and [folder] can be provided to control storage path.
  static Future<String> uploadImage(File file,
      {String? publicId, String? folder}) async {
    final uri =
        Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    final request = http.MultipartRequest('POST', uri);
    request.fields['upload_preset'] = uploadPreset;
    if (folder != null) request.fields['folder'] = folder;
    if (publicId != null) request.fields['public_id'] = publicId;

    final multipart = await http.MultipartFile.fromPath('file', file.path);
    request.files.add(multipart);

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
          'Cloudinary upload failed: ${response.statusCode} ${response.body}');
    }

    final body = json.decode(response.body) as Map<String, dynamic>;
    final secureUrl = body['secure_url'] as String?;
    if (secureUrl == null || secureUrl.isEmpty) {
      throw Exception('Cloudinary response missing secure_url');
    }
    return secureUrl;
  }
}
