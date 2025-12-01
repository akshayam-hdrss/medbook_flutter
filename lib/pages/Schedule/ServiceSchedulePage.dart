import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:medbook/components/Footer.dart';
import 'package:medbook/components/common/loading_widget.dart';
import 'package:medbook/services/secure_storage_service.dart';

class ServiceSchedulePage extends StatefulWidget {
  final String? selectedService;

  const ServiceSchedulePage({super.key, this.selectedService});

  @override
  State<ServiceSchedulePage> createState() => _ServiceSchedulePageState();
}

class _ServiceSchedulePageState extends State<ServiceSchedulePage> {
  List<Map<String, dynamic>> _schedules = [];
  String? _errorMessage;
  bool _isLoading = true;
  bool _isServiceProvider = false;
  int? _userId;

  static const String baseUrl =
      "https://medbook-backend-1.onrender.com/api/service-bookings";

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    try {
      final storage = SecureStorageService();
      final user = await storage.getUserDetails();

      final userId = user?['id'];
      final isService = user?['isService'] == 1;

      setState(() {
        _userId = userId;
        _isServiceProvider = isService;
      });

      Uri url;

      if (isService) {
        url = Uri.parse("$baseUrl/service/$userId");
      } else {
        url = Uri.parse("$baseUrl/user/$userId");
      }

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        List<Map<String, dynamic>> schedules =
            data is List ? List<Map<String, dynamic>>.from(data) : [];

        // Filter by selected service name
        if (widget.selectedService != null &&
            widget.selectedService!.isNotEmpty) {
          schedules = schedules
              .where((s) =>
                  (s['serviceName']?.toString().toLowerCase() ?? '') ==
                  widget.selectedService!.toLowerCase())
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

  String formatTime(String t) {
    try {
      return DateFormat("hh:mm a")
          .format(DateFormat("HH:mm:ss").parse(t.trim()));
    } catch (_) {
      return t;
    }
  }

  String formatDate(String d) {
    try {
      return DateFormat("dd MMM yyyy").format(DateTime.parse(d));
    } catch (_) {
      return d;
    }
  }

  // =================== UPDATE BOOKING ===================
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
        "serviceId": schedule['serviceId'],
        "editedBy": _isServiceProvider ? "service" : "user",
      };

      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Booking updated successfully"),
        ));
        _loadSchedules();
      } else {
        throw Exception("Failed to update booking");
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  // ================= SHOW DETAILS POPUP ==================
  void _showDetails(Map<String, dynamic> schedule) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                    child: Text(
                  "Service Booking Details",
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade700),
                )),
                const SizedBox(height: 16),

                _detailRow("Service", schedule['serviceName']),
                _detailRow("Customer", schedule['customerName']),
                _detailRow("Age", "${schedule['customerAge']}"),
                _detailRow("Gender", schedule['customerGender']),
                _detailRow("Phone", schedule['contactNumber']),
                _detailRow("Description", schedule['description']),
                _detailRow("Date", formatDate(schedule['date'])),
                _detailRow("Time", formatTime(schedule['time'])),
                _detailRow("Status", schedule['status']),
                _detailRow("Remarks", schedule['remarks'] ?? "N/A"),

                const SizedBox(height: 16),

                if (_isServiceProvider)
                  Wrap(
                    spacing: 10,
                    children: [
                      _actionButton(
                        "Confirm",
                        Colors.green,
                        () {
                          Navigator.pop(context);
                          _updateBooking(schedule, status: "Confirmed");
                        },
                      ),
                      _actionButton(
                        "Reschedule",
                        Colors.orange,
                        () {
                          Navigator.pop(context);
                          _showRescheduleForm(schedule);
                        },
                      ),
                    ],
                  ),

                const SizedBox(height: 14),
                _actionButton("Close", Colors.red, () {
                  Navigator.pop(context);
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============== RESCHEDULE FORM ================
  void _showRescheduleForm(Map<String, dynamic> schedule) {
    DateTime? selDate;
    TimeOfDay? selTime;
    TextEditingController remarkCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: StatefulBuilder(builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Reschedule Booking",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 14),

                ElevatedButton(
                  onPressed: () async {
                    final d = await showDatePicker(
                      context: context,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                      initialDate: DateTime.now(),
                    );
                    if (d != null) setState(() => selDate = d);
                  },
                  child: Text(
                      selDate == null ? "Select Date" : selDate.toString()),
                ),

                const SizedBox(height: 10),

                ElevatedButton(
                  onPressed: () async {
                    final t = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (t != null) setState(() => selTime = t);
                  },
                  child: Text(selTime == null
                      ? "Select Time"
                      : selTime!.format(context)),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: remarkCtrl,
                  decoration: const InputDecoration(
                    labelText: "Remarks",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);

                    final formattedTime = selTime != null
                        ? "${selTime!.hour.toString().padLeft(2, '0')}:${selTime!.minute.toString().padLeft(2, '0')}:00"
                        : schedule['time'];

                    _updateBooking(
                      schedule,
                      status: "Rescheduled",
                      date: selDate,
                      
                      time: formattedTime,
                      remarks: remarkCtrl.text,
                    );
                  },
                  child: const Text("Save"),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  // ================== UI HELPERS ==================
  Widget _detailRow(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text("$title: ",
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          Expanded(child: Text(value ?? "N/A")),
        ],
      ),
    );
  }

  Widget _actionButton(String label, Color color, VoidCallback onTap) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: color),
      onPressed: onTap,
      child: Text(label),
    );
  }

  // ================== BUILD UI ==================
  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.selectedService ?? "Service Schedule"),
        backgroundColor: Colors.redAccent,
      ),
      body: _isLoading
          ? const AppLoadingWidget()
          : _errorMessage != null
              ? Center(child: Text("Error: $_errorMessage"))
              : _schedules.isEmpty
                  ? const Center(child: Text("No service bookings found"))
                  : GridView.builder(
                      padding: const EdgeInsets.all(10),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isTablet ? 2 : 1,
                        childAspectRatio: 2.1,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: _schedules.length,
                      itemBuilder: (context, i) {
                        final s = _schedules[i];
                        final status = s['status'] ?? "N/A";

                        return GestureDetector(
                          onTap: () => _showDetails(s),
                          child: Card(
                            elevation: 6,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    s['customerName'] ?? 'Unknown Customer',
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_month,
                                          color: Colors.blue),
                                      const SizedBox(width: 4),
                                      Text(formatDate(s['date'])),
                                      const SizedBox(width: 15),
                                      const Icon(Icons.access_time,
                                          color: Colors.blueGrey),
                                      const SizedBox(width: 4),
                                      Text(formatTime(s['time'])),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(s['description'] ?? "No details"),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: status == "Confirmed"
                                          ? Colors.green
                                          : status == "Pending"
                                              ? Colors.orange
                                              : status == "Rescheduled"
                                                  ? Colors.red
                                                  : Colors.grey,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      status,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
      bottomNavigationBar: const Footer(title: "Service Schedule"),
    );
  }
}
