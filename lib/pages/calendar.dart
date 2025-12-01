import 'package:flutter/material.dart';
import 'package:medbook/components/Footer.dart'; // Import the Footer widget

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calendar Page')),
      body: Center(child: Text('View your calendar here')),
      bottomNavigationBar: Footer(title: "schedule"), // Include footer navigation
    );
  }
}
