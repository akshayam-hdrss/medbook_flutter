// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:medbook/components/Footer.dart';

// class OffersPage extends StatefulWidget {
//   const OffersPage({super.key});

//   @override
//   State<OffersPage> createState() => _OffersPageState();
// }

// class _OffersPageState extends State<OffersPage> {
//   List<Map<String, dynamic>> _offers = [];
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     fetchOffers();
//   }

//   Future<void> fetchOffers() async {
//     final response = await http.get(
//         Uri.parse('https://medbook-backend-1.onrender.com/api/offers'));

//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       if (data['result'] == 'Success') {
//         List<Map<String, dynamic>> offers = [];

//         for (var offer in data['resultData']) {
//           List<String> galleryImages =
//               List<String>.from(offer['gallery'] ?? []);
//           if (galleryImages.isNotEmpty) {
//             offers.add({
//               'name': offer['name'] ?? 'Untitled',
//               'gallery': galleryImages,
//             });
//           }
//         }

//         setState(() {
//           _offers = offers;
//           _isLoading = false;
//         });
//       } else {
//         setState(() => _isLoading = false);
//       }
//     } else {
//       setState(() => _isLoading = false);
//       throw Exception('Failed to load offers');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey.shade100,
//      appBar: PreferredSize(
//   preferredSize: const Size.fromHeight(kToolbarHeight),
//   child: Container(
//     decoration: const BoxDecoration(
//       gradient: LinearGradient(
//         colors: [
//           Color.fromARGB(255, 225, 119, 20), // Orange
//           Color.fromARGB(255, 239, 48, 34),  // Red
//         ],
//         stops: [0.0, 0.5],
//         begin: Alignment.topLeft,
//         end: Alignment.bottomRight,
//       ),
//     ),
//     child: AppBar(
//       title: const Text(
//         "Exclusive Offers",
//         style: TextStyle(color: Colors.white),
//       ),
//       centerTitle: true,
//       backgroundColor: Colors.transparent, // Make AppBar background transparent
//       elevation: 0, // Remove shadow so gradient shows cleanly
//       iconTheme: const IconThemeData(
//         color: Colors.white, // Ensure icons are white
//       ),
//     ),
//   ),
// ),

//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _offers.isEmpty
//               ? const Center(child: Text("No offers available"))
//               : ListView.builder(
//                   padding: const EdgeInsets.all(16),
//                   itemCount: _offers.length,
//                   itemBuilder: (context, index) {
//                     final offer = _offers[index];
//                     final name = offer['name'];
//                     final images = offer['gallery'] as List<String>;

//                     return Card(
//                       elevation: 6,
//                       margin: const EdgeInsets.only(bottom: 24),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // Offer Title
//                          // Offer Title
// Padding(
//   padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
//   child: Center(
//     child: Text(
//       name,
//       textAlign: TextAlign.center,
//       style: const TextStyle(
//         fontSize: 20,
//         fontWeight: FontWeight.bold,
//         color: Colors.deepOrange,
//       ),
//     ),
//   ),
// ),

//                           // Carousel
//                           ClipRRect(
//                             borderRadius: const BorderRadius.vertical(
//                                 bottom: Radius.circular(16)),
//                             child: CarouselSlider(
//                               options: CarouselOptions(
//                                 height: 200,
//                                 autoPlay: true,
//                                 autoPlayInterval: const Duration(seconds: 3),
//                                 enlargeCenterPage: true,
//                                 viewportFraction: 0.9,
//                               ),
//                               items: images.map((url) {
//                                 return Container(
//                                   margin:
//                                       const EdgeInsets.symmetric(horizontal: 6),
//                                   decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.circular(12),
//                                     image: DecorationImage(
//                                       image: NetworkImage(url),
//                                       fit: BoxFit.cover,
//                                     ),
//                                   ),
//                                 );
//                               }).toList(),
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//                 ),
//                 bottomNavigationBar: Footer(title: "offers"),
//     );
//   }
// }

// Nantha updated

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:medbook/components/Footer.dart';
import 'package:medbook/components/common/loading_widget.dart';

class OffersPage extends StatefulWidget {
  const OffersPage({super.key});

  @override
  State<OffersPage> createState() => _OffersPageState();
}

class _OffersPageState extends State<OffersPage> {
  List<Map<String, dynamic>> _offers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOffers();
  }

  Future<void> fetchOffers() async {
    final response = await http.get(
      Uri.parse('https://medbook-backend-1.onrender.com/api/offers'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['result'] == 'Success') {
        List<Map<String, dynamic>> offers = [];

        for (var offer in data['resultData']) {
          List<String> galleryImages = List<String>.from(
            offer['gallery'] ?? [],
          );
          if (galleryImages.isNotEmpty) {
            offers.add({
              'name': offer['name'] ?? 'Untitled',
              'gallery': galleryImages,
            });
          }
        }

        setState(() {
          _offers = offers;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } else {
      setState(() => _isLoading = false);
      throw Exception('Failed to load offers');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F2),
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
            title: const Text(
              "Exclusive Offers",
              style: TextStyle(color: Colors.white),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
        ),
      ),
      body: _isLoading
          ? const AppLoadingWidget()
          : _offers.isEmpty
          ? const Center(child: Text("No offers available"))
          : LayoutBuilder(
              builder: (context, constraints) {
                double screenWidth = constraints.maxWidth;
                bool isTablet = screenWidth >= 600;

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _offers.length,
                  itemBuilder: (context, index) {
                    final offer = _offers[index];
                    final name = offer['name'];
                    final images = offer['gallery'] as List<String>;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              name,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: isTablet ? 24 : 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepOrange,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CarouselSlider(
                              options: CarouselOptions(
                                height: isTablet ? 300 : 200,
                                autoPlay: true,
                                enlargeCenterPage: true,
                                viewportFraction: 1.0,
                              ),
                              items: images.map((url) {
                                return Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: NetworkImage(url),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
      bottomNavigationBar: Footer(title: "offers"),
    );
  }
}
