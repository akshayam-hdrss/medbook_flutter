

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:medbook/components/Footer.dart';
import 'package:medbook/components/common/loading_widget.dart';
import 'package:medbook/services/secure_storage_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

class DoctorSchedulePage extends StatefulWidget {
  const DoctorSchedulePage({super.key, this.selectedDoctor});

  final String? selectedDoctor;

  @override
  State<DoctorSchedulePage> createState() => _DoctorSchedulePageState();
}

class _DoctorSchedulePageState extends State<DoctorSchedulePage> {
  List<Map<String, dynamic>> _schedules = [];
  String? _errorMessage;
  bool _isLoading = true;
  bool _isDoctor = false;
  int? _userId;
  Timer? _timer;

  static const String baseUrl =
      "https://medbook-backend-1.onrender.com/api/bookings";

  @override
  void initState() {
    super.initState();
    _loadSchedules();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _loadSchedules();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<Map<String, dynamic>?> _getPrescription(int id) async {
    try {
      final url =
          Uri.parse("https://medbook-backend-1.onrender.com/api/prescription/getbyid/$id");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        throw Exception("Failed to fetch prescription: ${response.statusCode}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching prescription: $e")),
      );
      return null;
    }
  }

  Future<void> _loadSchedules() async {
    try {
      final storage = SecureStorageService();
      final userDetails = await storage.getUserDetails();

      final userId = userDetails?['id'];
      final isDoctor = userDetails?['isDoctor'] == 1;

      setState(() {
        _userId = userId;
        _isDoctor = isDoctor;
      });

      Uri url;

      if (isDoctor) {
        url = Uri.parse("$baseUrl/doctor/$userId");
      } else {
        url = Uri.parse("$baseUrl/user/$userId");
      }

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        List<Map<String, dynamic>> schedules;
        if (data is List) {
          schedules = List<Map<String, dynamic>>.from(data);
        } else if (data['data'] is List) {
          schedules = List<Map<String, dynamic>>.from(data['data']);
        } else {
          schedules = [];
        }

        if (widget.selectedDoctor != null && widget.selectedDoctor!.isNotEmpty) {
          schedules = schedules
              .where((s) =>
                  (s['doctorName']?.toString().toLowerCase() ?? '') ==
                  widget.selectedDoctor!.toLowerCase())
              .toList();
        }

        setState(() {
          _schedules = schedules;
          _isLoading = false;
        });
      } else {
        throw Exception("Failed: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  String formatTime(String timeString) {
    try {
      final time = DateFormat("HH:mm:ss").parse(timeString);
      return DateFormat("hh:mm a").format(time);
    } catch (e) {
      return timeString;
    }
  }

  String formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  Future<void> _updateBooking(
    Map<String, dynamic> schedule, {
    required String status,
    String? remarks,
    DateTime? date,
    String? time,
  }) async {
    try {
      final url = Uri.parse("$baseUrl/${schedule['id']}");
      final body = {
        "status": status,
        "remarks": remarks ?? "",
        "date": date != null
            ? DateFormat('yyyy-MM-dd').format(date)
            : DateFormat('yyyy-MM-dd').format(DateTime.parse(schedule['date'])),
        "time": time ?? schedule['time'],
        "userId": schedule['userId'],
        "doctorId": schedule['doctorId'],
        "editedBy": _isDoctor ? "doctor" : "user",
      };

      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Booking updated successfully")),
        );
        _loadSchedules();
      } else {
        throw Exception("Failed: ${response.body}");
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  void _showScheduleDetails(BuildContext context, Map<String, dynamic> schedule) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      "Appointment Details",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _isDoctor
                      ? _detailRow("Patient Name", schedule['patientName'])
                      : _detailRow("Doctor Name", schedule['doctorName']),
                  _detailRow("Patient Age", "${schedule['patientAge']}"),
                  _detailRow("Contact", schedule['contactNumber'], isPhone: true),
                  _detailRow("Description", schedule['description']),
                  _detailRow("Date", formatDate(schedule['date'])),
                  _detailRow("Time", formatTime(schedule['time'])),
                  schedule['isOnline'] == 1
                      ? _detailRow("Mode", "Online")
                      : _detailRow("Mode", "Offline"),
                  _detailRow("Status", schedule['status']),
                  _detailRow("Remarks", schedule['remarks'] ?? "N/A"),
                  const SizedBox(height: 20),
                  if (_isDoctor || schedule['status'] == "Rescheduled")
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 12,
                      children: [
                        _customButton(
                          label: "Reschedule",
                          colors: [Colors.blue, Colors.indigo],
                          onTap: () {
                            Navigator.pop(context);
                            _showRescheduleForm(context, schedule);
                          },
                        ),
                        _customButton(
                          label: "Confirm",
                          colors: [Colors.green, Colors.teal],
                          onTap: () {
                            Navigator.pop(context);
                            _updateBooking(schedule, status: "Confirmed");
                          },
                        ),
                      ],
                    ),
                  const SizedBox(height: 12),
                  _customButton(
                    label: "Close",
                    colors: [Colors.red, Colors.deepOrange],
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showRescheduleForm(BuildContext context, Map<String, dynamic> schedule) {
    final TextEditingController remarksController = TextEditingController();
    DateTime? selectedDate;
    TimeOfDay? selectedTime;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Reschedule Appointment",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.teal,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _customButton(
                    label: selectedDate == null
                        ? "Select Date"
                        : DateFormat('yyyy-MM-dd').format(selectedDate!),
                    colors: [Colors.purple, Colors.deepPurple],
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() => selectedDate = picked);
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  _customButton(
                    label: selectedTime == null
                        ? "Select Time"
                        : selectedTime!.format(context),
                    colors: [Colors.orange, Colors.deepOrange],
                    onTap: () async {
                      TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (picked != null) {
                        setState(() => selectedTime = picked);
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: remarksController,
                    decoration: const InputDecoration(
                      labelText: "Remarks",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _customButton(
                    label: "Save",
                    colors: [Colors.green, Colors.teal],
                    onTap: () {
                      Navigator.pop(context);
                      final formattedTime = selectedTime != null
                          ? "${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}:00"
                          : schedule['time'];
                      _updateBooking(
                        schedule,
                        status: "Rescheduled",
                        remarks: remarksController.text,
                        date: selectedDate,
                        time: formattedTime,
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String title, String? value, {bool isPhone = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              "$title:",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 5,
            child: isPhone && value != null
                ? InkWell(
                    onTap: () async {
                      final Uri launchUri = Uri(scheme: 'tel', path: value);
                      if (await canLaunchUrl(launchUri)) {
                        await launchUrl(launchUri);
                      }
                    },
                    child: Row(
                      children: [
                        Text(value, style: const TextStyle(color: Colors.blue)),
                        const SizedBox(width: 6),
                        const Icon(Icons.phone, color: Colors.green, size: 17),
                      ],
                    ),
                  )
                : Text(value ?? "N/A"),
          ),
        ],
      ),
    );
  }

  Widget _customButton({
    required String label,
    required List<Color> colors,
    double fontSize = 16, 
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(vertical: 12, horizontal: 24), 
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: colors.last.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

void _showPrescriptionDialog(Map<String, dynamic> prescription) {
  String formatDate(String? dateString) {
    if (dateString == null) return "N/A";
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (_) {
      return dateString;
    }
  }

  showDialog(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  "Prescription Details",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 🔹 Patient Info
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.red.shade100),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("👤 Patient: ${prescription['patientName'] ?? 'N/A'}",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text("🎂 Age: ${prescription['age'] ?? 'N/A'}"),
                      const SizedBox(height: 4),
                      Text("🏠 Address: ${prescription['address'] ?? 'N/A'}"),
                      const SizedBox(height: 4),
                      Text("🗓️ Date: ${formatDate(prescription['date'])}"),
                      const SizedBox(height: 4),
                      Text(
                          "🔁 Next Visit: ${formatDate(prescription['nextVisit'])}"),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 🔹 Description
              if (prescription['description'] != null &&
                  prescription['description'].toString().isNotEmpty)
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.red.shade100),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "📝 Description",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          prescription['description'] ?? '',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // 🔹 Medications Table
              const Text(
                "💊 Medications & Instructions",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 8),

              if (prescription['prescription'] != null &&
                  prescription['prescription'] is List &&
                  (prescription['prescription'] as List).isNotEmpty)
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.red.shade100),
                  ),
                  child: Table(
                    border: TableBorder.symmetric(
                      inside: BorderSide(color: Colors.grey.shade300),
                      outside: BorderSide(color: Colors.grey.shade300),
                    ),
                    columnWidths: const {
                      0: FlexColumnWidth(3), // Medicine
                      1: FlexColumnWidth(1), // Qty
                      2: FlexColumnWidth(2), // Before/After
                      3: FlexColumnWidth(1), // Breakfast
                      4: FlexColumnWidth(1), // Lunch
                      5: FlexColumnWidth(1), // Dinner
                    },
                    children: [
                      // Header Row
                      const TableRow(
                        decoration:
                            BoxDecoration(color: Color(0xFFFAEAEA)), // light red
                        children: [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text("Medicine",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14)),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text("Qty",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14)),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text("Before/After",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14)),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text("B",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14)),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text("L",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14)),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text("D",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14)),
                          ),
                        ],
                      ),

                      // Medicine Rows
                      ...(prescription['prescription'] as List)
                          .asMap()
                          .entries
                          .map<TableRow>((entry) {
                        final item = entry.value;
                        final isEven = entry.key % 2 == 0;

                        return TableRow(
                          decoration: BoxDecoration(
                            color: isEven
                                ? Colors.red.shade50
                                : Colors.white, // alternate row color
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(item['medicine'] ?? ''),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(item['quantity']?.toString() ?? ''),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(item['beforeAfterFood'] ?? ''),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                item['breakfast'] == true
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                color: item['breakfast'] == true
                                    ? Colors.green
                                    : Colors.redAccent,
                                size: 18,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                item['lunch'] == true
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                color: item['lunch'] == true
                                    ? Colors.green
                                    : Colors.redAccent,
                                size: 18,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                item['dinner'] == true
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                color: item['dinner'] == true
                                    ? Colors.green
                                    : Colors.redAccent,
                                size: 18,
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                )
              else
                const Text("No prescription details available."),

              const SizedBox(height: 20),

              // 🔹 Close Button
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.red, Colors.deepOrange],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "Close",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}




  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isTablet = constraints.maxWidth > 600;
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.selectedDoctor != null
                ? "${widget.selectedDoctor}"
                : "Doctor Schedule"),
            backgroundColor: const Color.fromARGB(255, 210, 10, 10),
            foregroundColor: Colors.white,
            centerTitle: true,
            elevation: 4,
          ),
          body: _isLoading
              ? const AppLoadingWidget()
              : _errorMessage != null
                  ? Center(child: Text("Error: $_errorMessage"))
                  : _schedules.isEmpty
                      ? const Center(child: Text("No schedules available"))
                      : GridView.builder(
                          padding: const EdgeInsets.all(7),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: isTablet ? 2 : 1,
                            childAspectRatio: isTablet ? 1.8 : 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: _schedules.length,
                          itemBuilder: (context, index) {
                            final schedule = _schedules[index];
                            final status = schedule['status'] ?? 'N/A';

                            return GestureDetector(
                              onTap: () => _showScheduleDetails(context, schedule),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                elevation: 6,
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                   Row(
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
    if ((schedule['isOnline'] ?? 0) == 1 ||
        schedule['isOnline'] == true ||
        schedule['isOnline'] == '1')
      Expanded(
        child: Wrap(
          alignment: WrapAlignment.start,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 4,
          children: [
            const Text(
              "Online Consultation",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            if (schedule['prescriptionID'] != null)
              GestureDetector(
                onTap: () async {
                  final prescription =
                      await _getPrescription(schedule['prescriptionID']);
                  if (prescription != null) {
                    _showPrescriptionDialog(prescription);
                  }
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.teal, Colors.green],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 3,
                        offset: const Offset(1, 2),
                      ),
                    ],
                  ),
                  child: const Text(
                    "View Prescription",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
  ],
),


                                      Row(
                                        children: [
                                          const Icon(Icons.person, color: Colors.teal),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              _isDoctor
                                                  ? (schedule['patientName'] ?? "Unknown Patient")
                                                  : (schedule['doctorName'] ?? "Unknown Doctor"),
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.calendar_today,
                                            size: 18,
                                            color: Colors.blueGrey,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(formatDate(schedule['date'])),
                                          const SizedBox(width: 16),
                                          const Icon(
                                            Icons.access_time,
                                            size: 18,
                                            color: Colors.blueGrey,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(formatTime(schedule['time'])),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.description,
                                            size: 18,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              schedule['description'] ?? 'N/A',
                                              style: const TextStyle(fontSize: 14),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: status == "Confirmed"
                                              ? const Color.fromARGB(255, 125, 246, 129)
                                              : status == "Pending"
                                                  ? const Color.fromARGB(255, 255, 159, 16)
                                                  : status == "Rescheduled"
                                                      ? const Color.fromARGB(255, 255, 0, 25)
                                                      : Colors.grey.shade200,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          "Status: $status",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: status == "Confirmed" ||
                                                    status == "Pending" ||
                                                    status == "Rescheduled"
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
          bottomNavigationBar: const Footer(title: "Schedule"),
        );
      },
    );
  }
}

