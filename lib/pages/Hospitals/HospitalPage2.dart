import 'package:flutter/material.dart';
import 'package:medbook/components/Footer.dart';
import 'package:medbook/components/common/loading_widget.dart';
import 'package:medbook/pages/Hospitals/HospitalInfo.dart';
import 'package:medbook/utils/api_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:medbook/pages/Hospitals/HospitalPage3.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medbook/components/ImageCarousel.dart';

class HospitalPage2 extends StatefulWidget {
  final String hospitalTypeId;
  final String ? district;
  final String ? area;

  const HospitalPage2 ({super.key, required this.hospitalTypeId ,this.district,this.area});

  @override
  _HospitalPage2State createState() => _HospitalPage2State();
}

class _HospitalPage2State extends State<HospitalPage2> {
  late Future<List<Map<String, String>>> _hospitals;
  late Future<List<String>> _adsImages;
  final TextEditingController _searchController = TextEditingController();
  String _selectedArea = 'All Areas';
  List<String> _availableAreas = ['All Areas'];
  List<Map<String, String>> _filteredHospitals = [];

  @override
  void initState() {
    super.initState();
    _hospitals = fetchHospitalsByType(widget.hospitalTypeId).then((hospitals) {
      _filteredHospitals = List.from(hospitals);
      _updateAvailableAreas(hospitals);
      return hospitals;
    });
    _adsImages = fetchHospitalAds();
  }

  void _updateAvailableAreas(List<Map<String, String>> hospitals) {
    final areas = hospitals
        .map((h) => h['area'] ?? '')
        .where((area) => area.isNotEmpty)
        .toSet()
        .toList();
    setState(() {
      _availableAreas = ['All Areas', ...areas];
    });
  }

  Future<List<String>> fetchHospitalAds() async {
    try {
      final response = await ApiServiceADS().getData(
        '/api/ads/gallery/hospital?typeId=${widget.hospitalTypeId}&itemId=null',
      );
      if (response['result'] == 'Success' &&
          response['resultData'].isNotEmpty) {
        final List<String> images = [];
        for (var item in response['resultData']) {
          if (item['imageUrl'] != null) {
            images.addAll(List<String>.from(item['imageUrl']));
          }
        }
        return images;
      }
    } catch (e) {
      print('Error fetching ads: $e');
    }
    return [];
  }

  void _filterHospitals() {
    _hospitals.then((hospitals) {
      setState(() {
        _filteredHospitals = hospitals.where((hospital) {
          final nameMatch =
              _searchController.text.isEmpty ||
              (hospital['name']?.toLowerCase().contains(
                    _searchController.text.toLowerCase(),
                  ) ??
                  false);
          final areaMatch =
              _selectedArea == 'All Areas' || hospital['area'] == _selectedArea;
          return nameMatch && areaMatch;
        }).toList();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _launchMapLink(String mapLink) async {
    if (mapLink.isEmpty) return;
    final uri = Uri.parse(mapLink);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $mapLink';
    }
  }

  // Future<void> _launchWhatsApp(String phone) async {
  //   if (phone.isEmpty) return;
  //   final cleanPhone = phone.replaceAll(' ', '').replaceAll('+', '');
  //   final url = Uri.parse("https://wa.me/$cleanPhone");
  //   if (await canLaunchUrl(url)) {
  //     await launchUrl(url, mode: LaunchMode.externalApplication);
  //   } else {
  //     throw 'Could not launch WhatsApp for $cleanPhone';
  //   }
  // }

  Future<void> _launchCaller(String phone) async {
    if (phone.isEmpty) return;
    final Uri callUri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(callUri)) {
      await launchUrl(callUri);
    } else {
      throw 'Could not call $phone';
    }
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
            iconTheme: const IconThemeData(color: Colors.white),
            title: const Text(
              'List of Hospitals',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.transparent,
            centerTitle: true,
            elevation: 0,
          ),
        ),
      ),
      bottomNavigationBar: Footer(title: "none"),
      body: FutureBuilder<List<Map<String, String>>>(
        future: _hospitals,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppLoadingWidget();
            
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading hospitals'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No hospitals available in this Location'),
            );
          }

