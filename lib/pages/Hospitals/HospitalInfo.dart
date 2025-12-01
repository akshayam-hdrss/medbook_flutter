// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:http/http.dart' as http;
// import 'package:medbook/components/Footer.dart';
// import 'package:medbook/components/common/loading_widget.dart';
// import 'package:url_launcher/url_launcher.dart';

// class HospitalInfoPage extends StatefulWidget {
//   final String hospitalId, hospitalname;

//   const HospitalInfoPage({
//     super.key,
//     required this.hospitalId,
//     required this.hospitalname,
//   });

//   @override
//   State<HospitalInfoPage> createState() => _HospitalInfoPageState();
// }

// class _HospitalInfoPageState extends State<HospitalInfoPage> {
//   Map<String, dynamic>? hospitalData;
//   bool isLoading = true;
//   String errorMessage = '';

//   @override
//   void initState() {
//     super.initState();
//     _loadHospitalInfo();
//   }

//   Future<void> _loadHospitalInfo() async {
//     final url = Uri.parse(
//       "https://medbook-backend-1.onrender.com/api/hospital-information/hospital/${widget.hospitalId}",
//     );

//     try {
//       final response = await http.get(url);

//       if (response.statusCode == 200) {
//         final jsonResponse = jsonDecode(response.body);
//         setState(() {
//           hospitalData = jsonResponse;
//           isLoading = false;
//         });
//       } else {
//         setState(() {
//           errorMessage =
//               "Failed to load: ${response.statusCode} ${response.reasonPhrase}";
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         errorMessage = e.toString();
//         isLoading = false;
//       });
//     }
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
//                 Color.fromARGB(255, 225, 119, 20),
//                 Color.fromARGB(255, 239, 48, 34),
//               ],
//               stops: [0.0, 0.5],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//           child: AppBar(
//             iconTheme: const IconThemeData(color: Colors.white),
//             title: const Text(
//               'Hospital Information',
//               style: TextStyle(color: Colors.white),
//             ),
//             backgroundColor: Colors.transparent,
//             centerTitle: true,
//             elevation: 0,
//           ),
//         ),
//       ),
//       bottomNavigationBar: Footer(title: "none"),
//       body: isLoading
//           ? const AppLoadingWidget()
//           : errorMessage.isNotEmpty
//           ? Center(child: Text("Error: $errorMessage"))
//           : _buildHospitalContent(),
//     );
//   }

//   Widget _buildHospitalContent() {
//     final name = widget.hospitalname;
//     final banner =
//         hospitalData?['banner_img'] ?? "https://via.placeholder.com/400x200";
//     final mission = hospitalData?['mission'] ?? "Mission not available.";
//     final vision = hospitalData?['vision'] ?? "Vision not available.";
//     final specialties =
//         hospitalData?['specialties'] ?? "Specialties not available.";
//     final address = hospitalData?['address'] ?? "Address not available.";
//     final nearest = hospitalData?['nearest_location'] ?? "";
//     final website = hospitalData?['website'] ?? "";
//     final description = hospitalData?['description'] ?? "";
//     final ceoName = hospitalData?['ceo_name'] ?? "CEO Name";
//     final ceoImage =
//         hospitalData?['ceo_image'] ?? "https://via.placeholder.com/150";

//     return SingleChildScrollView(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Banner Image
//           Container(
//             height: 200,
//             width: double.infinity,
//             decoration: BoxDecoration(
//               image: DecorationImage(
//                 image: NetworkImage(banner),
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),

//           // Hospital Name
//           Padding(
//             padding: const EdgeInsets.symmetric(vertical: 16),
//             child: Center(
//               child: Text(
//                 name,
//                 textAlign: TextAlign.center,
//                 style: GoogleFonts.poppins(
//                   fontSize: 26,
//                   fontWeight: FontWeight.bold,
//                   color: const Color(0xFFD32F2F),
//                 ),
//               ),
//             ),
//           ),

//           // About Hospital
//           _buildSectionTitle("About Hospital"),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Text(
//               description,
//               style: GoogleFonts.poppins(fontSize: 14, height: 1.5),
//             ),
//           ),
//           const SizedBox(height: 24),

//           // Mission & Vision
//           _buildSectionTitle("Our Core Principles"),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Column(
//               children: [
//                 _buildMissionVisionValueCard(
//                   context: context,
//                   title: "Mission",
//                   icon: Icons.flag,
//                   description: mission,
//                 ),
//                 const SizedBox(height: 12),
//                 _buildMissionVisionValueCard(
//                   context: context,
//                   title: "Vision",
//                   icon: Icons.visibility,
//                   description: vision,
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 24),

