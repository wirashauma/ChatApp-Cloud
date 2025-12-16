import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help'),
        backgroundColor: Colors.purple[600],
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text('Frequently Asked Questions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ExpansionTile(
            leading: const Icon(Icons.login_outlined),
            title: const Text('How do I sign in?'),
            children: const [
              Padding(
                padding: EdgeInsets.all(12.0),
                child: Text(
                    'Sign in using your registered email and password on the Login screen. If you used phone auth, use the OTP flow.'),
              )
            ],
          ),
          ExpansionTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('I forgot my password. What now?'),
            children: const [
              Padding(
                padding: EdgeInsets.all(12.0),
                child: Text(
                    'Use the "Forgot password" link on the login screen to request a password reset email. Follow the instructions sent to your email.'),
              )
            ],
          ),
          ExpansionTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('How to change my profile photo or name?'),
            children: const [
              Padding(
                padding: EdgeInsets.all(12.0),
                child: Text(
                    'Open Account → Edit Profile. You can choose a photo from your gallery or take a new photo. After uploading, the new photo will be saved to your profile.'),
              )
            ],
          ),
          ExpansionTile(
            leading: const Icon(Icons.chat_bubble_outline),
            title: const Text('How do I start a chat?'),
            children: const [
              Padding(
                padding: EdgeInsets.all(12.0),
                child: Text(
                    'Tap the + button on the Chats screen, enter the email of a registered user, then start messaging.'),
              )
            ],
          ),
          ExpansionTile(
            leading: const Icon(Icons.image_outlined),
            title: const Text('Can I send images?'),
            children: const [
              Padding(
                padding: EdgeInsets.all(12.0),
                child: Text(
                    'Yes — use the attachment or camera button inside a chat to send images. Large files may take longer to upload.'),
              )
            ],
          ),
          const SizedBox(height: 16),
          const Text('Support',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.support_agent_outlined),
            title: const Text('Contact support'),
            subtitle: const Text('wirashaumaa@gmail.com'),
            onTap: () {},
          ),
          const SizedBox(height: 12),
          const Text('About',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('About app'),
            subtitle: Text(
                'ChatApp — a simple real-time chat built with Flutter & Firebase.'),
          ),
        ],
      ),
    );
  }
}
