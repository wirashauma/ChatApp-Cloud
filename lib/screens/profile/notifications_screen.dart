import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
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
            title: const Text('Push notifications'),
          ),
          SwitchListTile(
            value: false,
            onChanged: (v) {},
            title: const Text('Sound'),
          ),
          ListTile(
            leading: const Icon(Icons.notifications_active_outlined),
            title: const Text('Notification tone'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
