// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:youtube_player_flutter/youtube_player_flutter.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// class CharityPage2 extends StatefulWidget {
//   final String charityId;
//   const CharityPage2({super.key, required this.charityId});

//   @override
//   State<CharityPage2> createState() => _CharityPage2State();
// }

// class _CharityPage2State extends State<CharityPage2> {
//   Map<String, dynamic>? charityData;
//   bool isLoading = true;
//   bool isError = false;
//   String errorMessage = '';
//   bool _isExpanded = false;
//   YoutubePlayerController? _youtubeController;
//   final TextEditingController amountController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     fetchCharityData();
//   }

//   @override
//   void dispose() {
//     _youtubeController?.dispose();
//     amountController.dispose();
//     super.dispose();
//   }

//   Future<void> fetchCharityData() async {
//     try {
//       final response = await http.get(
//         Uri.parse('https://medbook-backend-cd0b.onrender.com/api/charities/${widget.charityId}'),
//       ).timeout(const Duration(seconds: 10));

//       if (response.statusCode == 200) {
//         final jsonResponse = jsonDecode(response.body);

//         if (jsonResponse is Map<String, dynamic> && jsonResponse['resultData'] != null) {
//           final resultData = jsonResponse['resultData'];

//           if (resultData is Map<String, dynamic>) {
//             // Initialize YouTube controller if available
//             if (resultData['youtubeLink'] != null &&
//                 resultData['youtubeLink'].toString().isNotEmpty) {
//               final videoId = YoutubePlayer.convertUrlToId(resultData['youtubeLink']);
//               if (videoId != null) {
//                 _youtubeController = YoutubePlayerController(
//                   initialVideoId: videoId,
//                   flags: const YoutubePlayerFlags(
//                     autoPlay: false,
//                     mute: false,
//                     disableDragSeek: false,
//                     loop: false,
//                     isLive: false,
//                   ),
//                 );
//               }
//             }

//             setState(() {
//               charityData = resultData;
//               isLoading = false;
//               isError = false;
//             });
//             return;
//           }
//         }
//         throw Exception('Invalid response format');
//       }
//       throw Exception('HTTP ${response.statusCode}: ${response.body}');
//     } on TimeoutException {
//       _handleError('Request timed out. Please check your connection.');
//     } catch (e) {
//       _handleError('Failed to load charity details: ${e.toString()}');
//     }
//   }

//   void _handleError(String message) {
//     setState(() {
//       errorMessage = message;
//       isError = true;
//       isLoading = false;
//     });
//   }

//   Future<void> _launchUPIPayment(String amount) async {
//     try {
//       if (amount.isEmpty) throw Exception('Please enter a valid amount');

//       final upiUrl = Uri.parse(
//         'upi://pay?pa=aihmscbe-3@okicici&pn=${Uri.encodeComponent(charityData?['title'] ?? 'Charity')}&am=$amount&cu=INR',
//       );

//       if (await canLaunchUrl(upiUrl)) {
//         await launchUrl(upiUrl, mode: LaunchMode.externalApplication);
//       } else {
//         throw Exception('Could not launch UPI app');
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(e.toString())),
//       );
//     }
//   }

//   Widget _actionButton(IconData icon, Color color, VoidCallback onPressed) => GestureDetector(
//     onTap: onPressed,
//     child: Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.15),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: FaIcon(icon, color: color, size: 22),
//     ),
//   );

