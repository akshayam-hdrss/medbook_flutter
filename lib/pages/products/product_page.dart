// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:medbook/components/videoCarousel.dart';
// import 'package:medbook/pages/products/product_page2.dart';
// import 'package:medbook/utils/api_service.dart';
// import 'package:medbook/components/ImageCarousel.dart';

// class ProductPage extends StatefulWidget {
//   final String productId;

//   const ProductPage({super.key, required this.productId});

//   @override
//   State<ProductPage> createState() => _ProductPageState();
// }

// class _ProductPageState extends State<ProductPage> {
//   List<Map<String, dynamic>> productList = [];
//   List<String> adImages = [];
//   List<String> youtubeLinks = [];
//   bool isLoading = true;
//   String? error;

//   @override
//   void initState() {
//     super.initState();
//     loadProductDetails();
//   }

//   Future<void> loadProductDetails() async {
//     try {
//       final data = await ApiService.fetchProductById(widget.productId);
//       final adsResponse = await fetchProductAds();

//       setState(() {
//         productList = List<Map<String, dynamic>>.from(data['resultData']);

//         // Safely extract image URLs
//         if (adsResponse['resultData'] != null &&
//             adsResponse['resultData'].isNotEmpty) {
//           final firstItem = adsResponse['resultData'][0];

//           // Handle image URLs (could be List or String)
//           if (firstItem['imageUrl'] is List) {
//             adImages = List<String>.from(firstItem['imageUrl'] ?? []);
//           } else if (firstItem['imageUrl'] is String) {
//             adImages = [firstItem['imageUrl']];
//           }

//           // Handle YouTube links (could be List or String)
//           if (firstItem['youtubeLinks'] is List) {
//             youtubeLinks = List<String>.from(firstItem['youtubeLinks'] ?? []);
//           } else if (firstItem['youtubeLinks'] is String) {
//             youtubeLinks = [firstItem['youtubeLinks']];
//           }
//         }

//         isLoading = false;
//       });
//     } catch (e) {
//       print("Error fetching product details: $e");
//       setState(() {
//         error = e.toString();
//         isLoading = false;
//       });
//     }
//   }

//   Future<Map<String, dynamic>> fetchProductAds() async {
//     try {
//       final response = await http.get(
//         Uri.parse(
//           'https://medbook-backend-1.onrender.com/api/ads/gallery/products?typeId=null&itemId=null',
//         ),
//       );

//       if (response.statusCode == 200) {
//         return jsonDecode(response.body);
//       } else {
//         throw Exception('Failed to load product ads: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Error fetching ads: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;

//     return Scaffold(
//       appBar: AppBar(
//       centerTitle: true,
//       backgroundColor: Colors.transparent, // Important to show gradient
//       elevation: 0, // Optional: remove shadow
//       title: const Text(
//         "Product Details",
//         style: TextStyle(
//           color: Colors.white,
//           fontWeight: FontWeight.bold,
//           fontSize: 20,
//         ),
//       ),
//       iconTheme: const IconThemeData(color: Colors.white), // White back icon
//       flexibleSpace: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               Color.fromARGB(255, 225, 119, 20), // Orange
//               Color.fromARGB(255, 239, 48, 34),  // Red
//             ],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//       ),
//     ),
//       body: isLoading
//           ? const Center(child: )
//           : error != null
//               ? Center(child: Text("Error: $error"))
//               : productList.isEmpty
//                   ? const Center(child: Text("No products found"))
//                   : SingleChildScrollView(
//                       child: Padding(
//                         padding: EdgeInsets.all(screenWidth < 600 ? 12 : 20),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             if (adImages.isNotEmpty) ...[
//                               ImageCarousel(imageUrls: adImages),
//                               const SizedBox(height: 20),
//                             ],

//                             LayoutBuilder(
//   builder: (context, constraints) {
//     int crossAxisCount = 2;
//     double imageSize = 40;
//     double fontSize = 16;

//     if (constraints.maxWidth >= 600) {
//       crossAxisCount = 3;
//       imageSize = 56;
//       fontSize = 18;
//     }

//     return GridView.builder(
//       padding: const EdgeInsets.only(top: 16),
//       itemCount: productList.length,
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: crossAxisCount,
//         crossAxisSpacing: 16,
//         mainAxisSpacing: 16,
//         childAspectRatio: 3, // wider card
//       ),
//       itemBuilder: (context, index) {
//         final item = productList[index];
//         final productTypeId = item['id'].toString();

