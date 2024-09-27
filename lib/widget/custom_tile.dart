import 'package:flutter/material.dart';

class CustomTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color iconColor;
  final Color iconBackgroundColor;
  final VoidCallback? onTap;

  const CustomTile({
    super.key,
    required this.icon,
    required this.title,
    required this.iconColor,
    required this.iconBackgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        backgroundColor: iconBackgroundColor,
        child: Icon(icon, color: iconColor),
      ),
      title: Text(title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      trailing: Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}
