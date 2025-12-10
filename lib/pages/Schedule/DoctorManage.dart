import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:medbook/Services/secure_storage_service.dart';
import 'package:medbook/components/common/loading_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medbook/components/Footer.dart';

class Appointment {
  final int id;
  final int doctorId;
  final String doctorName;
  final int userId;
  final String username;
  final String patientName;
  final int isOnline;
  final int? patientAge;
  final String contactNumber;
  final String description;
  final DateTime date;
  final String time;
  final String status;
  final String remarks;
  final String? paymentImageUrl;
  final DateTime createdAt;
  final int? prescriptionID;
  final String? bloodPressure;
  final String? height;
  final String? weight;
  final String? sugar;

  Appointment({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    required this.userId,
    required this.username,
    required this.patientName,
    required this.isOnline,
    this.patientAge,
    required this.contactNumber,
    required this.description,
    required this.date,
    required this.time,
    required this.status,
    required this.remarks,
    this.paymentImageUrl,
    required this.createdAt,
    this.prescriptionID,
    this.bloodPressure,
    this.height,
    this.weight,
    this.sugar,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      doctorId: json['doctorId'],
      doctorName: json['doctorName'] ?? '',
      userId: json['userId'],
      username: json['username'] ?? '',
      patientName: json['patientName'] ?? '',
      isOnline: json['isOnline'],
      patientAge: json['patientAge'],
      contactNumber: json['contactNumber'] ?? '',
      description: json['description'] ?? '',
      date: DateTime.parse(json['date']),
      time: json['time'],
      status: json['status'],
      remarks: json['remarks'] ?? '',
      paymentImageUrl: json['paymentImageUrl'],
      createdAt: DateTime.parse(json['createdAt']),
      prescriptionID: json['prescriptionID'],
      bloodPressure: json['bloodPressure'],
      height: json['height'],
      weight: json['weight'],
      sugar: json['sugar'],
    );
  }
}

class DoctorManage extends StatefulWidget {
  const DoctorManage({super.key});

  @override
  State<DoctorManage> createState() => _DoctorManageState();
}

class _DoctorManageState extends State<DoctorManage> {
  final SecureStorageService _storageService = SecureStorageService();
  List<Appointment> _appointments = [];
  List<Appointment> _filteredAppointments = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  String _filterStatus = 'All'; // 'All', 'Pending', 'Confirmed', 'Rescheduled'
  Timer? _timer;

  // For Basic Tests
  Appointment? _selectedAppointmentForTests;
  final TextEditingController _bpController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _sugarController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _fetchAppointments(isBackground: true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _bpController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _sugarController.dispose();
    super.dispose();
  }