//   Widget _buildImageWithPlaceholder(String? imageUrl, {double? height, double? width, BoxFit? fit}) {
//     return imageUrl == null || imageUrl.isEmpty
//         ? Container(
//             color: Colors.grey[200],
//             child: const Icon(Icons.image, size: 50),
//           )
//         : Image.network(
//             imageUrl,
//             height: height,
//             width: width,
//             fit: fit ?? BoxFit.cover,
//             loadingBuilder: (context, child, loadingProgress) {
//               if (loadingProgress == null) return child;
//               return Center(
//                 child: CircularProgressIndicator(
//                   value: loadingProgress.expectedTotalBytes != null
//                       ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
//                       : null,
//                 ),
//               );
//             },
//             errorBuilder: (context, error, stackTrace) => Container(
//               color: Colors.grey[200],
//               child: const Icon(Icons.broken_image),
//             ),
//           );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: PreferredSize(
//         preferredSize: const Size.fromHeight(kToolbarHeight),
//         child: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               colors: [
//                 Color.fromARGB(255, 225, 119, 20), // Orange
//                 Color.fromARGB(255, 239, 48, 34),  // Red
//               ],
//               stops: [0.0, 0.5],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//           child: AppBar(
//             title: const Text(
//               "Charity Details",
//               style: TextStyle(color: Colors.white),
//             ),
//             backgroundColor: Colors.transparent,
//             elevation: 0,
//             iconTheme: const IconThemeData(color: Colors.white),
//             centerTitle: true,
//           ),
//         ),
//       ),
//       body: isLoading
//          
//           : isError
//               ? Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const Icon(Icons.error_outline, size: 48, color: Colors.red),
//                       const SizedBox(height: 16),
//                       Text(
//                         errorMessage,
//                         textAlign: TextAlign.center,
//                         style: const TextStyle(fontSize: 16),
//                       ),
//                       const SizedBox(height: 16),
//                       ElevatedButton(
//                         onPressed: fetchCharityData,
//                         child: const Text('Retry'),
//                       ),
//                     ],
//                   ),
//                 )
//               : charityData == null
//                   ? const Center(child: Text("No charity data available"))
//                   : SingleChildScrollView(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // Banner + Profile Image
//                           Stack(
//                             clipBehavior: Clip.none,
//                             alignment: Alignment.bottomCenter,
//                             children: [
//                               SizedBox(
//                                 height: 200,
//                                 child: _buildImageWithPlaceholder(
//                                   charityData?['banner_image'],
//                                   fit: BoxFit.cover,
//                                 ),
//                               ),
//                               Positioned(
//                                 bottom: -60,
//                                 child: Container(
//                                   width: 120,
//                                   height: 120,
//                                   decoration: BoxDecoration(
//                                     border: Border.all(color: Colors.white, width: 4),
//                                     borderRadius: BorderRadius.circular(16),
//                                     boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
//                                   ),
//                                   child: ClipRRect(
//                                     borderRadius: BorderRadius.circular(16),
//                                     child: _buildImageWithPlaceholder(charityData?['imageUrl']),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 80),

//                           // About Section
//                           Padding(
//                             padding: const EdgeInsets.symmetric(horizontal: 20),
//                             child: Card(
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(16),
//                               ),
//                               color: const Color(0xFFF6F9FF),
//                               child: Padding(
//                                 padding: const EdgeInsets.all(16),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     const Text(
//                                       "About Charity",
//                                       style: TextStyle(
//                                         fontSize: 18,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                     const SizedBox(height: 8),
//                                     Text(
//                                       charityData?['description'] ?? 'No description available',
//                                       style: const TextStyle(fontSize: 15),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),

//                           const SizedBox(height: 20),

//                       const SizedBox(height: 20),

//                           // YouTube Video
//                           if (_youtubeController != null)
//                             Padding(
//                               padding: const EdgeInsets.symmetric(horizontal: 20),
//                               child: YoutubePlayerBuilder(
//                                 player: YoutubePlayer(
//                                   controller: _youtubeController!,
//                                   showVideoProgressIndicator: true,
//                                   progressIndicatorColor: Colors.redAccent,
//                                 ),
//                                 builder: (context, player) => ClipRRect(
//                                   borderRadius: BorderRadius.circular(12),
//                                   child: player,
//                                 ),
//                               ),
//                             ),

//                           const SizedBox(height: 20),

//                           // Gallery
//                           if (charityData?['gallery'] != null &&
//                               (charityData!['gallery'] as List).isNotEmpty)
//                             Padding(
//                               padding: const EdgeInsets.symmetric(horizontal: 20),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   const Text(
//                                     "Gallery",
//                                     style: TextStyle(
//                                       fontSize: 18,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                   const SizedBox(height: 10),
//                                   SizedBox(
//                                     height: 180,
//                                     child: ListView.builder(
//                                       scrollDirection: Axis.horizontal,
//                                       itemCount: charityData!['gallery'].length,
//                                       itemBuilder: (context, index) {
//                                         final imageUrl = charityData!['gallery'][index];
//                                         return Container(
//                                           margin: const EdgeInsets.only(right: 10),
//                                           width: 150,
//                                           decoration: BoxDecoration(
//                                             borderRadius: BorderRadius.circular(12),
//                                             image: DecorationImage(
//                                               image: NetworkImage(imageUrl),
//                                               fit: BoxFit.cover,
//                                             ),
//                                           ),
//                                         );
//                                       },
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),

