import 'dart:io';

import 'package:flutter/material.dart';

const String _kDummyPhoto =
    'https://ssl.gstatic.com/images/silhouette/avatar-contact.png';

class InitialAvatar extends StatelessWidget {
  final String? photoUrl;
  final File? imageFile;
  final String? name;
  final double radius;

  const InitialAvatar({
    Key? key,
    this.photoUrl,
    this.imageFile,
    this.name,
    this.radius = 20,
  }) : super(key: key);

  Color _colorFromString(String? s) {
    final hash = (s ?? '').runes.fold<int>(0, (p, c) => p + c);
    final colors = [
      Colors.purple,
      Colors.blue,
      Colors.teal,
      Colors.orange,
      Colors.indigo,
      Colors.deepPurple,
      Colors.green,
    ];
    return colors[hash % colors.length].withOpacity(0.9);
  }

  String _initial() {
    if (name == null || name!.trim().isEmpty) return '?';
    final parts = name!.trim().split(RegExp(r'\s+'));
    final first = parts.first;
    return first.isEmpty ? '?' : first.substring(0, 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    // Prefer a freshly selected local file
    if (imageFile != null) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: FileImage(imageFile!),
      );
    }

    // If there's a remote photo and it's not the dummy placeholder, show it
    if (photoUrl != null && photoUrl!.isNotEmpty && photoUrl! != _kDummyPhoto) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(photoUrl!),
      );
    }

    // Fallback: initial
    final bg = _colorFromString(name);
    return CircleAvatar(
      radius: radius,
      backgroundColor: bg,
      child: Text(
        _initial(),
        style: TextStyle(
          color: Colors.white,
          fontSize: radius * 0.7,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
