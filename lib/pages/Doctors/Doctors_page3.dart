import 'dart:async';
import 'package:flutter/material.dart';
import 'package:medbook/components/common/loading_widget.dart';
import 'package:medbook/utils/api_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Doctors_Page3 extends StatefulWidget {
  final String doctorId;
  const Doctors_Page3({super.key, required this.doctorId});

  @override
  State<Doctors_Page3> createState() => _DoctorsPage3State();
}

class _DoctorsPage3State extends State<Doctors_Page3> {
  bool _isExpanded = false;
  late Future<Map<String, dynamic>> doctorDetails;
  late Future<List<Map<String, dynamic>>> doctorReviews;
  final TextEditingController commentController = TextEditingController();
  double selectedRating = 0;
  YoutubePlayerController? _youtubeController; // Make nullable
  String? _youtubeLink; // Store the fetched link
  late PageController _reviewPageController;
  Timer? _autoScrollTimer;
  int _currentPage = 0;
  bool showAllReviews = false;

  @override
  void initState() {
    super.initState();
    doctorDetails = fetchDoctorDetails(widget.doctorId);
    doctorReviews = fetchDoctorReviews();

    _reviewPageController = PageController(viewportFraction: 0.5);
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (_reviewPageController.hasClients) {
        _currentPage++;
        _reviewPageController.animateToPage(
          _currentPage % 5,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    _reviewPageController.dispose();
    _autoScrollTimer?.cancel();
    super.dispose();
  }

  Future<Map<String, dynamic>> fetchDoctorDetails(String id) async {
    final response = await ApiServices.get('/doctor/$id');
    final data = response['resultData'];
    final youtubeLink = data['youtubeLink']?.toString();
    if (youtubeLink != null && youtubeLink.isNotEmpty) {
      final videoId = YoutubePlayer.convertUrlToId(youtubeLink);
      if (videoId != null) {
        _youtubeController?.dispose();
        _youtubeController = YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
        );
        _youtubeLink = youtubeLink;
        setState(() {}); // Update UI when controller is ready
      }
    }
    return data;
  }

  Future<List<Map<String, dynamic>>> fetchDoctorReviews() async {
    final response = await ApiServices.get(
      '/doctor/${widget.doctorId}/reviews',
    );
    if (response['result'] == 'Success') {
      return List<Map<String, dynamic>>.from(response['resultData']);
    } else {
      return [];
    }
  }

  Future<void> submitReview() async {
    final comment = commentController.text.trim();
    if (comment.isEmpty || selectedRating == 0) return;

    await ApiServices.post('/doctor/${widget.doctorId}/review', {
      "comment": comment,
      "rating": selectedRating,
    });

    setState(() {
      doctorReviews = fetchDoctorReviews();
      commentController.clear();
      selectedRating = 0;
    });
  }

  void _launchCaller(String phone) async {
    final url = Uri.parse("tel:$phone");
    if (await canLaunchUrl(url)) await launchUrl(url);
  }

  void _launchWhatsApp(String phone) async {
    final url = Uri.parse("https://wa.me/$phone");
    if (await canLaunchUrl(url)) await launchUrl(url);
  }

  void _launchMapLink(String address) async {
    final url = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}",
    );
    if (await canLaunchUrl(url)) await launchUrl(url);
  }

  Widget _actionButton(IconData icon, Color color) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: color.withOpacity(0.15),
      borderRadius: BorderRadius.circular(12),
    ),
    child: FaIcon(icon, color: color, size: 22),
  );

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
      title: const Text(
        "Doctor Details",
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: Colors.white),
    ),
  ),
),

      body: FutureBuilder<Map<String, dynamic>>(
        future: doctorDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppLoadingWidget();
            // return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return const Center(child: Text("Failed to load doctor details"));
          }

          final doctor = snapshot.data!;
          final imageUrl = doctor['imageUrl']?.toString() ?? '';
          final bannerUrl = doctor['bannerUrl']?.toString() ?? '';
          final phone = doctor['phone']?.toString() ?? '';
          final address = '${doctor['addressLine1']}, ${doctor['addressLine2']}';
          List<String> gallery = [];
          final rawGallery = doctor['gallery'];
          if (rawGallery is List) {
            gallery = rawGallery.whereType<String>().toList();
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Banner + Profile Stack
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(
                            bannerUrl.isNotEmpty
                                ? bannerUrl
                                : 'https://via.placeholder.com/600x200',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -60,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 4),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(color: Colors.black26, blurRadius: 8),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            imageUrl.isNotEmpty
                                ? imageUrl
                                : 'https://via.placeholder.com/150',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 80),

                // Doctor Info Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            doctor['doctorName'],
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            doctor['businessName'] ?? '',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.star, color: Colors.amber),
                              const SizedBox(width: 5),
                              FutureBuilder<List<Map<String, dynamic>>>(
                                future: doctorReviews,
                                builder: (context, reviewSnapshot) {
                                  if (reviewSnapshot.hasData) {
                                    final reviews = reviewSnapshot.data!;
                                    if (reviews.isEmpty) {
                                      return const Text(
                                        "0.0",
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      );
                                    }
                                    final avgRating = reviews
                                        .map((r) => double.tryParse(r['rating']?.toString() ?? '0') ?? 0)
                                        .reduce((a, b) => a + b) / reviews.length;
                                    return Text(
                                      avgRating.toStringAsFixed(1),
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    );
                                  }
                                  return const Text(
                                    "5.0",
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  );
                                },
                              ),
                              const SizedBox(width: 5),
                              FutureBuilder<List<Map<String, dynamic>>>(
                                future: doctorReviews,
                                builder: (context, reviewSnapshot) {
                                  return Text(
                                    "• ${reviewSnapshot.data?.length ?? 0} reviews",
                                    style: const TextStyle(color: Colors.grey),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () => _launchCaller(phone),
                                child: _actionButton(
                                  FontAwesomeIcons.phone,
                                  Colors.lightBlueAccent,
                                ),
                              ),
                              const SizedBox(width: 12),
                              GestureDetector(
                                onTap: () => _launchWhatsApp(phone),
                                child: _actionButton(
                                  FontAwesomeIcons.whatsapp,
                                  Colors.green,
                                ),
                              ),
                            const SizedBox(width: 12),
                              GestureDetector(
                                onTap: () => _launchMapLink(address),
                                child: _actionButton(
                                  FontAwesomeIcons
                                      .mapMarkerAlt, // Map marker icon
                                  Color(
                                    0xFFFF5722,
                                  ), // Orange color for the map marker
                             ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 30,
                                vertical: 12,
                              ),
                            ),
                            child: const Text(
                              "Book Appointment",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // About Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: const Color(0xFFF6F9FF),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "About Doctor",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            doctor['about'],
                            maxLines: _isExpanded ? null : 3,
                            overflow:
                                _isExpanded ? null : TextOverflow.ellipsis,
                          ),
                          TextButton(
                            onPressed: () =>
                                setState(() => _isExpanded = !_isExpanded),
                            child: Text(
                              _isExpanded ? 'Show Less' : 'Read More',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Reviews Section
                const Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Text(
                    "⭐ Reviews",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                if (!showAllReviews)
                  SizedBox(
                    height: 210,
                    child: FutureBuilder<List<Map<String, dynamic>>>(
                      future: doctorReviews,
                      builder: (context, reviewSnapshot) {
                        if (reviewSnapshot.connectionState ==
                            ConnectionState.waiting) {
                              return const AppLoadingWidget();
                          // return const Center(child: CircularProgressIndicator());
                        } else if (!reviewSnapshot.hasData ||
                            reviewSnapshot.data!.isEmpty) {
                          return const Center(child: Text("No reviews yet."));
                        }
                        final reviews = reviewSnapshot.data!;
                        final limited = reviews.length > 5
                            ? reviews.sublist(0, 5)
                            : reviews;

                        return PageView.builder(
                          padEnds: false,
                          controller: _reviewPageController,
                          itemCount: limited.length,
                          itemBuilder: (context, index) {
                            final review = limited[index];
                            final rating = double.tryParse(
                                      review['rating']?.toString() ?? '0',
                                    ) ??
                                0;

                            return Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 10,
                              ),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.shade300,
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Patient",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        review['createdAt']?.toString() ?? '',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: List.generate(5, (i) {
                                      return Icon(
                                        i < rating.round()
                                            ? Icons.star
                                            : Icons.star_border_outlined,
                                        color: Colors.orange,
                                        size: 18,
                                      );
                                    }),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    review['comment'] ?? '',
                                    maxLines: 4,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 10),
                if (!showAllReviews)
                  Center(
                    child: ElevatedButton(
                      onPressed: () => setState(() => showAllReviews = true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent.shade200,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 10,
                        ),
                      ),
                      child: const Text(
                        "See More Reviews",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),

                if (showAllReviews)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: FutureBuilder<List<Map<String, dynamic>>>(
                      future: doctorReviews,
                      builder: (context, reviewSnapshot) {
                        if (reviewSnapshot.connectionState ==
                            ConnectionState.waiting) {
                              return const AppLoadingWidget();
                          // return const Center(child: CircularProgressIndicator());
                        } else if (!reviewSnapshot.hasData ||
                            reviewSnapshot.data!.isEmpty) {
                          return const Center(child: Text("No reviews yet."));
                        }

                        final reviews = reviewSnapshot.data!;
                        return Column(
                          children: reviews.map((review) {
                            final rating = double.tryParse(
                                      review['rating']?.toString() ?? '0',
                                    ) ??
                                0;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.grey.shade200),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.shade100,
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        "Patient",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        review['createdAt']?.toString() ?? '',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: List.generate(5, (i) {
                                      return Icon(
                                        i < rating.round()
                                            ? Icons.star
                                            : Icons.star_border_outlined,
                                        color: Colors.orange,
                                        size: 20,
                                      );
                                    }),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    review['comment'] ?? '',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 10),
                if (showAllReviews)
                  Center(
                    child: ElevatedButton(
                      onPressed: () => setState(() => showAllReviews = false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent.shade200,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 10,
                        ),
                      ),
                      child: const Text(
                        "See less Reviews",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),

                const SizedBox(height: 20),

                // Add Review Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // const Text(
                      //   "Leave a Review",
                      //   style: TextStyle(
                      //     fontSize: 18,
                      //     fontWeight: FontWeight.bold,
                      //   ),
                      // ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Text("Rating: "),
                          for (int i = 1; i <= 5; i++)
                            IconButton(
                              icon: Icon(
                                Icons.star,
                                color: i <= selectedRating
                                    ? Colors.orange
                                    : Colors.grey,
                              ),
                              onPressed: () => setState(
                                  () => selectedRating = i.toDouble()),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: commentController,
                        decoration: InputDecoration(
                          hintText: "Enter your comment...",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 15),
                      ElevatedButton(
                        onPressed: submitReview,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent.shade200,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          "Submit Review",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // YouTube Video Section
                Padding(
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Video",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (_youtubeController != null)
                        YoutubePlayer(
                          controller: _youtubeController!,
                          showVideoProgressIndicator: true,
                          progressIndicatorColor: Colors.redAccent,
                        )
                      else
                        const Text("No video available."),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Gallery Section
                if (gallery.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
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
                          height: 180,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: gallery.length,
                            itemBuilder: (ctx, idx) {
                              return Container(
                                margin: const EdgeInsets.only(right: 10),
                                width: 150,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  image: DecorationImage(
                                    image: NetworkImage(gallery[idx]),
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
              ],
            ),
          );
        },
      ),
    );
  }
}



Widget _actionButton(IconData icon, Color color) {
  return Container(
    width: 40,
    height: 40,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Center(child: FaIcon(icon, color: Colors.white, size:18)),
  );
}