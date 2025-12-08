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

class ServiceBooking {
  final int id;
  final int serviceId;
  final String serviceName;
  final int userId;
  final String username;
  final String customerName;
  final String customerAge;
  final String customerGender;
  final String contactNumber;
  final String description;
  final DateTime date;
  final String time;
  final String status;
  final String? remarks;
  final String? paymentImageUrl;
  final int isOnline;
  final DateTime createdAt;

  ServiceBooking({
    required this.id,
    required this.serviceId,
    required this.serviceName,
    required this.userId,
    required this.username,
    required this.customerName,
    required this.customerAge,
    required this.customerGender,
    required this.contactNumber,
    required this.description,
    required this.date,
    required this.time,
    required this.status,
    this.remarks,
    this.paymentImageUrl,
    required this.isOnline,
    required this.createdAt,
  });

  factory ServiceBooking.fromJson(Map<String, dynamic> json) {
    return ServiceBooking(
      id: json['id'],
      serviceId: json['serviceId'],
      serviceName: json['serviceName'] ?? '',
      userId: json['userId'],
      username: json['username'] ?? '',
      customerName: json['customerName'] ?? '',
      customerAge: json['customerAge'] ?? '',
      customerGender: json['customerGender'] ?? '',
      contactNumber: json['contactNumber'] ?? '',
      description: json['description'] ?? '',
      date: DateTime.parse(json['date']),
      time: json['time'],
      status: json['status'],
      remarks: json['remarks'],
      paymentImageUrl: json['paymentImageUrl'],
      isOnline: json['isOnline'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class ServiceManage extends StatefulWidget {
  const ServiceManage({super.key});

  @override
  State<ServiceManage> createState() => _ServiceManageState();
}

class _ServiceManageState extends State<ServiceManage> {
  final SecureStorageService _storageService = SecureStorageService();
  List<ServiceBooking> _bookings = [];
  List<ServiceBooking> _filteredBookings = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  String _filterStatus = 'All'; // 'All', 'Pending', 'Confirmed', 'Rescheduled'
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchBookings();
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _fetchBookings(isBackground: true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchBookings({bool isBackground = false}) async {
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

      final int? serviceId = userData['id'];

      if (serviceId == null) {
        throw Exception("Service ID not found");
      }

      final url = Uri.parse(
        'https://medbook-backend-1.onrender.com/api/service-bookings/service/$serviceId',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        _bookings = jsonList
            .map((json) => ServiceBooking.fromJson(json))
            .toList();
        _filterBookings();
      } else {
        throw Exception("Failed to load bookings: ${response.statusCode}");
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

  void _filterBookings() {
    setState(() {
      _filteredBookings = _bookings.where((booking) {
        final matchesSearch =
            booking.customerName.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            booking.description.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            );

        if (_filterStatus == 'All') return matchesSearch;
        return matchesSearch &&
            booking.status.toLowerCase() == _filterStatus.toLowerCase();
      }).toList();
    });
  }

  int get _totalCount => _bookings.length;
  int get _pendingCount =>
      _bookings.where((b) => b.status.toLowerCase() == 'pending').length;
  int get _todayCount {
    final now = DateTime.now();
    return _bookings
        .where(
          (b) =>
              b.date.year == now.year &&
              b.date.month == now.month &&
              b.date.day == now.day,
        )
        .length;
  }

  int get _futureCount {
    final now = DateTime.now();
    return _bookings.where((b) => b.date.isAfter(now)).length;
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
              "Service Bookings",
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
              onRefresh: _fetchBookings,
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
                    _buildTodaysBookingsHeader(),
                    const SizedBox(height: 8),
                    _buildFilterChips(),
                    const SizedBox(height: 16),
                    _buildBookingsList(),
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
        hintText: 'Search by customer name...',
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
        _filterBookings();
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
            _filterBookings();
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
      "Booking Overview",
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
              "Total Bookings",
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

  Widget _buildTodaysBookingsHeader() {
    return const Row(
      children: [
        Icon(Icons.calendar_month, color: Colors.blue),
        SizedBox(width: 8),
        Text(
          "Today's Bookings",
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
              '$label (${_bookings.where((b) => b.status.toLowerCase() == statusValue.toLowerCase()).length})',
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
            _filterBookings();
          });
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Widget _buildBookingsList() {
    final titleText = _filterStatus == 'All'
        ? "All Bookings (${_filteredBookings.length})"
        : "$_filterStatus Bookings (${_filteredBookings.length})";

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
        if (_filteredBookings.isEmpty)
          const Center(
            child: Text(
              "No bookings found",
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _filteredBookings.length,
          itemBuilder: (context, index) {
            final booking = _filteredBookings[index];
            return _buildBookingCard(booking);
          },
        ),
      ],
    );
  }

  Widget _buildBookingCard(ServiceBooking booking) {
    Color statusColor;
    if (booking.status.toLowerCase() == 'confirmed') {
      statusColor = Colors.green;
    } else if (booking.status.toLowerCase() == 'pending') {
      statusColor = Colors.orange;
    } else {
      statusColor = Colors.grey;
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showBookingDetails(booking),
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
                    FontAwesomeIcons.user,
                    size: 20,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      booking.customerName,
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
                    DateFormat('EEE, MMM d, y').format(booking.date),
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
                    _formatTime(booking.time),
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.design_services,
                    size: 16,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    booking.description,
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
                      booking.status.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.phone, color: Colors.green),
                    onPressed: () => _launchPhone(booking.contactNumber),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBookingDetails(ServiceBooking booking) {
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
                          Icon(FontAwesomeIcons.user, color: Colors.white),
                          SizedBox(width: 10),
                          Text(
                            "Booking Details",
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
                            "Customer",
                            booking.customerName,
                            icon: Icons.person,
                          ),
                          _buildDetailRow("Age", booking.customerAge),
                          _buildDetailRow(
                            "Contact",
                            booking.contactNumber,
                            icon: Icons.phone,
                            isLink: true,
                          ),
                          _buildDetailRow(
                            "Date",
                            DateFormat('EEE, MMM d, y').format(booking.date),
                          ),
                          _buildDetailRow("Time", _formatTime(booking.time)),
                          const SizedBox(height: 16),
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
                              booking.status.toUpperCase(),
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
                              booking.remarks != null &&
                                      booking.remarks!.isNotEmpty
                                  ? booking.remarks!
                                  : "No remarks provided",
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Actions
                          OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _updateBooking(booking, status: "Confirmed");
                            },
                            icon: const Icon(
                              Icons.check_box,
                              color: Colors.white,
                            ),
                            label: const Text(
                              "Confirmed",
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
                              _showRescheduleForm(booking);
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

  // =================== UPDATE BOOKING ===================
  Future<void> _updateBooking(
    ServiceBooking booking, {
    required String status,
    String? remarks,
    DateTime? date,
    String? time,
  }) async {
    try {
      final url = Uri.parse(
        "https://medbook-backend-1.onrender.com/api/service-bookings/${booking.id}",
      );

      final body = {
        "status": status,
        "remarks": remarks ?? "",
        "date": date != null
            ? DateFormat('yyyy-MM-dd').format(date)
            : DateFormat('yyyy-MM-dd').format(booking.date),
        "time": time ?? booking.time,
        "userId": booking.userId,
        "serviceId": booking.serviceId,
        "editedBy": "service",
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
        _fetchBookings();
      } else {
        throw Exception("Failed to update booking");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  // ============== RESCHEDULE FORM ================
  void _showRescheduleForm(ServiceBooking booking) {
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
                      "Reschedule Booking",
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
                          initialDate: DateTime.now(),
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
                            : booking.time;

                        _updateBooking(
                          booking,
                          status: "Rescheduled",
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
