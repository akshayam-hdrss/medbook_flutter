import 'package:flutter/material.dart';
import 'package:medbook/components/Footer.dart';
import 'package:medbook/components/ImageCarousel.dart';
import 'package:medbook/components/common/loading_widget.dart';
import 'package:medbook/components/videoCarousel.dart';
import 'package:medbook/pages/Traditional/Traditional2.dart';
import 'package:medbook/utils/api_service.dart';

class Traditional1 extends StatefulWidget {
    final String? selectedDistrict;
  final String? selectedArea;
  const Traditional1({super.key,this.selectedDistrict, this.selectedArea});

  @override
  _Traditional1State createState() => _Traditional1State();
}

class _Traditional1State extends State<Traditional1>
    with TickerProviderStateMixin {
  late Future<Map<String, dynamic>> _adsData;
  List<dynamic> _allTypes = [];
  List<dynamic> _filteredTypes = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _adsData = fetchTraditionalAds();
    _fetchTraditionalTypes();
    _searchController.addListener(_filterTypes);

      print('📍 Passed District: ${widget.selectedDistrict}');
  print('📍 Passed Area: ${widget.selectedArea}');
  }

  Future<void> _fetchTraditionalTypes() async {
    try {
      final types = await ApiServicetraditional.fetchTraditionalTypes();
      setState(() {
        _allTypes = types;
        _filteredTypes = types;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching traditional types: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<Map<String, dynamic>> fetchTraditionalAds() async {
    try {
      final response = await ApiServiceADS().getData(
        '/api/ads/gallery/traditional?typeId=null&itemId=null',
      );
      if (response['result'] == 'Success' &&
          response['resultData'].isNotEmpty) {
        return response;
      }
      return {'imageUrls': [], 'youtubeLinks': []};
    } catch (e) {
      print('Error fetching traditional ads: $e');
      return {'imageUrls': [], 'youtubeLinks': []};
    }
  }

  void _filterTypes() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredTypes = _allTypes.where((type) {
        final name = type['name']?.toLowerCase() ?? '';
        return name.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    bool isTablet = screenWidth >= 600;
    int crossAxisCount = isTablet ? 3 : 2;
    double spacing = isTablet ? 20.0 : 12.0;
    double fontSize = isTablet ? 18 : 14;
    double iconSize = isTablet ? 42 : 32;
    double aspectRatio = isTablet ? 3.2 : 2.6;

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
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            automaticallyImplyLeading: true,
            title: const Text(
              'Traditional Treatments',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 🔍 Search Bar
            // 🔍 Search Bar (Only Search, No Dropdown)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              child: Container(
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
                    hintText: 'Search by name',
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
                              _filterTypes();
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
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade800),
                  onChanged: (value) => _filterTypes(),
                ),
              ),
            ),

            // 🔶 Image Carousel
            Padding(
              padding: EdgeInsets.symmetric(vertical: isTablet ? 16.0 : 8.0),
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

            // 🔶 Grid Cards
            _isLoading
                ? const AppLoadingWidget()
                : _filteredTypes.isEmpty
                ? const Center(child: Text('No matching treatments found'))
                : Padding(
                    padding: EdgeInsets.symmetric(horizontal: spacing),
                    child: GridView.count(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: spacing,
                      mainAxisSpacing: spacing,
                      childAspectRatio: aspectRatio,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: _filteredTypes.map((type) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Traditional2(
                                  traditionalTypeId: type['id'].toString(),
                                   district: widget.selectedDistrict,  // <-- pass district
                                    area: widget.selectedArea,      // <-- pass area
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
                                  type['image'] ?? '',
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
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        type['name'] ?? '',
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: fontSize,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

            const SizedBox(height: 30),

            // 🔶 Video Carousel
            FutureBuilder<Map<String, dynamic>>(
              future: _adsData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const AppLoadingWidget();
                  // return const Center(child: CircularProgressIndicator());
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
        ),
      ),
      bottomNavigationBar: Footer(title: "none"),
    );
  }
}
