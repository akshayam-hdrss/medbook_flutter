import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:medbook/pages/Schedule/DoctorSchedulePage.dart';
// import 'doctor_schedule_page.dart';

class DoctorSelectionPage extends StatefulWidget {
  const DoctorSelectionPage({super.key});

  @override
  State<DoctorSelectionPage> createState() => _DoctorSelectionPageState();
}

class _DoctorSelectionPageState extends State<DoctorSelectionPage> {
  final String baseUrl = "https://medbook-backend-1.onrender.com/api/bookings";
  List<String> doctorNames = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadDoctorNames();
  }

  Future<void> _loadDoctorNames() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        List<Map<String, dynamic>> allBookings = [];
        if (data is List) {
          allBookings = List<Map<String, dynamic>>.from(data);
        } else if (data['data'] is List) {
          allBookings = List<Map<String, dynamic>>.from(data['data']);
        }

        // ✅ Extract unique doctor names
        final names = allBookings
            .map((e) => e['doctorName']?.toString().trim())
            .where((name) => name != null && name.isNotEmpty)
            .toSet()
            .toList();

        setState(() {
          doctorNames = List<String>.from(names);
          isLoading = false;
        });
      } else {
        throw Exception("Failed to fetch doctors");
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Doctor"),
        backgroundColor: const Color.fromARGB(255, 210, 10, 10),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text("Error: $error"))
              : ListView.builder(
                  itemCount: doctorNames.length,
                  itemBuilder: (context, index) {
                    final doctor = doctorNames[index];
                    return ListTile(
                      leading: const Icon(Icons.person, color: Colors.teal),
                      title: Text(doctor),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DoctorSchedulePage(
                              selectedDoctor: doctor,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
