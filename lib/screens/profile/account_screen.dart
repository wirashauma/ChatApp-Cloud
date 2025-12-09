import 'dart:io';

import 'package:chatapp/services/firestore_service.dart';
import 'package:chatapp/services/cloudinary_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:chatapp/screens/profile/change_password_screen.dart';
import 'package:chatapp/widgets/initial_avatar.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const _AccountForm();
  }
}

class _AccountForm extends StatefulWidget {
  const _AccountForm({Key? key}) : super(key: key);

  @override
  State<_AccountForm> createState() => _AccountFormState();
}

class _AccountFormState extends State<_AccountForm> {
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  File? _imageFile;
  String? _existingPhotoUrl;
  bool _clearPhoto = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final doc = await FirestoreService.getUserProfile();
      if (!mounted) return;
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        _nameController.text = data['displayName'] ?? '';
        _bioController.text = data['bio'] ?? '';
        _existingPhotoUrl = (data['photoUrl'] as String?)?.isNotEmpty == true
            ? data['photoUrl'] as String?
            : null;
      }
    } catch (e) {
      debugPrint('Load profile error: $e');
    }
    if (mounted) setState(() {});
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    try {
      final XFile? picked =
          await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (picked != null) {
        setState(() {
          _imageFile = File(picked.path);
          _clearPhoto = false; // user picked a new photo
        });
      }
    } on MissingPluginException catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content:
                Text('Fitur pemilihan gambar tidak tersedia di platform ini')));
      }
    } catch (e) {
      debugPrint('Image pick error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal memilih gambar: $e')));
      }
    }
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    final bio = _bioController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nama tidak boleh kosong')));
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      String? photoUrl;
      final uid = FirebaseAuth.instance.currentUser?.uid;

      if (_imageFile != null && uid != null) {
        // upload new photo and use returned url
        photoUrl = await CloudinaryService.uploadProfileImage(uid, _imageFile!);
      } else if (_clearPhoto) {
        // user requested to remove photo -> pass null so FirestoreService will set default
        photoUrl = null;
      } else {
        // preserve existing photo url (if any)
        photoUrl = _existingPhotoUrl;
      }

      await FirestoreService.saveUserProfile(
          displayName: name, bio: bio, photoUrl: photoUrl);

      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Profil diperbarui')));
      Navigator.of(context).pop();
    } catch (e) {
      debugPrint('Save profile error: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal menyimpan profil: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // change password is handled in `ChangePasswordScreen`

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const SizedBox(height: 8),
          Center(
            child: Stack(
              children: [
                InitialAvatar(
                  imageFile: _imageFile,
                  photoUrl: _existingPhotoUrl,
                  name: _nameController.text.isNotEmpty
                      ? _nameController.text
                      : null,
                  radius: 56,
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_existingPhotoUrl != null || _imageFile != null)
                        InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            setState(() {
                              _imageFile = null;
                              _existingPhotoUrl = null;
                              _clearPhoto = true;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.delete_forever,
                                size: 18, color: Colors.redAccent),
                          ),
                        ),
                      InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit,
                              size: 18, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Display name',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _bioController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Bio',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isSaving ? null : _saveProfile,
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.purple[400]),
            child: _isSaving
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : const Text('Save Profile'),
          ),
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('Change password'),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ChangePasswordScreen()));
            },
          ),
        ],
      ),
    );
  }
}