//                           const SizedBox(height: 30),
//                                 // Donation Section
//                           Padding(
//                             padding: const EdgeInsets.symmetric(horizontal: 20),
//                             child: Card(
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(16),
//                               ),
//                               color: const Color(0xFFF6F9FF),
//                               child: Padding(
//                                 padding: const EdgeInsets.all(16),
//                                 child: Column(
//                                   children: [
//                                     const Text(
//                                       "Donate for a Cause",
//                                       style: TextStyle(
//                                         fontSize: 18,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                     const SizedBox(height: 12),
//                                     TextField(
//                                       controller: amountController,
//                                       keyboardType: TextInputType.number,
//                                       decoration: const InputDecoration(
//                                         labelText: "Enter Amount (INR)",
//                                         border: OutlineInputBorder(),
//                                         contentPadding: EdgeInsets.symmetric(horizontal: 12),
//                                       ),
//                                     ),
//                                     const SizedBox(height: 16),
//                                     ElevatedButton(
//                                       onPressed: () => _launchUPIPayment(amountController.text.trim()),
//                                       style: ElevatedButton.styleFrom(
//                                         backgroundColor: Colors.redAccent,
//                                         shape: RoundedRectangleBorder(
//                                           borderRadius: BorderRadius.circular(25),
//                                         ),
//                                         padding: const EdgeInsets.symmetric(
//                                           horizontal: 30,
//                                           vertical: 12,
//                                         ),
//                                       ),
//                                       child: const Text(
//                                         "Donate Now",
//                                         style: TextStyle(
//                                           fontSize: 16,
//                                           fontWeight: FontWeight.bold,
//                                           color: Colors.white,
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),

//                         ],
//                       ),
//                     ),
//     );
//   }
// }

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:medbook/components/common/loading_widget.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class CharityPage2 extends StatefulWidget {
  final String charityId;
  const CharityPage2({super.key, required this.charityId});

  @override
  State<CharityPage2> createState() => _CharityPage2State();
}