//         return GestureDetector(
//           onTap: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => ProductPage2(productTypeId: productTypeId),
//               ),
//             );
//           },
//           child: Container(
//             decoration: BoxDecoration(
//               gradient: const LinearGradient(
//                 colors: [Color.fromARGB(255, 255, 255, 255), Color.fromARGB(255, 246, 237, 237)],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               borderRadius: BorderRadius.circular(20),
//               border: Border.all(
//                 color: const Color.fromARGB(255, 182, 179, 179),
//                 width: 1,
//               ),
//               boxShadow: [
//                 BoxShadow(
//                   color: const Color.fromARGB(255, 154, 152, 152).withOpacity(0.05),
//                   blurRadius: 8,
//                   offset: const Offset(2, 4),
//                 ),
//               ],
//             ),
//             padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//             child: Row(
//               children: [
//                 (item['imageUrl'] != null && item['imageUrl'].toString().isNotEmpty)
//                     ? Image.network(
//                         item['imageUrl'],
//                         width: imageSize,
//                         height: imageSize,
//                         fit: BoxFit.contain,
//                         errorBuilder: (context, error, stackTrace) {
//                           return Image.asset(
//                             'lib/Assets/icons/hospital.png',
//                             width: imageSize,
//                             height: imageSize,
//                           );
//                         },
//                       )
//                     : Image.asset(
//                         'lib/Assets/icons/hospital.png',
//                         width: imageSize,
//                         height: imageSize,
//                       ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Align(
//                     alignment: Alignment.centerLeft,
//                     child: FittedBox(
//                       fit: BoxFit.scaleDown,
//                       alignment: Alignment.centerLeft,
//                       child: Text(
//                         item['name'] ?? 'No Name',
//                         style: TextStyle(
//                           color: Colors.black87,
//                           fontSize: fontSize,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   },
// ),

//                             const SizedBox(height: 30),

//                             if (youtubeLinks.isNotEmpty)
//                               VideoCarousel(videoUrls: youtubeLinks),
//                           ],
//                         ),
//                       ),
//                     ),
//     );
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:medbook/components/common/loading_widget.dart';
import 'package:medbook/components/footer.dart';
import 'package:medbook/components/videoCarousel.dart';
import 'package:medbook/pages/products/product_page2.dart';
import 'package:medbook/utils/api_service.dart';
import 'package:medbook/components/ImageCarousel.dart';

class ProductPage extends StatefulWidget {
  final String productId;

  const ProductPage({super.key, required this.productId});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  List<Map<String, dynamic>> productList = [];
  List<Map<String, dynamic>> filteredProducts = [];
  List<String> adImages = [];
  List<String> youtubeLinks = [];
  bool isLoading = true;
  String? error;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadProductDetails();
    _searchController.addListener(_filterProducts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> loadProductDetails() async {
    try {
      final data = await ApiService.fetchProductById(widget.productId);
      final adsResponse = await fetchProductAds();

      setState(() {
        productList = List<Map<String, dynamic>>.from(data['resultData']);
        filteredProducts = List<Map<String, dynamic>>.from(data['resultData']);

        // Safely extract image URLs
        if (adsResponse['resultData'] != null &&
            adsResponse['resultData'].isNotEmpty) {
          final firstItem = adsResponse['resultData'][0];

          // Handle image URLs (could be List or String)
          if (firstItem['imageUrl'] is List) {
            adImages = List<String>.from(firstItem['imageUrl'] ?? []);
          } else if (firstItem['imageUrl'] is String) {
            adImages = [firstItem['imageUrl']];
          }

          // Handle YouTube links (could be List or String)
          if (firstItem['youtubeLinks'] is List) {
            youtubeLinks = List<String>.from(firstItem['youtubeLinks'] ?? []);
          } else if (firstItem['youtubeLinks'] is String) {
            youtubeLinks = [firstItem['youtubeLinks']];
          }
        }

        isLoading = false;
      });
    } catch (e) {
      print("Error fetching product details: $e");
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  void _filterProducts() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredProducts = productList.where((product) {
        final name = (product['name'] ?? '').toLowerCase();
        return name.contains(query);
      }).toList();
    });
  }

  Future<Map<String, dynamic>> fetchProductAds() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://medbook-backend-1.onrender.com/api/ads/gallery/products?typeId=null&itemId=null',
        ),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load product ads: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching ads: $e');
    }
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
          "Product Details",
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
          : productList.isEmpty
          ? const Center(child: Text("No products found"))
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(screenWidth < 600 ? 12 : 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search Bar Only
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
                          hintText: 'Search products...',
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
                                    _filterProducts();
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
                        onChanged: (_) => _filterProducts(),
                      ),
                    ),

                    if (adImages.isNotEmpty) ...[
                      ImageCarousel(imageUrls: adImages),
                      const SizedBox(height: 20),
                    ],

                    if (filteredProducts.isEmpty)
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
                          double fontSize = 12;

                          if (constraints.maxWidth >= 600) {
                            crossAxisCount = 3;
                            imageSize = 56;
                            fontSize = 18;
                          }

                          return GridView.builder(
                            padding: const EdgeInsets.only(top: 16),
                            itemCount: filteredProducts.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 2.2,
                                ),
                            itemBuilder: (context, index) {
                              final item = filteredProducts[index];
                              final productTypeId = item['id'].toString();

                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProductPage2(
                                        productTypeId: productTypeId,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color.fromARGB(255, 255, 255, 255),
                                        Color.fromARGB(255, 246, 237, 237),
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
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color.fromARGB(
                                          255,
                                          154,
                                          152,
                                          152,
                                        ).withOpacity(0.05),
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
                            },
                          );
                        },
                      ),

                    const SizedBox(height: 30),

                    if (youtubeLinks.isNotEmpty)
                      Container(
                        // margin: const EdgeInsets.symmetric(vertical: 30),
                        padding: EdgeInsets.zero,
                        decoration: BoxDecoration(
                          // color: Colors.white,
                          // borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
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
                      ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: const Footer(title: "none"),
    );
  }
}
