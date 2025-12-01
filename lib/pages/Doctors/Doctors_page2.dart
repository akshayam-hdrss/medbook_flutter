import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:medbook/components/Footer.dart';
import 'package:medbook/components/common/loading_widget.dart';
import 'package:medbook/pages/DoctorSchedule/DoctorSchedule.dart';
import 'dart:convert';
import 'package:medbook/pages/Hospitals/HospitalPage4.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medbook/Services/secure_storage_service.dart';

class DoctorsPage2 extends StatefulWidget {
  final String doctorTypeId;
  final String? selectedDistrict;
  final String? selectedArea;
  const DoctorsPage2({super.key, required this.doctorTypeId,this.selectedDistrict,this.selectedArea});

  @override
  State<DoctorsPage2> createState() => _DoctorsPage2State();
}

class _DoctorsPage2State extends State<DoctorsPage2> {
  late Future<List<Map<String, dynamic>>> _doctors;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredDoctors = [];
  List<Map<String, dynamic>> _allDoctors = [];
  String _selectedArea = 'All Areas';
  List<String> _availableAreas = ['All Areas'];

  @override

  void initState() {
    super.initState();
    _doctors = fetchDoctors(widget.doctorTypeId).then((doctors) {
      _allDoctors = List.from(doctors);

      final areas =
          doctors
              .map((doc) => doc['location']?.toString().trim())
              .where(
                (loc) =>
                    loc != null &&
                    loc.isNotEmpty &&
                    loc.toLowerCase() != 'unknown',
              )
              .toSet()
              .toList()
            ..sort();

      setState(() {
        _filteredDoctors = List.from(_allDoctors);
        _availableAreas = ['All Areas', ...areas.cast<String>()];
      });

      return doctors;
    });
  }