class _CharityPage2State extends State<CharityPage2> {
  Map<String, dynamic>? charityData;
  bool isLoading = true;
  bool isError = false;
  String errorMessage = '';
  YoutubePlayerController? _youtubeController;
  final TextEditingController amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchCharityData();
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    amountController.dispose();
    super.dispose();
  }

  Future<void> fetchCharityData() async {
    try {
      final response = await http
          .get(
            Uri.parse(
              'https://medbook-backend-cd0b.onrender.com/api/charities/${widget.charityId}',
            ),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        if (jsonResponse is Map<String, dynamic> &&
            jsonResponse['resultData'] != null) {
          final resultData = jsonResponse['resultData'];

          if (resultData is Map<String, dynamic>) {
            if (resultData['youtubeLink'] != null &&
                resultData['youtubeLink'].toString().isNotEmpty) {
              final videoId = YoutubePlayer.convertUrlToId(
                resultData['youtubeLink'],
              );
              if (videoId != null) {
                _youtubeController = YoutubePlayerController(
                  initialVideoId: videoId,
                  flags: const YoutubePlayerFlags(
                    autoPlay: false,
                    mute: false,
                    disableDragSeek: false,
                    loop: false,
                    isLive: false,
                  ),
                );
              }
            }

            setState(() {
              charityData = resultData;
              isLoading = false;
              isError = false;
            });
            return;
          }
        }
        throw Exception('Invalid response format');
      }
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    } on TimeoutException {
      _handleError('Request timed out. Please check your connection.');
    } catch (e) {
      _handleError('Failed to load charity details: ${e.toString()}');
    }
  }

  void _handleError(String message) {
    setState(() {
      errorMessage = message;
      isError = true;
      isLoading = false;
    });
  }

  Future<void> _launchUPIPayment(String amount) async {
    try {
      if (amount.isEmpty) throw Exception('Please enter a valid amount');

      final upiUrl = Uri.parse(
        'upi://pay?pa=aihmscbe-3@okicici&pn=${Uri.encodeComponent(charityData?['title'] ?? 'Charity')}&am=$amount&cu=INR',
      );

      if (await canLaunchUrl(upiUrl)) {
        await launchUrl(upiUrl, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Could not launch UPI app');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Widget _buildImageWithPlaceholder(
    String? imageUrl, {
    double? height,
    double? width,
    BoxFit? fit,
  }) {
    return imageUrl == null || imageUrl.isEmpty
        ? Container(
            color: Colors.grey[200],
            child: const Icon(Icons.image, size: 50),
          )
        : Image.network(
            imageUrl,
            height: height,
            width: width,
            fit: fit ?? BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(child: AppLoadingWidget());
            },
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.grey[200],
              child: const Icon(Icons.broken_image),
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    final bool isTablet = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: Colors.white,
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
              "Charity Details",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            centerTitle: true,
          ),
        ),
      ),

      body: isLoading
          ? const AppLoadingWidget()
          : isError
          ? Center(child: Text(errorMessage))
          : charityData == null
          ? const Center(child: Text("No charity data available"))
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// ============================================================
                  ///                🔥 NEW UPDATED TOP LAYOUT 🔥
                  /// ============================================================

                  // Banner
                  SizedBox(
                    height: isTablet ? 300 : 200,
                    width: double.infinity,
                    child: _buildImageWithPlaceholder(
                      charityData?['banner_image'],
                      fit: BoxFit.cover,
                    ),
                  ),

                  // Profile + Title Row
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 40 : 20,
                      vertical: 16,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Profile Image Bottom-Left
                        Container(
                          width: isTablet ? 140 : 110,
                          height: isTablet ? 140 : 110,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: Colors.white, width: 4),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 6,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: _buildImageWithPlaceholder(
                              charityData?['imageUrl'],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                        const SizedBox(width: 20),

                        // Title + Location Centered
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                charityData?['title'] ?? 'Charity',
                                style: TextStyle(
                                  fontSize: isTablet ? 28 : 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              if (charityData?['location'] != null)
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      charityData!['location'],
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// ============================================================
                  const SizedBox(height: 20),

                  // About Section
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 40 : 20,
                    ),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      color: const Color(0xFFF6F9FF),
                      child: Padding(
                        padding: EdgeInsets.all(isTablet ? 24 : 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "About Charity",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              charityData?['description'] ??
                                  'No description available',
                              style: const TextStyle(fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // YouTube block
                  if (_youtubeController != null)
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 40 : 20,
                      ),
                      child: YoutubePlayerBuilder(
                        player: YoutubePlayer(
                          controller: _youtubeController!,
                          showVideoProgressIndicator: true,
                          progressIndicatorColor: Colors.redAccent,
                        ),
                        builder: (context, player) => ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: player,
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Gallery
                  if (charityData?['gallery'] != null &&
                      (charityData!['gallery'] as List).isNotEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 40 : 20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Gallery",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: isTablet ? 220 : 180,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: charityData!['gallery'].length,
                              itemBuilder: (context, index) {
                                final imageUrl = charityData!['gallery'][index];
                                return Container(
                                  margin: const EdgeInsets.only(right: 10),
                                  width: isTablet ? 200 : 150,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    image: DecorationImage(
                                      image: NetworkImage(imageUrl),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 30),

                  // Donation Section
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 40 : 20,
                    ),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      color: const Color(0xFFF6F9FF),
                      child: Padding(
                        padding: EdgeInsets.all(isTablet ? 24 : 16),
                        child: Column(
                          children: [
                            const Text(
                              "Donate for a Cause",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: isTablet ? 400 : double.infinity,
                              child: TextField(
                                controller: amountController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: "Enter Amount (INR)",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: isTablet ? 400 : double.infinity,
                              child: ElevatedButton(
                                onPressed: () => _launchUPIPayment(
                                  amountController.text.trim(),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                                child: const Text(
                                  "Donate Now",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }
}
