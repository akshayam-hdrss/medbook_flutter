import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:medbook/Services/secure_storage_service.dart';
import 'package:medbook/components/Footer.dart';
import 'package:medbook/pages/Schedule/DoctorSchedulePage.dart';
import 'package:medbook/pages/Schedule/ServiceSchedulePage.dart';

class DoctorListPage extends StatefulWidget {
  const DoctorListPage({super.key});

  @override
  State<DoctorListPage> createState() => _DoctorListPageState();
}

class _DoctorListPageState extends State<DoctorListPage> {
  List<String> doctorNames = [];
  List<String> serviceNames = []; // ✅ NEW
  bool isLoading = true;
  String? errorMessage;

  static const String doctorBaseUrl =
      "https://medbook-backend-1.onrender.com/api/bookings";

  static const String serviceBaseUrl =
      "https://medbook-backend-1.onrender.com/api/service-bookings";

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    await _loadDoctors();
    await _loadServices();
    setState(() => isLoading = false);
  }

  // ===================== LOAD DOCTORS ======================
  Future<void> _loadDoctors() async {
    try {
      final storage = SecureStorageService();
      final user = await storage.getUserDetails();
      final userId = user?['id'];
      final isDoctor = user?['isDoctor'] == 1;
      

      final url = Uri.parse(
        isDoctor ? "$doctorBaseUrl/doctor/$userId" : "$doctorBaseUrl/user/$userId",
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        List<Map<String, dynamic>> list =
            data is List ? List<Map<String, dynamic>>.from(data) : [];

        final names = list
            .map((e) => e["doctorName"]?.toString() ?? "")
            .where((e) => e.isNotEmpty)
            .toSet()
            .toList();

        doctorNames = names;
      }
    } catch (e) {
      errorMessage = e.toString();
    }
  }

  // ===================== LOAD SERVICES ======================
  Future<void> _loadServices() async {
    try {
      final storage = SecureStorageService();
      final user = await storage.getUserDetails();
      final userId = user?['id'];
      final isService = user?['isService'] == 1;

      final url = Uri.parse(
        isService ? "$serviceBaseUrl/service/$userId" : "$serviceBaseUrl/user/$userId",
        );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        List<Map<String, dynamic>> list =
            data is List ? List<Map<String, dynamic>>.from(data) : [];

        final names = list
            .map((e) => e["serviceName"]?.toString() ?? "")
            .where((e) => e.isNotEmpty)
            .toSet()
            .toList();

        serviceNames = names;
      }
    } catch (e) {
      errorMessage = e.toString();
    }
  }

  // =================== UI CARD FOR DOCTOR ===================
  Widget _buildDoctorCard(String doctor, bool isTablet) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DoctorSchedulePage(selectedDoctor: doctor),
          ),
        );
      },
      child: _buildCard(doctor, isTablet, Icons.person),
    );
  }

  // =================== UI CARD FOR SERVICE ==================
  Widget _buildServiceCard(String service, bool isTablet) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ServiceSchedulePage(
              selectedService: service,
            ),
          ),
        );
      },
      child: _buildCard(service, isTablet, Icons.home_repair_service),
    );
  }

  // ========== SHARED CARD WIDGET (Doctor + Service) ==========
  Widget _buildCard(String name, bool isTablet, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: isTablet ? 30 : 26,
            backgroundColor: const Color(0xFFEAF4F4),
            child: Icon(icon, color: Color(0xFF00796B), size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontSize: isTablet ? 20 : 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 18, color: Color(0xFF00796B)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > 600;
        final contentWidth = isTablet ? 600.0 : double.infinity;

        return Scaffold(
          backgroundColor: const Color(0xFFF7FAFC),

          appBar: AppBar(
            title: const Text("Doctors & Services"),
            centerTitle: true,
            backgroundColor: Colors.redAccent,
          ),

          body: isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.red))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: SizedBox(
                      width: contentWidth,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ---------------------- DOCTOR SECTION ---------------------
                          if (doctorNames.isNotEmpty) ...[
                            const Text("Doctors",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),

                            ...doctorNames.map(
                              (doc) => _buildDoctorCard(doc, isTablet),
                            ),
                            const SizedBox(height: 28),
                          ],

                          // ---------------------- SERVICE SECTION --------------------
                          if (serviceNames.isNotEmpty) ...[
                            const Text("Services",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),

                            ...serviceNames.map(
                              (srv) => _buildServiceCard(srv, isTablet),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),

          bottomNavigationBar: const Footer(title: "Doctors & Services"),
        );
      },
    );
  }
}
