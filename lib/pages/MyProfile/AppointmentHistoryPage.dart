import 'package:flutter/material.dart';

class AppointmentHistoryPage extends StatelessWidget {
  const AppointmentHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appointments = [
      {"date": "2025-07-01", "doctor": "Dr. Smith", "status": "Completed"},
      {"date": "2025-06-20", "doctor": "Dr. Alice", "status": "Cancelled"},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Appointment History"),
        backgroundColor: const Color.fromARGB(255, 233, 61, 61),
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          fontFamily: 'Impact',
          fontSize: 24,
          color: Colors.white,
        ),
      ),
      body: ListView.builder(
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          final item = appointments[index];
          return ListTile(
            leading: Icon(Icons.calendar_today, color: Colors.deepOrange),
            title: Text("Dr. ${item['doctor']}"),
            subtitle: Text(item['date']!),
            trailing: Text(item['status']!, style: TextStyle(color: Colors.green)),
          );
        },
      ),
    );
  }
}
