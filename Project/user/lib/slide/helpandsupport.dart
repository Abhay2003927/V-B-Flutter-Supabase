import 'package:flutter/material.dart';

class Helpandsupport extends StatefulWidget {
  const Helpandsupport({super.key});

  @override
  State<Helpandsupport> createState() => _HelpandsupportState();
}

class _HelpandsupportState extends State<Helpandsupport> {
  final TextEditingController _messageController = TextEditingController();
  bool _isFaq1Expanded = false;
  bool _isFaq2Expanded = false;
  bool _isFaq3Expanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // FAQ Section
            const Text(
              'Frequently Asked Questions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ExpansionTile(
              title: const Text('How do I reset my password?'),
              onExpansionChanged: (bool expanded) {
                setState(() => _isFaq1Expanded = expanded);
              },
              children: const [
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'To reset your password, go to Settings > Account > Change Password and follow the instructions. You\'ll need to verify your email address.',
                  ),
                ),
              ],
            ),
            ExpansionTile(
              title: const Text('How can I contact support?'),
              onExpansionChanged: (bool expanded) {
                setState(() => _isFaq2Expanded = expanded);
              },
              children: const [
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'You can contact support using the form below, email us at support@example.com, or call our toll-free number 1-800-555-HELP.',
                  ),
                ),
              ],
            ),
            ExpansionTile(
              title: const Text('What are the app\'s features?'),
              onExpansionChanged: (bool expanded) {
                setState(() => _isFaq3Expanded = expanded);
              },
              children: const [
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Our app includes features like user profiles, settings customization, real-time notifications, and 24/7 support.',
                  ),
                ),
              ],
            ),
            const Divider(height: 30),

            // Contact Support Section
            const Text(
              'Contact Support',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _messageController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Describe your issue...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                if (_messageController.text.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Message sent to support!')),
                  );
                  _messageController.clear();
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Send Message'),
            ),
            const Divider(height: 30),

            // Quick Contact Options
            const Text(
              'Quick Contact',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Email Us'),
              subtitle: const Text('support@example.com'),
              onTap: () {
                // Launch email client
              },
            ),
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Call Us'),
              subtitle: const Text('1-800-555-HELP'),
              onTap: () {
                // Launch phone dialer
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat),
              title: const Text('Live Chat'),
              subtitle: const Text('Available 24/7'),
              onTap: () {
                // Open chat interface
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}