  Future<List<Map<String, dynamic>>> fetchDoctors(String id) async {
    final storage = SecureStorageService();
    final selectedArea = await storage.getSelectedArea() ?? '';
    final selectedDistrict = await storage.getSelectedDistrict() ?? '';

    final url =
        'https://medbook-backend-1.onrender.com/api/doctor?doctorTypeId=$id&location=$selectedArea&district=$selectedDistrict';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> doctorList = data['resultData'];

      // ✅ Sort by order_no (nulls last)
      doctorList.sort((a, b) {
        final aOrder = a['order_no'];
        final bOrder = b['order_no'];

        if (aOrder == null && bOrder == null) return 0; // both null → equal
        if (aOrder == null) return 1; // a is null → goes last
        if (bOrder == null) return -1; // b is null → goes last

        return (aOrder as int).compareTo(bOrder as int); // ascending
      });

      return doctorList.map<Map<String, dynamic>>((item) {
        return {
          'id': item['id'],
          'name': item['doctorName'] ?? 'N/A',
          'imageUrl': item['imageUrl'] ?? '',
          'speciality': item['speciality'] ?? '',
          'location': item['location'] ?? 'Unknown',
          'phone': item['phone'] ?? '',
          'degree': item['degree'] ?? '',
          'rating': item['rating'] ?? '0.0',
          'businessName': item['businessName'] ?? '',
          'designation': item['designation'] ?? '',
        };
      }).toList();
    } else {
      throw Exception('Failed to load doctors');
    }
  }

  void _filterDoctors() {
    setState(() {
      _filteredDoctors = _allDoctors.where((doctor) {
        final query = _searchController.text.toLowerCase();
        final nameMatch =
            query.isEmpty ||
            (doctor['name']?.toLowerCase().contains(query) ?? false) ||
            (doctor['speciality']?.toLowerCase().contains(query) ?? false) ||
            (doctor['businessName']?.toLowerCase().contains(query) ?? false);

        final areaMatch =
            _selectedArea == 'All Areas' ||
            (doctor['location']?.toLowerCase() == _selectedArea.toLowerCase());

        return nameMatch && areaMatch;
      }).toList();
    });
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _showError("Cannot make call.");
    }
  }

  Future<void> _launchWhatsApp(String phoneNumber) async {
    final cleanPhone = phoneNumber.replaceAll(' ', '').replaceAll('+', '');
    final Uri uri = Uri.parse("https://wa.me/$cleanPhone");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _showError("Cannot open WhatsApp.");
    }
  }

  Future<void> _launchMapLink(String location) async {
    final Uri uri = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=$location",
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _showError("Cannot open map.");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
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
              "Expert Practitioners",
              style: TextStyle(color: Colors.white),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _doctors,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppLoadingWidget();
            // return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("Error loading doctors"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
            child: Text(
              'No doctors available'
              '${widget.selectedArea != null && widget.selectedArea!.isNotEmpty && widget.selectedArea != 'All Areas' ? ' in ${widget.selectedArea}' : ''}'
              '${widget.selectedDistrict != null && widget.selectedDistrict!.isNotEmpty ? ', ${widget.selectedDistrict}' : ''}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          );


          }

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search by doctor name ',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 15,
                          ),
                          prefixIcon: Container(
                            padding: const EdgeInsets.all(14),
                            child: const Icon(
                              Icons.search_rounded,
                              color: Color(0xFFF37A20),
                              size: 26,
                            ),
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(
                                    Icons.close_rounded,
                                    color: Colors.grey.shade400,
                                    size: 22,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    _filterDoctors();
                                    FocusScope.of(context).unfocus();
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 2,
                            horizontal: 18,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: Color(0xFFF37A20).withOpacity(0.6),
                              width: 1.8,
                            ),
                          ),
                        ),
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade800,
                        ),
                        onChanged: (value) => _filterDoctors(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.grey.shade200,
                          width: 1.5,
                        ),
                      ),
                      child: DropdownButton<String>(
                        value: _selectedArea,
                        isExpanded: true,
                        underline: const SizedBox(),
                        icon: Icon(
                          Icons.arrow_drop_down_rounded,
                          color: Colors.grey.shade600,
                          size: 28,
                        ),
                        items: _availableAreas.map((area) {
                          return DropdownMenuItem<String>(
                            value: area,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                area,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          _selectedArea = value!;
                          _filterDoctors();
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (_filteredDoctors.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 50),
                          child: Text(
                            'No doctors found matching your search',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ),
                      ),
                    ..._filteredDoctors.map(
                      (doctor) => _buildDoctorCard(doctor),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: const Footer(title: "none"),
    );
  }

  Widget _buildDoctorCard(Map<String, dynamic> doctor) {
    final phone = doctor['phone'] ?? '';
    final location = doctor['location'] ?? '';
    final imageUrl = doctor['imageUrl'] ?? '';
    final doctorName = doctor['name'] ?? '';
    final doctorId = doctor['id'].toString();
    final rating = doctor['rating'] ?? '4.5';
    final degree = doctor['degree'] ?? '';
    final speciality = doctor['speciality'] ?? '';
    final businessName = doctor['businessName'] ?? '';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HospitalPage4(doctorId: doctorId),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl.isNotEmpty ? imageUrl : "",
                    height: 140,
                    width: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'lib/Assets/icons/doctor.png',
                        height: 140,
                        width: 120,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ..._buildStarIcons(double.tryParse(rating) ?? 0.0),
                    const SizedBox(width: 4),
                    Text(
                      rating,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctorName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    degree,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    businessName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    location,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      // ✅ These GestureDetectors prevent the parent onTap
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _makePhoneCall(phone),
                        child: _actionButton(
                          FontAwesomeIcons.phone,
                          Colors.lightBlueAccent,
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _launchWhatsApp(phone),
                        child: _actionButton(
                          FontAwesomeIcons.whatsapp,
                          Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _launchMapLink(location),
                        child: _actionIcon(
                          () => _launchMapLink(location),
                          FontAwesomeIcons.mapMarkerAlt,
                          const Color(0xFFFF5722),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: 160,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DoctorSchedule(
                              doctorName: doctorName,
                              doctorId: doctorId,
                              doctorNo: phone,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 234, 29, 29),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      child: const Text(
                        "Book Now",
                        style: TextStyle(fontSize: 14, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(IconData icon, Color color) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(child: FaIcon(icon, color: Colors.white, size: 18)),
    );
  }

  List<Widget> _buildStarIcons(double rating) {
    List<Widget> stars = [];
    for (int i = 1; i <= 5; i++) {
      if (i <= rating) {
        stars.add(const Icon(Icons.star, color: Colors.amber, size: 16));
      } else if (i - rating <= 0.5) {
        stars.add(const Icon(Icons.star_half, color: Colors.amber, size: 16));
      } else {
        stars.add(const Icon(Icons.star_border, color: Colors.amber, size: 16));
      }
    }
    return stars;
  }

  Widget _actionIcon(VoidCallback onTap, IconData icon, Color color) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(child: FaIcon(icon, color: Colors.white, size: 18)),
      ),
    );
  }
}