//           // Specialties
//           _buildSectionTitle("Specialties"),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Text(
//               specialties,
//               style: GoogleFonts.poppins(fontSize: 14, height: 1.5),
//             ),
//           ),
//           const SizedBox(height: 24),

//           // CEO Section (centered)
//           _buildSectionTitle("Leadership"),
//           _buildLeaderCard("CEO", ceoName, "Hospital CEO", ceoImage),
//           const SizedBox(height: 24),

//           // Address
//           _buildSectionTitle("Address & Location"),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Card(
//               elevation: 2,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Icon(Icons.location_on, color: Colors.red, size: 24),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Text(
//                         "$address\nNearest: $nearest",
//                         style: GoogleFonts.poppins(
//                           fontSize: 14,
//                           height: 1.4,
//                           color: Colors.grey[700],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(height: 24),

//           // Website (clickable)
//           _buildSectionTitle("Map"),
//           if (website.isNotEmpty)
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: GestureDetector(
//                 onTap: () async {
//                   final Uri url = Uri.parse(website);
//                   if (await canLaunchUrl(url)) {
//                     await launchUrl(url, mode: LaunchMode.externalApplication);
//                   } else {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(content: Text("Could not open $website")),
//                     );
//                   }
//                 },
//                 child: Text(
//                   website,
//                   style: GoogleFonts.poppins(
//                     fontSize: 14,
//                     color: Colors.blue,
//                     decoration: TextDecoration.underline,
//                   ),
//                 ),
//               ),
//             ),
//           const SizedBox(height: 30),
//         ],
//       ),
//     );
//   }

//   // Section Title
//   Widget _buildSectionTitle(String title) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
//       child: Text(
//         title,
//         style: GoogleFonts.poppins(
//           fontSize: 20,
//           fontWeight: FontWeight.w700,
//           color: const Color(0xFFD32F2F),
//         ),
//       ),
//     );
//   }

//   // Mission/Vision Card
//   Widget _buildMissionVisionValueCard({
//     required BuildContext context,
//     required String title,
//     required IconData icon,
//     required String description,
//   }) {
//     return Card(
//       elevation: 3,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Container(
//         height: 140,
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(icon, size: 20, color: const Color(0xFFD32F2F)),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Text(
//                     title,
//                     style: GoogleFonts.poppins(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       color: const Color(0xFFD32F2F),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             Expanded(
//               child: Text(
//                 description,
//                 style: GoogleFonts.poppins(
//                   fontSize: 13,
//                   height: 1.4,
//                   color: Colors.grey[700],
//                 ),
//                 maxLines: 4,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Leader Card (center aligned)
//   Widget _buildLeaderCard(
//     String role,
//     String name,
//     String tagline,
//     String imageUrl,
//   ) {
//     return Container(
//       width: double.infinity,
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.2),
//             spreadRadius: 1,
//             blurRadius: 6,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           // Role header
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Color(0xFFD32F2F), Color(0xFFB71C1C)],
//                 begin: Alignment.centerLeft,
//                 end: Alignment.centerRight,
//               ),
//               borderRadius: BorderRadius.only(
//                 topLeft: Radius.circular(12),
//                 topRight: Radius.circular(12),
//               ),
//             ),
//             child: Center(
//               child: Text(
//                 role,
//                 style: GoogleFonts.poppins(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//           ),

//           // Content (centered)
//           Padding(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Container(
//                   width: 120,
//                   height: 120,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(8),
//                     border: Border.all(
//                       color: const Color(0xFFD32F2F),
//                       width: 3,
//                     ),
//                   ),
//                   clipBehavior: Clip.hardEdge,
//                   child: Image.network(imageUrl, fit: BoxFit.cover),
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   name,
//                   style: GoogleFonts.poppins(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w600,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   tagline,
//                   style: GoogleFonts.poppins(
//                     fontSize: 13,
//                     color: const Color(0xFFD32F2F),
//                     fontStyle: FontStyle.italic,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//               ],
//             ),
//           ),
//         ],
// ),
// );
// }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:medbook/components/Footer.dart';
import 'package:medbook/components/common/loading_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class HospitalInfoPage extends StatefulWidget {
  final String hospitalId, hospitalname;

  const HospitalInfoPage({
    super.key,
    required this.hospitalId,
    required this.hospitalname,
  });

  @override
  State<HospitalInfoPage> createState() => _HospitalInfoPageState();
}

class _HospitalInfoPageState extends State<HospitalInfoPage> {
  Map<String, dynamic>? hospitalData;
  bool isLoading = true;
  String errorMessage = '';

  late YoutubePlayerController _youtubeController;
  String youtube = "";

  @override
  void initState() {
    super.initState();
    _loadHospitalInfo();
  }

