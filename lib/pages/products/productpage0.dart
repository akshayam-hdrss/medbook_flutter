import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:medbook/components/common/loading_widget.dart';
import 'package:medbook/pages/products/product_page.dart';
import 'package:medbook/components/ImageCarousel.dart';
import 'package:medbook/components/videoCarousel.dart';
import 'package:medbook/components/footer.dart';

class ProductPage0 extends StatefulWidget {
  final String productId;

  const ProductPage0({super.key, required this.productId});
  // const ProductPage0({super.key});

  @override
  State<ProductPage0> createState() => _ProductPage0State();
}

class _ProductPage0State extends State<ProductPage0> {
  List<Map<String, dynamic>> serviceList = [];
  List<Map<String, dynamic>> filteredList = [];
  List<String> adImages = [];
  List<String> youtubeLinks = [];
  bool isLoading = true;
  String? error;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchData();
    _searchController.addListener(_filterList);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchData() async {
    try {
      final serviceResponse = await http.get(
        Uri.parse(
          'https://medbook-backend-1.onrender.com/api/products/availableProduct/${widget.productId}',
        ),
      );

      final adsResponse = await http.get(
        Uri.parse(
          'https://medbook-backend-1.onrender.com/api/ads/gallery/products?typeId=null&itemId=null',
        ),
      );

      if (serviceResponse.statusCode == 200 && adsResponse.statusCode == 200) {
        final serviceData = jsonDecode(serviceResponse.body);
        final adsData = jsonDecode(adsResponse.body);

        final services = List<Map<String, dynamic>>.from(
          serviceData['resultData'],
        );

        // Extract image and video URLs
        List<String> images = [];
        List<String> videos = [];

        if (adsData['resultData'] != null && adsData['resultData'].isNotEmpty) {
          final adItem = adsData['resultData'][0];

          // Images
          if (adItem['imageUrl'] is List) {
            images = List<String>.from(adItem['imageUrl']);
          } else if (adItem['imageUrl'] is String) {
            images = [adItem['imageUrl']];
          }

          // Videos
          if (adItem['youtubeLinks'] is List) {
            videos = List<String>.from(adItem['youtubeLinks']);
          } else if (adItem['youtubeLinks'] is String) {
            videos = [adItem['youtubeLinks']];
          }
        }

        setState(() {
          serviceList = services;
          filteredList = List<Map<String, dynamic>>.from(services);

          // ✅ Sort by order_no (null values go to the end)
          filteredList.sort((a, b) {
            final orderA = a['order_no'];
            final orderB = b['order_no'];

            if (orderA == null && orderB == null) return 0;
            if (orderA == null) return 1; // null → after non-null
            if (orderB == null) return -1;

            return orderA.compareTo(orderB); // ascending order
          });

          adImages = images;
          youtubeLinks = videos;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  void _filterList() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredList = serviceList.where((item) {
        final name = (item['name'] ?? '').toLowerCase();
        return name.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Product Types",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
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
        ),
      ),
      body: isLoading
          ? const AppLoadingWidget() 
          : error != null
          ? Center(child: Text("Error: $error"))
          : serviceList.isEmpty
          ? const Center(child: Text("No services found"))
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(screenWidth < 600 ? 12 : 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search Bar
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
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
                          hintText: 'Search service types...',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 15,
                          ),
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
                                    _filterList();
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
                              color: const Color(0xFFF37A20).withOpacity(0.6),
                              width: 1.8,
                            ),
                          ),
                        ),
                        onChanged: (_) => _filterList(),
                      ),
                    ),

                    // Image Carousel
                    if (adImages.isNotEmpty) ...[
                      ImageCarousel(imageUrls: adImages),
                      const SizedBox(height: 20),
                    ],

                    // Grid of Services
                    if (filteredList.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 50),
                        child: Column(
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 60,
                              color: Colors.grey.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No results found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try a different search term',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      LayoutBuilder(
                        builder: (context, constraints) {
                          int crossAxisCount = 2;
                          double imageSize = 40;
                          double fontSize = 13;
                          double aspectRatio = 2.1;

                          if (constraints.maxWidth >= 600) {
                            crossAxisCount = 3;
                            imageSize = 56;
                            fontSize = 18;
                            aspectRatio = 2.8;
                          }

                          return GridView.builder(
                            padding: const EdgeInsets.only(top: 10),
                            itemCount: filteredList.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: aspectRatio,
                                ),
                            itemBuilder: (context, index) {
                              final item = filteredList[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProductPage(
                                        productId: item['id'].toString(),
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFFFFFFF),
                                        Color(0xFFF6F6F6),
                                      ],
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
                                        color: Color(
                                          0xFF9A9898,
                                        ).withOpacity(0.05),
                                        blurRadius: 8,
                                        offset: Offset(2, 4),
                                      ),
                                    ],
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
                                              width: imageSize,
                                              height: imageSize,
                                              fit: BoxFit.contain,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                    return Image.asset(
                                                      'lib/Assets/icons/hospital.png',
                                                      width: imageSize,
                                                      height: imageSize,
                                                    );
                                                  },
                                            )
                                          : Image.asset(
                                              'lib/Assets/icons/hospital.png',
                                              width: imageSize,
                                              height: imageSize,
                                            ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          item['name'] ?? '',
                                          style: TextStyle(
                                            fontSize: fontSize,
                                            fontWeight: FontWeight.w600,
                                            height: 1.3,
                                          ),
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                          softWrap: true,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),

                    const SizedBox(height: 30),

                    // Video Carousel (Doctor Interviews)
                    if (youtubeLinks.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Doctor Interviews',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 16),
                          VideoCarousel(videoUrls: youtubeLinks),
                        ],
                      ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: const Footer(title: "none"),
    );
  }
}
