import 'package:flutter/material.dart';
import 'package:medbook/components/ImageCarousel.dart';
import 'package:medbook/components/common/loading_widget.dart';
import 'package:medbook/components/footer.dart';
import 'package:medbook/components/videoCarousel.dart';
import 'package:medbook/pages/Hospitals/HospitalPage2.dart';
import 'package:medbook/utils/api_service.dart';

class HospitalPage1 extends StatefulWidget {
    final String? selectedDistrict;
  final String? selectedArea;
  const HospitalPage1({super.key,this.selectedDistrict, this.selectedArea});


  @override
  _HospitalPage1State createState() => _HospitalPage1State();
}

class _HospitalPage1State extends State<HospitalPage1>
    with TickerProviderStateMixin {
  late Future<List<Map<String, String>>> _hospitals;
  late Future<List<Map<String, dynamic>>> _allHospitals;
  late TabController _tabController;
  late Future<Map<String, dynamic>> _adsData;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _filteredCategories = [];
  List<Map<String, dynamic>> _filteredHospitals = [];
  bool _showHospitalResults = false;

  Future<Map<String, dynamic>> fetchHospitalAds() async {
    try {
      final response = await ApiServiceADS().getData(
        '/api/ads/gallery/hospital?typeId=null&itemId=null',
      );
      if (response['result'] == 'Success' &&
          response['resultData'].isNotEmpty) {
        return response;
      }
      return {'imageUrls': [], 'youtubeLinks': []};
    } catch (e) {
      print('Error fetching hospital ads: $e');
      return {'imageUrls': [], 'youtubeLinks': []};
    }
  }

  Future<List<Map<String, dynamic>>> fetchAllHospitals() async {
    try {
      final response = await ApiService.getData('/hospital');
      if (response['result'] == 'Success' &&
          response['resultData'].isNotEmpty) {
        return List<Map<String, dynamic>>.from(response['resultData']);
      }
      return [];
    } catch (e) {
      print('Error fetching all hospitals: $e');
      return [];
    }
  }

  @override
  void initState() {
    super.initState();
    _hospitals = fetchHospitalCategories();
    _allHospitals = fetchAllHospitals();
    _adsData = fetchHospitalAds();
    _tabController = TabController(length: 1, vsync: this);

    // Initialize filtered lists as empty
    _filteredCategories = [];
    _filteredHospitals = [];
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _filterSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _showHospitalResults = false;
        _filteredCategories = [];
        _filteredHospitals = [];
      });
      return;
    }

    final categories = await _hospitals;
    final allHospitals = await _allHospitals;

    setState(() {
      // Filter categories by name
      _filteredCategories = categories.where((category) {
        final name = category['category']?.toLowerCase() ?? '';
        return name.contains(query.toLowerCase());
      }).toList();

      // Filter hospitals by name and get their hospitalTypeId
      _filteredHospitals = allHospitals.where((hospital) {
        final name = hospital['name']?.toString().toLowerCase() ?? '';
        return name.contains(query.toLowerCase());
      }).toList();

      _showHospitalResults = _filteredHospitals.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return DefaultTabController(
      length: 1,
      child: Scaffold(
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
                ' Speciality Hospitals',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
            ),
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      spreadRadius: 1,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Find hospitals, specialties...',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 15,
                    ),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Icon(
                        Icons.search_rounded,
                        color: Color(
                          0xFFF37A20,
                        ), // Orange color matching your app bar
                        size: 24,
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
                              _filterSearch('');
                              FocusScope.of(context).unfocus();
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Color(0xFFF37A20).withOpacity(0.5),
                        width: 1.5,
                      ),
                    ),
                  ),
                  style: TextStyle(fontSize: 15, color: Colors.grey.shade800),
                  onChanged: _filterSearch,
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildHospitalTab(screenWidth)],
              ),
            ),
          ],
        ),
        bottomNavigationBar: Footer(title: "none"),
      ),
    );
  }

  Widget _buildHospitalTab(double screenWidth) {
    bool isTablet = screenWidth >= 600;
    int crossAxisCount = isTablet ? 3 : 2;
    double spacing = isTablet ? 20.0 : 12.0;
    double fontSize = isTablet ? 22 : 14;
    double iconSize = isTablet ? 50 : 45;
    double aspectRatio = isTablet ? 2.1 : 2.6;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!_showHospitalResults) ...[
            // 🔶 Image Carousel - Full Width
            Padding(
              padding: EdgeInsets.symmetric(vertical: isTablet ? 20.0 : 8.0),
              child: FutureBuilder<Map<String, dynamic>>(
                future: _adsData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const AppLoadingWidget();
                  } else if (snapshot.hasError || !snapshot.hasData) {
                    return const SizedBox();
                  }

                  final adsData = snapshot.data!['resultData'][0];
                  final imageUrls = List<String>.from(
                    adsData['imageUrl'] ?? [],
                  );

                  if (imageUrls.isEmpty) return const SizedBox();

                  return ImageCarousel(imageUrls: imageUrls);
                },
              ),
            ),

            const SizedBox(height: 20),

            // 🔶 Hospital Categories Grid - Full Width
            FutureBuilder<List<Map<String, String>>>(
              future: _hospitals,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const AppLoadingWidget();
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Error loading data'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No categories available'));
                }

                // Use filtered categories if search is active, otherwise use all categories
                final displayCategories = _searchController.text.isNotEmpty
                    ? _filteredCategories
                    : snapshot.data!;

                if (_searchController.text.isNotEmpty &&
                    _filteredCategories.isEmpty) {
                  return const Center(
                    child: Text('No matching categories found'),
                  );
                }

                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: spacing),
                  child: GridView.count(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: spacing,
                    mainAxisSpacing: spacing,
                    shrinkWrap: true,
                    childAspectRatio: aspectRatio,
                    physics: const NeverScrollableScrollPhysics(),
                    children: displayCategories.map((category) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HospitalPage2(
                                hospitalTypeId: category['id']!,
                                district: widget.selectedDistrict, // pass current district
                                area: widget.selectedArea,         // pass current area
                              ),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFFFFF), Color(0xFFF6EDED)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Color(0xFFB6B3B3),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF9A9898).withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(2, 4),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.network(
                                category['icon']!,
                                width: iconSize,
                                height: iconSize,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    'lib/Assets/icons/hospital.png',
                                    width: iconSize,
                                    height: iconSize,
                                  );
                                },
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    category['category']!,
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: fontSize,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 3, // keep single line
                                    overflow: TextOverflow
                                        .ellipsis, // prevent shrinking
                                    softWrap: false,
                                  ),
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

          if (_showHospitalResults) ...[
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Hospital Search Results',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: spacing),
              child: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _filteredHospitals.length,
                itemBuilder: (context, index) {
                  final hospital = _filteredHospitals[index];
                  return Card(
                    elevation: 4,
                    margin: EdgeInsets.only(bottom: spacing),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading:
                          hospital['imageUrl'] != null &&
                              hospital['imageUrl'].toString().isNotEmpty
                          ? Image.network(
                              hospital['imageUrl'].toString(),
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            )
                          : Icon(Icons.local_hospital, size: 40),
                      title: Text(
                        hospital['name']?.toString() ?? 'Unknown Hospital',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: fontSize,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (hospital['area'] != null &&
                              hospital['area'].toString().isNotEmpty)
                            Text('Area: ${hospital['area']}'),
                          if (hospital['phone'] != null &&
                              hospital['phone'].toString().isNotEmpty)
                            Text('Phone: ${hospital['phone']}'),
                        ],
                      ),
                      onTap: () {
                        // Navigate to HospitalPage2 if hospitalTypeId exists
                        if (hospital['hospitalTypeId'] != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HospitalPage2(
                                hospitalTypeId: hospital['hospitalTypeId']
                                    .toString(),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ],

          if (!_showHospitalResults) ...[
            const SizedBox(height: 30),

            // 🔶 Video Carousel - Full Width
            FutureBuilder<Map<String, dynamic>>(
              future: _adsData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const AppLoadingWidget();
                } else if (snapshot.hasError || !snapshot.hasData) {
                  return const SizedBox();
                }

                final adsData = snapshot.data!['resultData'][0];
                final youtubeLinks = List<String>.from(
                  adsData['youtubeLinks'] ?? [],
                );

                if (youtubeLinks.isEmpty) return const SizedBox();

                return VideoCarousel(videoUrls: youtubeLinks);
              },
            ),

            const SizedBox(height: 30),
          ],
        ],
      ),
    );
  }
}