  Future<void> _loadHospitalInfo() async {
    final url = Uri.parse(
      "https://medbook-backend-1.onrender.com/api/hospital-information/hospital/${widget.hospitalId}",
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        youtube = jsonResponse['youtubeLink'] ?? "";

        if (youtube.isNotEmpty) {
          final videoId = YoutubePlayer.convertUrlToId(youtube) ?? "";
          _youtubeController = YoutubePlayerController(
            initialVideoId: videoId,
            flags: const YoutubePlayerFlags(
              autoPlay: false,
              mute: false,
              controlsVisibleAtStart: true,
            ),
          );
        }

        setState(() {
          hospitalData = jsonResponse;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage =
              "Failed to load: ${response.statusCode} ${response.reasonPhrase}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    if (youtube.isNotEmpty) {
      _youtubeController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            iconTheme: const IconThemeData(color: Colors.white),
            title: const Text(
              'Hospital Information',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.transparent,
            centerTitle: true,
            elevation: 0,
          ),
        ),
      ),
      bottomNavigationBar: Footer(title: "none"),
      body: isLoading
          ? const AppLoadingWidget()
          : errorMessage.isNotEmpty
          ? Center(child: Text("Error: $errorMessage"))
          : _buildHospitalContent(),
    );
  }

  Widget _buildHospitalContent() {
    final name = widget.hospitalname;
    final banner =
        hospitalData?['banner_img'] ?? "https://via.placeholder.com/400x200";
    final mission = hospitalData?['mission'] ?? "Our mission is to serve.";
    final vision = hospitalData?['vision'] ?? "Our vision is to lead.";
    final specialties = hospitalData?['specialties'] ?? "Cardiology, Neurology";
    final address = hospitalData?['address'] ?? "123 Health St, City";
    final nearest =
        hospitalData?['nearest_location'] ?? "Main Square, Near Hospital";
    final website = hospitalData?['website'] ?? "http://example.com";
    final description = hospitalData?['description'] ?? "";
    final ceoName = hospitalData?['ceo_name'] ?? "Unknown";
    final ceoImage =
        hospitalData?['ceo_image'] ?? "https://via.placeholder.com/150";

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Image
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(banner),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Hospital Name
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                name,
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFD32F2F),
                ),
              ),
            ),
          ),

          // About
          _buildSectionTitle("About Hospital"),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              description,
              style: GoogleFonts.poppins(fontSize: 14, height: 1.5),
            ),
          ),
          const SizedBox(height: 24),

          // Mission / Vision
          _buildSectionTitle("Our Core Principles"),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _buildMissionVisionValueCard(
                  context: context,
                  title: "Mission",
                  icon: Icons.flag,
                  description: mission,
                ),
                const SizedBox(height: 12),
                _buildMissionVisionValueCard(
                  context: context,
                  title: "Vision",
                  icon: Icons.visibility,
                  description: vision,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Specialties
          _buildSectionTitle("Specialties"),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              specialties,
              style: GoogleFonts.poppins(fontSize: 14, height: 1.5),
            ),
          ),
          const SizedBox(height: 24),

          // Leadership
          _buildSectionTitle("Leadership"),
          _buildLeaderCard("CEO", ceoName, "Hospital CEO", ceoImage),
          const SizedBox(height: 24),

          // Address
          _buildSectionTitle("Address & Location"),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.red),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "$address\nNearest: $nearest",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          height: 1.4,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Website
          _buildSectionTitle("Website"),
          if (website.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GestureDetector(
                onTap: () async {
                  
                  final url = Uri.parse(website);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
                child: Text(
                  website,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),

          const SizedBox(height: 30),

          // ⭐ YOUTUBE VIDEO SECTION
          if (youtube.isNotEmpty) ...[
            _buildSectionTitle("Hospital Video"),
            Padding(
              padding: EdgeInsets.zero,
              child: YoutubePlayerBuilder(
                player: YoutubePlayer(
                  controller: _youtubeController,
                  showVideoProgressIndicator: true,
                  progressIndicatorColor: Colors.redAccent,
                ),
                builder: (context, player) => player,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }

  // Section Title
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: const Color(0xFFD32F2F),
        ),
      ),
    );
  }

  // Mission/Vision Card
  Widget _buildMissionVisionValueCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required String description,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        height: 140,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: const Color(0xFFD32F2F)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFD32F2F),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Text(
                description,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  height: 1.4,
                  color: Colors.grey[700],
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Leader Card
  Widget _buildLeaderCard(
    String role,
    String name,
    String tagline,
    String imageUrl,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFD32F2F), Color(0xFFB71C1C)],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Center(
              child: Text(
                role,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFD32F2F),
                      width: 3,
                    ),
                  ),
                  child: Image.network(imageUrl, fit: BoxFit.cover),
                ),
                const SizedBox(height: 16),
                Text(
                  name,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tagline,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: const Color(0xFFD32F2F),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
