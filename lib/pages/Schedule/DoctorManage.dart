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
      builder: (context) => AlertDialog(
        titlePadding: EdgeInsets.zero,
        contentPadding: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Container(
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
              Icon(FontAwesomeIcons.userDoctor, color: Colors.white),
              SizedBox(width: 10),
              Text(
                "Appointment Details",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ],
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(
              "Contact",
              appointment.contactNumber,
              icon: Icons.phone,
              isLink: true,
            ),
            _buildDetailRow(
              "Date",
              DateFormat('EEE, MMM d, y').format(appointment.date),
            ),
            _buildDetailRow("Time", _formatTime(appointment.time)),
            const SizedBox(height: 16),
            if (appointment.status.toLowerCase() == 'confirmed')
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    // Implement view prescription logic
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.amber.shade700),
                    foregroundColor: Colors.amber.shade700,
                  ),
                  child: const Text("View Prescription"),
                ),
              ),
            const SizedBox(height: 16),
            const Text("Status", style: TextStyle(fontWeight: FontWeight.bold)),
            Container(
              margin: const EdgeInsets.only(top: 5),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green, // Adjust dynamic color if needed
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
          ],
        ),
        actions: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    // Confirm action
                  },
                  icon: const Icon(Icons.check_box, color: Colors.white),
                  label: const Text(
                    "Confirmed",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFF66BB6A),
                    side: BorderSide.none,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: Colors.amber.shade700),
                  ),
                  child: Text(
                    "Prescription",
                    style: TextStyle(color: Colors.amber.shade700),
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
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
    );
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
}
