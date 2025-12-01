import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:medbook/components/Footer.dart';
import 'package:medbook/components/ImageCarousel.dart';
import 'package:medbook/components/common/loading_widget.dart';
import 'package:medbook/components/videoCarousel.dart';
import 'package:medbook/pages/services/service_page.dart';
import 'package:http/http.dart' as http;

class ServicePage0 extends StatefulWidget {
  final String serviceId;

  const ServicePage0({super.key, required this.serviceId});

  @override
  State<ServicePage0> createState() => _ServicePage0State();
}

class _ServicePage0State extends State<ServicePage0> {
  List<dynamic>? serviceTypes;
  List<String> adImages = [];
  List<String> adVideos = [];
  bool isLoading = true;
  String? error;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // print("Received Service ID: ${widget.serviceId}");
    loadServiceTypes();
  }

  Future<void> loadServiceTypes() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://medbook-backend-1.onrender.com/api/services/available-services/${widget.serviceId}',
        ),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        // Convert to list and sort
        List<dynamic> sortedList = List.from(jsonData['resultData']);
        sortedList.sort((a, b) {
          final aOrder = a['order_no'];
          final bOrder = b['order_no'];

          if (aOrder == null && bOrder == null) return 0; // both null → equal
          if (aOrder == null) return 1; // a is null → goes after b
          if (bOrder == null) return -1; // b is null → goes after a

          return (aOrder as int).compareTo(bOrder as int); // normal ascending
        });

        setState(() {
          serviceTypes = sortedList;
        });

        await fetchHospitalAds(); // Load carousel after services
      } else {
        throw Exception('Failed to load service types');
      }
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchHospitalAds() async {
    final response = await http.get(
      Uri.parse(
        'https://medbook-backend-1.onrender.com/api/ads/gallery/services?typeId=null&itemId=null',
      ),
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final resultData = jsonData['resultData'] as List;

      List<String> imageUrls = [];
      List<String> videoUrls = [];

      for (var item in resultData) {
        if (item['imageUrl'] is List) {
          imageUrls.addAll(List<String>.from(item['imageUrl']));
        }
        if (item['youtubeLinks'] is List) {
          videoUrls = List<String>.from(item['youtubeLinks'] ?? []);
        } else if (item['youtubeLinks'] is String) {
          videoUrls = [item['youtubeLinks']];
        }
      }

      setState(() {
        adImages = imageUrls;
        adVideos = videoUrls;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Healthcare Services',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
          ),
        ),
      ),

      body: isLoading
          ? const AppLoadingWidget()
          : error != null
          ? Center(child: Text('Error: $error'))
          : serviceTypes == null || serviceTypes!.isEmpty
          ? const Center(child: Text('No services available.'))
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(screenWidth < 600 ? 12 : 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 12),
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
                          hintText: 'Search Services...',
                          prefixIcon: const Padding(
                            padding: EdgeInsets.all(14),
                            child: Icon(
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
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    FocusScope.of(context).unfocus();
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),

                    if (adImages.isNotEmpty) ...[
                      ImageCarousel(imageUrls: adImages),
                      const SizedBox(height: 20),
                    ],

                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isTablet = constraints.maxWidth >= 600;
                        final crossAxisCount = isTablet ? 3 : 2;
                        final iconSize = isTablet ? 50.0 : 45.0;
                        final fontSize = isTablet ? 18.0 : 13.0;

                        return GridView.count(
                          crossAxisCount: crossAxisCount,
                          padding: const EdgeInsets.only(top: 16),
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          childAspectRatio: isTablet ? 2.0 : 2.2,
                          children: serviceTypes!.map((item) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ServicePage(
                                      serviceId: item['id'].toString(),
                                    ),
                                  ),
                                );
                              },

                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFF7F5F5),
                                      Color(0xFFFAF0F0),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color.fromARGB(
                                      255,
                                      182,
                                      179,
                                      179,
                                    ),
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                child: Row(
                                  children: [
                                    (item['imageUrl'] != null &&
                                            item['imageUrl']
                                                .toString()
                                                .isNotEmpty)
                                        ? Image.network(
                                            item['imageUrl'],
                                            width: iconSize,
                                            height: iconSize,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                                  return Image.asset(
                                                    'lib/Assets/icons/hospital.png',
                                                    width: iconSize,
                                                    height: iconSize,
                                                  );
                                                },
                                          )
                                        : Image.asset(
                                            'lib/Assets/icons/hospital.png',
                                            width: iconSize,
                                            height: iconSize,
                                          ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        item['name'] ?? 'Unnamed',
                                        style: TextStyle(
                                          fontSize: fontSize,
                                          fontWeight: FontWeight.w600,
                                          height:
                                              1.3, // forces consistent line height
                                        ),
                                        maxLines: null,
                                        overflow: TextOverflow.visible,
                                        softWrap: true,
                                        strutStyle: StrutStyle(
                                          fontSize: fontSize,
                                          height: 1.3, // same as above
                                          forceStrutHeight: true,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),

                    if (adVideos.isNotEmpty) ...[
                      const SizedBox(height: 30),
                      VideoCarousel(videoUrls: adVideos),
                    ],
                  ],
                ),
              ),
            ),
      bottomNavigationBar: const Footer(title: "none"),
    );
  }
}
