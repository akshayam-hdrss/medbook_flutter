// search and filter functionality

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:medbook/components/Footer.dart';
import 'package:medbook/components/ImageCarousel.dart';
import 'package:medbook/components/common/loading_widget.dart';
import 'package:medbook/components/videoCarousel.dart';
import 'package:medbook/pages/Doctors/Doctors_page2.dart';
import 'package:medbook/utils/api_service.dart';
import 'package:http/http.dart' as http;

class DoctorsPage1 extends StatefulWidget {
final String? selectedDistrict ; // or from your filter
final String? selectedArea  ;     
  // or from your filter  
  const DoctorsPage1({super.key,this.selectedDistrict, this.selectedArea});

  @override
  State<DoctorsPage1> createState() => _DoctorsPage1State();
}

class _DoctorsPage1State extends State<DoctorsPage1> {
  late Future<List<Map<String, String>>> _doctorTypes;
  List<String> carouselImages = [];
  List<String> youtubeLinks = [];
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _filteredDoctors = [];

  @override
  void initState() {
    super.initState();
    _doctorTypes = fetchDoctorTypes().then((doctors) {
      setState(() {
        _filteredDoctors = List.from(doctors);
      });
      return doctors;
    });
    _fetchCarouselData();
  }

  Future<void> _fetchCarouselData() async {
    try {
      final response = await http.get(
        Uri.parse(
          "https://medbook-backend-1.onrender.com/api/ads/gallery/doctor?typeId=null&itemId=null",
        ),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final resultData = data["resultData"];
        if (resultData != null && resultData is List && resultData.isNotEmpty) {
          final images = resultData[0]["imageUrl"];
          if (images is List) {
            setState(() {
              carouselImages = List<String>.from(images);
            });
          }
          
          final links = resultData[0]["youtubeLinks"];
          if (links is List) {
            setState(() {
              youtubeLinks = List<String>.from(links);
            });
          }
        }
      } else {
        print("Error loading carousel data");
      }
    } catch (e) {
      print("Error fetching carousel data: $e");
    }
  }

  void _filterDoctors(List<Map<String, String>> allDoctors) {
    setState(() {
      _filteredDoctors = allDoctors.where((doctor) {
        return _searchController.text.isEmpty ||
            (doctor['category']?.toLowerCase().contains(
                  _searchController.text.toLowerCase(),
                ) ??
                false);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

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
            title: const Text(
              "Specializations",
              style: TextStyle(color: Colors.white),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Color.fromARGB(255, 251, 251, 251)),
          ),
        ),
      ),
      body: FutureBuilder<List<Map<String, String>>>(
        future: _doctorTypes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
           return const AppLoadingWidget();
            // return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("Error loading data"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No doctor types available"));
          }

          final doctors = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              children: [
                // Search Bar Only
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Container(
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
                        hintText: 'Search specializations...',
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
                ),
                
                Padding(
                  padding: EdgeInsets.all(screenWidth < 600 ? 8.0 : 16.0),
                  child: ImageCarousel(imageUrls: carouselImages),
                ),
                
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isTablet = constraints.maxWidth >= 600;
                    final crossAxisCount = isTablet ? 3 : 2;
                    final iconSize = isTablet ? 48.0 : 32.0;
                    final fontSize = isTablet ? 20.0 : 14.0;
                    final cardHeight = isTablet ? 100.0 : 80.0;

                    return Padding(
                      padding: const EdgeInsets.all(12),
                      child: _filteredDoctors.isEmpty
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.only(top: 50),
                                child: Text(
                                  'No specializations found',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            )
                          : GridView.count(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              childAspectRatio: isTablet ? 2.2 : 2.8,
                              children: _filteredDoctors.map((doctor) {
                                return _buildDoctorCard(
                                  title: doctor['category'] ?? '',
                                  iconUrl: doctor['icon'] ?? '',
                                  id: doctor['id'] ?? '',
                                  iconSize: iconSize,
                                  fontSize: fontSize,
                                  cardHeight: cardHeight,
                                );
                              }).toList(),
                            ),
                    );
                  },
                ),
                
                const SizedBox(height: 30),
                VideoCarousel(videoUrls: youtubeLinks),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const Footer(title: "none"),
    );
  }

  Widget _buildDoctorCard({
    required String title,
    required String iconUrl,
    required String id,
    required double iconSize,
    required double fontSize,
    required double cardHeight,
  }) {
    return GestureDetector(
      onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DoctorsPage2(
            doctorTypeId: id,
            selectedDistrict: widget.selectedDistrict, // pass your district value
            selectedArea: widget.selectedArea,         // pass your area value
          ),
        ),
      );
    },
      child: Container(
        height: cardHeight,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color.fromARGB(255, 255, 255, 255), Color.fromARGB(255, 246, 237, 237)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Color.fromARGB(255, 182, 179, 179),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB(255, 154, 152, 152).withOpacity(0.05),
              blurRadius: 8,
              offset: Offset(2, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.network(
              iconUrl.isNotEmpty
                  ? iconUrl
                  : 'https://cdn-icons-png.flaticon.com/512/3771/3771391.png',
              width: iconSize,
              height: iconSize,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.medical_services, size: iconSize);
              },
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}