  Future<void> _fetchAppointments({bool isBackground = false}) async {
    if (!isBackground) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final userDetails = await _storageService.getUserDetails();
      if (userDetails == null) {
        throw Exception("User not logged in");
      }

      // Handle nested user object if present
      var userData = userDetails;
      if (userData.containsKey('user')) {
        userData = userData['user'];
      }

      final int? doctorId = userData['id'];

      if (doctorId == null) {
        throw Exception("Doctor ID not found");
      }

      final url = Uri.parse(
        'https://medbook-backend-1.onrender.com/api/bookings/doctor/$doctorId',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        _appointments = jsonList
            .map((json) => Appointment.fromJson(json))
            .toList();
        _filterAppointments();
      } else {
        throw Exception("Failed to load appointments: ${response.statusCode}");
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      if (!isBackground) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<Map<String, dynamic>?> _getPrescription(int id) async {
    try {
      final url = Uri.parse(
        "https://medbook-backend-1.onrender.com/api/prescription/getbyid/$id",
      );
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

  void _filterAppointments() {
    setState(() {
      _filteredAppointments = _appointments.where((appointment) {
        final matchesSearch =
            appointment.patientName.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            appointment.description.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            );

        if (_filterStatus == 'All') return matchesSearch;
        return matchesSearch &&
            appointment.status.toLowerCase() == _filterStatus.toLowerCase();
      }).toList();
    });
  }

  int get _totalCount => _appointments.length;
  int get _pendingCount =>
      _appointments.where((a) => a.status.toLowerCase() == 'pending').length;
  int get _todayCount {
    final now = DateTime.now();
    return _appointments
        .where(
          (a) =>
              a.date.year == now.year &&
              a.date.month == now.month &&
              a.date.day == now.day,
        )
        .length;
  }

  int get _futureCount {
    final now = DateTime.now();
    return _appointments.where((a) => a.date.isAfter(now)).length;
  }

  // Update Basic Tests function
  Future<void> _updateBasicTests() async {
    if (_selectedAppointmentForTests == null) return;

    try {
      // Format date correctly for MySQL (YYYY-MM-DD)
      final scheduleDate = _selectedAppointmentForTests!.date;
      final formattedDate = DateFormat('yyyy-MM-dd').format(scheduleDate);

      // Format time correctly
      String formattedTime = _selectedAppointmentForTests!.time;
      if (formattedTime.length == 5) {
        formattedTime = '${formattedTime}:00';
      }

      final url = Uri.parse(
        "https://medbook-backend-1.onrender.com/api/bookings/${_selectedAppointmentForTests!.id}",
      );

      final body = {
        "status": _selectedAppointmentForTests!.status,
        "remarks": _selectedAppointmentForTests!.remarks,
        "date": formattedDate,
        "time": formattedTime,
        "userId": _selectedAppointmentForTests!.userId,
        "doctorId": _selectedAppointmentForTests!.doctorId,
        "bloodPressure": _bpController.text.trim(),
        "height": _heightController.text.trim(),
        "weight": _weightController.text.trim(),
        "sugar": _sugarController.text.trim(),
        "editedBy": "doctor",
      };

      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Basic tests saved successfully"),
            backgroundColor: Colors.green,
          ),
        );

        // Clear controllers
        _bpController.clear();
        _heightController.clear();
        _weightController.clear();
        _sugarController.clear();

        // Close dialog and refresh appointments
        Navigator.of(context).pop(); // Close basic tests dialog
        _fetchAppointments();

        // Refresh the appointment details dialog if it's open
        if (_selectedAppointmentForTests != null) {
          // Find the updated appointment
          final updatedAppointment = _appointments.firstWhere(
            (a) => a.id == _selectedAppointmentForTests!.id,
            orElse: () => _selectedAppointmentForTests!,
          );

          // Show updated details
          _showAppointmentDetails(updatedAppointment);
        }
      } else {
        final error = jsonDecode(response.body);
        throw Exception("Failed to save basic tests: ${error['error']}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  // Show Basic Tests Dialog
  void _showBasicTestsDialog(Appointment appointment) {
    _selectedAppointmentForTests = appointment;

    // Pre-fill existing values
    _bpController.text = appointment.bloodPressure ?? '';
    _heightController.text = appointment.height ?? '';
    _weightController.text = appointment.weight ?? '';
    _sugarController.text = appointment.sugar ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Basic Tests", style: TextStyle(color: Colors.blue)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _bpController,
                decoration: const InputDecoration(
                  labelText: "Blood Pressure",
                  hintText: "e.g., 120/80",
                  suffixText: "mmHg",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _sugarController,
                decoration: const InputDecoration(
                  labelText: "Sugar Level",
                  hintText: "e.g., 110",
                  suffixText: "mg/dL",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _heightController,
                      decoration: const InputDecoration(
                        labelText: "Height",
                        hintText: "e.g., 170",
                        suffixText: "cm",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _weightController,
                      decoration: const InputDecoration(
                        labelText: "Weight",
                        hintText: "e.g., 70",
                        suffixText: "kg",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),

              // Show existing values if available
              if (appointment.bloodPressure != null ||
                  appointment.height != null ||
                  appointment.weight != null ||
                  appointment.sugar != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Current Values:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        children: [
                          if (appointment.bloodPressure != null)
                            _buildCurrentValue(
                              "BP",
                              "${appointment.bloodPressure} mmHg",
                            ),
                          if (appointment.sugar != null)
                            _buildCurrentValue(
                              "Sugar",
                              "${appointment.sugar} mg/dL",
                            ),
                          if (appointment.height != null)
                            _buildCurrentValue(
                              "Height",
                              "${appointment.height} cm",
                            ),
                          if (appointment.weight != null)
                            _buildCurrentValue(
                              "Weight",
                              "${appointment.weight} kg",
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _bpController.clear();
              _heightController.clear();
              _weightController.clear();
              _sugarController.clear();
            },
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: _updateBasicTests,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text(
              "Save Tests",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentValue(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 225, 119, 20),
                Color.fromARGB(255, 239, 48, 34),
              ],
              stops: [0.0, 0.5],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            title: const Text(
              "Appointments",
              style: TextStyle(color: Colors.white),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: AppLoadingWidget())
          : _errorMessage != null
          ? Center(child: Text("Error: $_errorMessage"))
          : RefreshIndicator(
              onRefresh: _fetchAppointments,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSearchBar(),
                    const SizedBox(height: 16),
                    _buildClearFiltersButton(),
                    const SizedBox(height: 16),
                    _buildOverviewTitle(),
                    const SizedBox(height: 16),
                    _buildSummaryCards(),
                    const SizedBox(height: 24),
                    _buildTodaysAppointmentsHeader(),
                    const SizedBox(height: 8),
                    _buildFilterChips(),
                    const SizedBox(height: 16),
                    _buildAppointmentsList(),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: const Footer(title: 'Schedule'),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search by name...',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      onChanged: (value) {
        _searchQuery = value;
        _filterAppointments();
      },
    );
  }

  Widget _buildClearFiltersButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          setState(() {
            _searchQuery = '';
            _filterStatus = 'All';
            _filterAppointments();
          });
        },
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          side: BorderSide(color: Colors.grey.shade400),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),
        child: const Text(
          "Clear Filters",
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildOverviewTitle() {
    return const Text(
      "Appointment Overview",
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.blue,
      ),
    );
  }

  Widget _buildSummaryCards() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        return GridView.count(
          crossAxisCount: isWide ? 4 : 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.3,
          children: [
            _buildSummaryCard(
              "Total Appointments",
              _totalCount.toString(),
              Colors.blue,
            ),
            _buildSummaryCard(
              "Pending",
              _pendingCount.toString(),
              Colors.orange,
            ),
            _buildSummaryCard("Today", _todayCount.toString(), Colors.cyan),
            _buildSummaryCard("Future", _futureCount.toString(), Colors.teal),
          ],
        );
      },
    );
  }

  Widget _buildSummaryCard(String title, String count, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            count,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildTodaysAppointmentsHeader() {
    return const Row(
      children: [
        Icon(Icons.calendar_month, color: Colors.blue),
        SizedBox(width: 8),
        Text(
          "Today's Appointments",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip("Pending", Colors.amber, "Pending"),
          const SizedBox(width: 8),
          _buildFilterChip("Confirmed", Colors.green, "Confirmed"),
          const SizedBox(width: 8),
          _buildFilterChip("Rescheduled", Colors.cyan, "Rescheduled"),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, Color color, String statusValue) {
    final isSelected = _filterStatus == statusValue;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ActionChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (statusValue == "Pending")
              Icon(
                Icons.hourglass_empty,
                size: 16,
                color: isSelected ? Colors.white : color,
              ),
            if (statusValue == "Confirmed")
              Icon(
                Icons.check,
                size: 16,
                color: isSelected ? Colors.white : color,
              ),
            if (statusValue == "Rescheduled")
              Icon(
                Icons.calendar_today,
                size: 16,
                color: isSelected ? Colors.white : color,
              ),
            const SizedBox(width: 4),
            Text(
              '$label (${_appointments.where((a) => a.status.toLowerCase() == statusValue.toLowerCase()).length})',
              style: TextStyle(
                color: isSelected ? Colors.white : color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: isSelected ? color : Colors.white,
        side: BorderSide(color: color),
        onPressed: () {
          setState(() {
            if (_filterStatus == statusValue) {
              _filterStatus = 'All';
            } else {
              _filterStatus = statusValue;
            }
            _filterAppointments();
          });
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Widget _buildAppointmentsList() {
    final titleText = _filterStatus == 'All'
        ? "All Appointments (${_filteredAppointments.length})"
        : "$_filterStatus Appointments (${_filteredAppointments.length})";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.filter_list, color: Colors.blue[700]),
            const SizedBox(width: 8),
            Text(
              titleText,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_filteredAppointments.isEmpty)
          const Center(
            child: Text(
              "No appointments found",
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _filteredAppointments.length,
          itemBuilder: (context, index) {
            final appointment = _filteredAppointments[index];
            return _buildAppointmentCard(appointment);
          },
        ),
      ],
    );
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    Color statusColor;
    if (appointment.status.toLowerCase() == 'confirmed') {
      statusColor = Colors.green;
    } else if (appointment.status.toLowerCase() == 'pending') {
      statusColor = Colors.orange;
    } else {
      statusColor = Colors.grey;
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showAppointmentDetails(appointment),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    FontAwesomeIcons.userDoctor,
                    size: 20,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      appointment.patientName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
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
                    size: 16,
                    color: Colors.lightBlue,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('EEE, MMM d, y').format(appointment.date),
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.lightBlue,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatTime(appointment.time),
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.medical_services,
                    size: 16,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    appointment.description,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      appointment.status.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.phone, color: Colors.green),
                    onPressed: () => _launchPhone(appointment.contactNumber),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAppointmentDetails(Appointment appointment) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              width: constraints.maxWidth > 600 ? 500 : double.infinity,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.9,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color.fromARGB(255, 225, 119, 20),
                            Color.fromARGB(255, 239, 48, 34),
                          ],
                          stops: [0.0, 0.5],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            FontAwesomeIcons.userDoctor,
                            color: Colors.white,
                          ),
                          SizedBox(width: 10),
                          Text(
                            "Appointment Details",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                    // Content
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow(
                            "Patient",
                            appointment.patientName,
                            icon: Icons.person,
                          ),
                          _buildDetailRow(
                            "Age",
                            appointment.patientAge?.toString() ?? "",
                          ),
                          _buildDetailRow(
                            "Contact",
                            appointment.contactNumber,
                            icon: Icons.phone,
                            isLink: true,
                          ),
                          _buildDetailRow(
                            "Date",
                            DateFormat(
                              'EEE, MMM d, y',
                            ).format(appointment.date),
                          ),
                          _buildDetailRow(
                            "Time",
                            _formatTime(appointment.time),
                          ),

                          // Basic Tests Button
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).pop();
                              _showBasicTestsDialog(appointment);
                            },
                            icon: const Icon(
                              Icons.medical_services_outlined,
                              size: 20,
                            ),
                            label: const Text("Basic Tests"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade50,
                              foregroundColor: Colors.blue,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(color: Colors.blue.shade300),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                          const SizedBox(height: 8),

                          if (appointment.prescriptionID != null)
                            OutlinedButton.icon(
                              onPressed: () async {
                                Navigator.pop(context);

                                final prescription = await _getPrescription(
                                  appointment.prescriptionID!,
                                );

                                if (prescription != null) {
                                  _showPrescriptionDialog(prescription);
                                }
                              },
                              icon: const Icon(
                                Icons.receipt_long,
                                color: Colors.white,
                                size: 18,
                              ),
                              label: const Text(
                                "View Prescription",
                                style: TextStyle(color: Colors.white),
                              ),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                side: BorderSide.none,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                minimumSize: const Size(double.infinity, 48),
                              ),
                            ),

                          const SizedBox(height: 16),

                          // Basic Tests Results Display
                          if (appointment.bloodPressure != null ||
                              appointment.height != null ||
                              appointment.weight != null ||
                              appointment.sugar != null) ...[
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.blue.shade100),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.assignment,
                                        color: Colors.blue.shade700,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        "Basic Tests Results",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue,
                                        ),
                                      ),
                                      const Spacer(),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: const Text(
                                          "RECORDED",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 12,
                                    runSpacing: 12,
                                    children: [
                                      if (appointment.bloodPressure != null)
                                        _buildTestResultCard(
                                          "Blood Pressure",
                                          appointment.bloodPressure!,
                                          "mmHg",
                                          Icons.favorite_border,
                                          Colors.red.shade100,
                                        ),
                                      if (appointment.sugar != null)
                                        _buildTestResultCard(
                                          "Sugar Level",
                                          appointment.sugar!,
                                          "mg/dL",
                                          Icons.bloodtype,
                                          Colors.green.shade100,
                                        ),
                                      if (appointment.height != null)
                                        _buildTestResultCard(
                                          "Height",
                                          appointment.height!,
                                          "cm",
                                          Icons.height,
                                          Colors.blue.shade100,
                                        ),
                                      if (appointment.weight != null)
                                        _buildTestResultCard(
                                          "Weight",
                                          appointment.weight!,
                                          "kg",
                                          Icons.monitor_weight,
                                          Colors.orange.shade100,
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          const Text(
                            "Status",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 5),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              appointment.status.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),

                          const SizedBox(height: 16),
                          const Text(
                            "Remarks",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(top: 5),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              appointment.remarks.isNotEmpty
                                  ? appointment.remarks
                                  : "No remarks provided",
                            ),
                          ),
                          const SizedBox(height: 24),
                          OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _updateBooking(appointment, status: "confirmed");
                            },
                            icon: const Icon(
                              Icons.check_box,
                              color: Colors.white,
                            ),
                            label: const Text(
                              "Confirm",
                              style: TextStyle(color: Colors.white),
                            ),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: const Color(0xFF66BB6A),
                              side: BorderSide.none,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              minimumSize: const Size(double.infinity, 48),
                            ),
                          ),
                          const SizedBox(height: 10),
                          OutlinedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _showRescheduleForm(appointment);
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(color: Colors.amber.shade700),
                              minimumSize: const Size(double.infinity, 48),
                            ),
                            child: Text(
                              "Reschedule",
                              style: TextStyle(color: Colors.amber.shade700),
                            ),
                          ),
                          const SizedBox(height: 10),
                          OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              minimumSize: const Size(double.infinity, 48),
                            ),
                            child: const Text(
                              "Close",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTestResultCard(
    String title,
    String value,
    String unit,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: 130,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          Text(
            unit,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
          ),
        ],
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
                        Text(
                          "👤 Patient: ${prescription['patientName'] ?? 'N/A'}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text("🎂 Age: ${prescription['age'] ?? 'N/A'}"),
                        const SizedBox(height: 4),
                        Text("🏠 Address: ${prescription['address'] ?? 'N/A'}"),
                        const SizedBox(height: 4),
                        Text("🗓️ Date: ${formatDate(prescription['date'])}"),
                        const SizedBox(height: 4),
                        Text(
                          "🔁 Next Visit: ${formatDate(prescription['nextVisit'])}",
                        ),
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
                          decoration: BoxDecoration(
                            color: Color(0xFFFAEAEA),
                          ), // light red
                          children: [
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Medicine",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Qty",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Before/After",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "B",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "L",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "D",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
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
                                    child: Text(
                                      item['quantity']?.toString() ?? '',
                                    ),
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
                            })
                            .toList(),
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
                        vertical: 10,
                        horizontal: 24,
                      ),
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

