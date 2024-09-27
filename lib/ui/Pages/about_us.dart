import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  final String appName = 'Swan Pair';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffffffff),
      appBar: AppBar(
        elevation: 2,
        backgroundColor: const Color(0xff3a57e8),
        iconTheme: const IconThemeData(color: Colors.white),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
        ),
        title: const Text(
          "About Us",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontStyle: FontStyle.normal,
            fontSize: 20,
            color: Color(0xffffffff),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'About Us',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "At $appName, our mission is simple: to make communication as easy and personal as possible, no matter the distance. In an increasingly digital world, we understand the importance of face-to-face interaction, whether for professional collaboration, educational engagement, or staying connected with family and friends. That’s why we created a video calling platform designed for the modern world—fast, secure, and simple to use.",
            ),
            const SizedBox(height: 20),
            const Text(
              'Our Vision',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "We believe that distance should never be a barrier to meaningful interaction. Our vision is to create a world where everyone has the ability to connect, share, and collaborate seamlessly, regardless of location. With $appName, you can have conversations that matter, whether you're discussing business strategies with clients or catching up with loved ones on the other side of the world.",
            ),
            const SizedBox(height: 20),
            const Text(
              'Our Values',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildBulletPoint(
                'Innovation: We are constantly evolving to meet the needs of our users. Our platform is built with state-of-the-art technology, ensuring you experience the latest advancements in video calling.'),
            _buildBulletPoint(
                'User-Centric Design: At the heart of everything we do is the user experience. We’ve designed $appName to be intuitive, accessible, and adaptable for both personal and professional use.'),
            _buildBulletPoint(
                'Security and Privacy: We understand the importance of keeping your data safe. All our communications are encrypted end-to-end, ensuring your conversations remain private and secure.'),
            _buildBulletPoint(
                'Reliability: Whether you’re in the middle of an important business meeting or connecting with a family member across the world, you can rely on $appName for uninterrupted, high-quality video calls.'),
            const SizedBox(height: 20),
            const Text(
              'Our Features',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildBulletPoint(
                'High-Definition Video and Audio: Crystal-clear quality makes your conversations feel as real as if you were in the same room.'),
            _buildBulletPoint(
                'Multi-Device Compatibility: Use $appName across all devices—smartphones, tablets, laptops, and desktops—with seamless syncing between them.'),
            _buildBulletPoint(
                'Large Group Calls: Perfect for remote work, online classes, or virtual family gatherings, $appName supports group video calls with up to [X] participants.'),
            _buildBulletPoint(
                'Screen Sharing & Collaboration Tools: Share your screen effortlessly for presentations, projects, or simply to guide someone through a process.'),
            _buildBulletPoint(
                'Record Meetings: Keep track of important discussions with the option to record and save your video calls for future reference.'),
            _buildBulletPoint(
                'Global Accessibility: Connect with people from any part of the world with no geographical limitations, offering real-time translation and captioning for added convenience.'),
            const SizedBox(height: 20),
            const Text(
              'Our Commitment',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "At $appName, we’re more than just a video calling app. We’re a team of passionate professionals committed to enhancing how the world communicates. As technology continues to evolve, so does our platform—constantly upgrading, improving, and adding new features to ensure you’re always getting the best communication experience possible.",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 18)),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
