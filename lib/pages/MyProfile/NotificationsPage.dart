import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool pushNotifications = true;
  bool emailNotifications = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: const Color.fromARGB(255, 233, 61, 61),
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          fontFamily: 'Impact',
          fontSize: 24,
          color: Colors.white,
        )
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text("Push Notifications"),
            value: pushNotifications,
            onChanged: (val) => setState(() => pushNotifications = val),
            activeColor: Colors.deepOrange,
          ),
          SwitchListTile(
            title: const Text("Email Notifications"),
            value: emailNotifications,
            onChanged: (val) => setState(() => emailNotifications = val),
            activeColor: Colors.deepOrange,
          ),
        ],
      ),
    );
  }
}
