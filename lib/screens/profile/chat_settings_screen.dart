import 'package:flutter/material.dart';

class ChatSettingsScreen extends StatelessWidget {
  const ChatSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Settings'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          SwitchListTile(
            value: true,
            onChanged: (v) {},
            title: const Text('Show read receipts'),
          ),
          SwitchListTile(
            value: true,
            onChanged: (v) {},
            title: const Text('Show typing indicators'),
          ),
          ListTile(
            leading: const Icon(Icons.format_size),
            title: const Text('Font size'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