          return Column(
            children: [
              // Search and Filter Section
              // Enhanced Search and Filter Section
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
                    // Modern Search Bar with improved styling
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
                          hintText: 'Search by hospital name...',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 15,
                          ),
                          prefixIcon: Container(
                            padding: const EdgeInsets.all(14),
                            child: Icon(
                              Icons.search_rounded,
                              color: Color(
                                0xFFF37A20,
                              ), // Matching your app theme
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
                                    _filterHospitals();
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
                        onChanged: (value) => _filterHospitals(),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Area Filter Dropdown with improved design
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
                          setState(() {
                            _selectedArea = value!;
                            _filterHospitals();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Hospital List
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Carousel
                      FutureBuilder<List<String>>(
                        future: _adsImages,
                        builder: (context, adSnap) {
                          if (adSnap.connectionState ==
                              ConnectionState.waiting) {
                            return const SizedBox(
                              height: 220,
                              child: Center(child: AppLoadingWidget()),
                            );
                          } else if (adSnap.hasError ||
                              !adSnap.hasData ||
                              adSnap.data!.isEmpty) {
                            return const SizedBox();
                          }
                          return ImageCarousel(imageUrls: adSnap.data!);
                        },
                      ),
                      const SizedBox(height: 16),
                      // Hospitals List or Empty State
                      if (_filteredHospitals.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No hospitals found',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Try adjusting your search or filter criteria',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      else
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isTablet = constraints.maxWidth >= 600;
                            final itemWidth = isTablet
                                ? (constraints.maxWidth / 2) - 16
                                : constraints.maxWidth;

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: Wrap(
                                spacing: 16,
                                runSpacing: 16,
                                children: _filteredHospitals.map((hospital) {
                                  final phone = hospital['phone'] ?? '';
                                  final imageUrl = hospital['imageUrl'] ?? '';
                                  final mapLink = hospital['mapLink'] ?? '';

                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => HospitalPage3(
                                            hospitalId: hospital['id']!,
                                            hospitalTypeId:
                                                widget.hospitalTypeId,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      width: itemWidth,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.05,
                                            ),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 100,
                                            height: 100,
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade200,
                                              shape: BoxShape.rectangle,
                                              image: DecorationImage(
                                                fit: BoxFit.cover,
                                                image: imageUrl.isNotEmpty
                                                    ? NetworkImage(imageUrl)
                                                    : const AssetImage(
                                                            'lib/Assets/icons/hospital.png',
                                                          )
                                                          as ImageProvider,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  hospital['name'] ?? '',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                // Text(
                                                //   hospital['doctor'] ?? '',
                                                //   style: const TextStyle(
                                                //     fontSize: 14,
                                                //     fontWeight: FontWeight.w500,
                                                //   ),
                                                // ),
                                                // const SizedBox(height: 4),
                                                Text(
                                                  hospital['area'] ?? '',
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                                const SizedBox(height: 10),
                                                Row(
                                                  children: [
                                                    _actionIcon(
                                                      () =>
                                                          _launchCaller(phone),
                                                      FontAwesomeIcons.phone,
                                                      Colors.blue,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    _actionIcon(
                                                      () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                HospitalInfoPage(
                                                                  hospitalId:
                                                                      hospital['id']!,
                                                                   hospitalname:hospital['name'] ?? 'Hospital',
                                                                     // ✅ Passing hospitalId
                                                                ),
                                                          ),
                                                        );
                                                      },
                                                      FontAwesomeIcons
                                                          .infoCircle,
                                                      Colors.orange,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    _actionIcon(
                                                      () => _launchMapLink(
                                                        mapLink,
                                                      ),
                                                      FontAwesomeIcons
                                                          .mapMarkerAlt,
                                                      const Color(0xFFFF5722),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
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