  void _showRescheduleForm(Appointment appointment) {
    DateTime? selDate;
    TimeOfDay? selTime;
    TextEditingController remarkCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Reschedule Appointment",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton(
                      onPressed: () async {
                        final d = await showDatePicker(
                          context: context,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                          initialDate: appointment.date,
                        );
                        if (d != null) setState(() => selDate = d);
                      },
                      child: Text(
                        selDate == null
                            ? "Select Date"
                            : DateFormat('yyyy-MM-dd').format(selDate!),
                      ),
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
                      child: Text(
                        selTime == null
                            ? "Select Time"
                            : selTime!.format(context),
                      ),
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
                            : appointment.time;

                        _updateBooking(
                          appointment,
                          status: "rescheduled",
                          date: selDate,
                          time: formattedTime,
                          remarks: remarkCtrl.text,
                        );
                      },
                      child: const Text("Save"),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _updateBooking(
    Appointment appointment, {
    required String status,
    String? remarks,
    DateTime? date,
    String? time,
  }) async {
    try {
      final url = Uri.parse(
        "https://medbook-backend-1.onrender.com/api/bookings/${appointment.id}",
      );

      final body = {
        "status": status,
        "remarks": remarks ?? "",
        "date": date != null
            ? DateFormat('yyyy-MM-dd').format(date)
            : DateFormat('yyyy-MM-dd').format(appointment.date),
        "time": time ?? appointment.time,
        "userId": appointment.userId,
        "doctorId": appointment.doctorId,
        "editedBy": "doctor",
      };

      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Booking updated successfully"),
            backgroundColor: Colors.green,
          ),
        );
        _fetchAppointments();
      } else {
        throw Exception("Failed to update appointment");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  String _formatTime(String time) {
    try {
      final parsed = DateFormat("HH:mm:ss").parse(time);
      return DateFormat("hh:mm a").format(parsed);
    } catch (_) {
      return time;
    }
  }

  Future<void> _launchPhone(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    IconData? icon,
    bool isLink = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: Colors.blue),
                const SizedBox(width: 6),
              ],
              InkWell(
                onTap: isLink ? () => _launchPhone(value) : null,
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: isLink ? Colors.blue : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
