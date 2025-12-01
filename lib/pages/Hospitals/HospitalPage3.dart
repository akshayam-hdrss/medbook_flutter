//search and filter functionality

import 'package:flutter/material.dart';
import 'package:medbook/components/Footer.dart';
import 'package:medbook/components/common/loading_widget.dart';
import 'package:medbook/components/videoCarousel.dart';
import 'package:medbook/pages/DoctorSchedule/DoctorSchedule.dart';
import 'package:medbook/utils/api_service.dart';
import 'package:medbook/pages/Hospitals/HospitalPage4.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HospitalPage3 extends StatefulWidget {
  final String hospitalId;
  final String hospitalTypeId;

  const HospitalPage3({
    super.key,
    required this.hospitalId,
    required this.hospitalTypeId,
  });

  @override
  _HospitalPage3State createState() => _HospitalPage3State();
}

class _HospitalPage3State extends State<HospitalPage3> {
  late Future<Map<String, dynamic>> _dataFuture;
  late Future<Map<String, dynamic>> _adsFuture;
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All Categories';
  List<String> _availableCategories = ['All Categories'];
  List<Map<String, String>> _filteredDoctors = [];
  Map<String, List<Map<String, String>>> _categorizedDoctors = {};

  @override
  void initState() {
    super.initState();
    _dataFuture = fetchDoctorsByHospital(widget.hospitalId).then((data) {
      final categories = List<String>.from(data['categories'] ?? []);
      final doctors = List<Map<String, String>>.from(data['doctors'] ?? []);

      setState(() {
        _availableCategories = ['All Categories', ...categories];
        _filteredDoctors = List.from(doctors);
        _updateCategorizedDoctors();
      });
      return data;
    });
    _adsFuture = fetchHospitalAds();
  }

  Future<Map<String, dynamic>> fetchHospitalAds() async {
    try {
      final response = await ApiServiceADS().getData(
        '/api/ads/gallery/hospital?typeId=${widget.hospitalTypeId}&itemId=${widget.hospitalId}',
      );
      if (response['result'] == 'Success' &&
          response['resultData'].isNotEmpty) {
        return response;
      }
      return {'youtubeLinks': []};
    } catch (e) {
      print('Error fetching hospital ads: $e');
      return {'youtubeLinks': []};
    }
  }

  void _filterDoctors(List<Map<String, String>> allDoctors) {
    setState(() {
      _filteredDoctors = allDoctors.where((doctor) {
        final nameMatch =
            _searchController.text.isEmpty ||
            (doctor['doctorName']?.toLowerCase().contains(
                  _searchController.text.toLowerCase(),
                ) ??
                false);
        final categoryMatch =
            _selectedCategory == 'All Categories' ||
            (doctor['category']?.toLowerCase() ==
                _selectedCategory.toLowerCase());
        return nameMatch && categoryMatch;
      }).toList();

      _updateCategorizedDoctors();
    });
  }

  void _updateCategorizedDoctors() {
    final Map<String, List<Map<String, String>>> tempCategorized = {};

    for (var doc in _filteredDoctors) {
      final category = doc['category']?.trim() ?? 'Others';
      if (!tempCategorized.containsKey(category)) {
        tempCategorized[category] = [];
      }
      tempCategorized[category]!.add(doc);
    }

    setState(() {
      _categorizedDoctors = tempCategorized;
    });
  }

  Future<void> _launchCaller(String phoneNumber) async {
    final Uri uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _showError("Cannot initiate call.");
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
      _showError("Cannot open Map.");
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
            iconTheme: const IconThemeData(
              color: Color.fromARGB(255, 255, 255, 255),
            ),
            title: const Text(
              'Panel Experts',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
          ),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppLoadingWidget();
            // return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading doctors'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No doctors available'));
          }

          final List<Map<String, String>> doctors =
              List<Map<String, String>>.from(snapshot.data!['doctors'] ?? []);

          return Column(
            children: [
              // Search and Filter Section
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Column(
                  children: [
                    // Search Bar
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 12,
                            spreadRadius: 1,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search doctors by name...',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 15,
                          ),
                          prefixIcon: Container(
                            padding: const EdgeInsets.all(15),
                            child: Icon(
                              Icons.search_rounded,
                              color: Colors.orange[600],
                              size: 24,
                            ),
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? Padding(
                                  padding: const EdgeInsets.only(right: 4),
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.clear_rounded,
                                      color: Colors.grey[500],
                                      size: 22,
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                      _filterDoctors(doctors);
                                      FocusScope.of(context).unfocus();
                                    },
                                  ),
                                )
                              : null,
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 18,
                            horizontal: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: Colors.orange.withOpacity(0.4),
                              width: 2,
                            ),
                          ),
                        ),
                        cursorColor: Colors.orange[600],
                        onChanged: (value) => _filterDoctors(doctors),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Category Filter
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButton<String>(
                        value: _selectedCategory,
                        isExpanded: true,
                        underline: const SizedBox(),
                        items: _availableCategories.map((category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                            _filterDoctors(doctors);
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Doctors List
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_filteredDoctors.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(20),
                          child: Center(
                            child: Text(
                              'No doctors found matching your search',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      if (_filteredDoctors.isNotEmpty)
                        ..._categorizedDoctors.entries
                            .where((entry) => entry.value.isNotEmpty)
                            .map(
                              (entry) => Padding(
                                padding: EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      child: Text(
                                        entry.key,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                    ),
                                    ...entry.value.map(
                                      (doctor) => _buildDoctorCard(doctor),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            ,

                      const SizedBox(height: 30), // spacing between sections
                      // Video section in its own block
                      Padding(
                        padding: EdgeInsets.zero,
                        child: FutureBuilder<Map<String, dynamic>>(
                          future: _adsFuture,
                          builder: (context, adsSnapshot) {
                            if (adsSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            } else if (adsSnapshot.hasError ||
                                !adsSnapshot.hasData) {
                              return const SizedBox();
                            }

                            final youtubeLinks =
                                adsSnapshot
                                    .data!['resultData'][0]['youtubeLinks'] ??
                                [];
                            if (youtubeLinks.isEmpty) return const SizedBox();

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                VideoCarousel(
                                  videoUrls: List<String>.from(youtubeLinks),
                                ),
                              ],
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: Footer(title: "none"),
    );
  }

  Widget _buildDoctorCard(Map<String, String> doctor) {
    final phone = doctor['phone'] ?? '';
    final location = doctor['location'] ?? '';
    final designation = doctor['designation'] ?? 'unknown';
    final imageUrl = doctor['imageUrl'] ?? '';
    final doctorName = doctor['doctorName'] ?? '';
    final doctorId = doctor['doctorId'] ?? '';
    final rating = doctor['rating'] ?? '0';
    final degree = doctor['degree'] ?? '';

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
            // Doctor Image
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
                  mainAxisAlignment: MainAxisAlignment.center,
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

            // Doctor Info + Buttons
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
                    designation,
                    style: const TextStyle(fontSize: 15, color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => _launchCaller(phone),
                        child: _actionButton(
                          FontAwesomeIcons.phone,
                          Colors.lightBlueAccent,
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () => _launchWhatsApp(phone),
                        child: _actionButton(
                          FontAwesomeIcons.whatsapp,
                          Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      _actionIcon(
                        () => _launchMapLink(location),
                        FontAwesomeIcons.mapMarkerAlt,
                        const Color(0xFFFF5722),
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
