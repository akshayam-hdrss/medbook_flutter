import 'dart:async';
import 'package:flutter/material.dart';
import 'package:medbook/components/Footer.dart';
import 'package:medbook/components/common/loading_widget.dart';
import 'package:medbook/pages/ServiceSchedule/ServiceSchedule.dart';
import 'package:medbook/utils/api_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ServicesPage3 extends StatefulWidget {
  final String serviceId;
  final String mainServiceName;

  const ServicesPage3({
    super.key,
    required this.serviceId,
    required this.mainServiceName,
  });

  @override
  State<ServicesPage3> createState() => _ServicesPage3State();
}

class _ServicesPage3State extends State<ServicesPage3> {
  Map<String, dynamic>? serviceDetails;
  bool isLoading = true;
  final bool _isExpanded = false;
  bool showAllReviews = false;
  YoutubePlayerController? _youtubeController;
  late PageController _reviewPageController;
  Timer? _autoScrollTimer;
  int _currentPage = 0;

  // Review state variables
  List<Map<String, dynamic>> reviews = [];
  TextEditingController commentController = TextEditingController();
  double selectedRating = 0;

  @override
  void initState() {
    super.initState();
    loadServiceDetails();
    _reviewPageController = PageController(viewportFraction: 0.5);
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (_reviewPageController.hasClients && reviews.length > 1) {
        _currentPage = (_currentPage + 1) % reviews.length;
        _reviewPageController.animateToPage(
          _currentPage,
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
    commentController.dispose();
    super.dispose();
  }

  // ⭐ Helper method to get trimmed service name
  String _getTrimmedServiceName() {
    return widget.mainServiceName.trim();
  }

  // ⭐ Check if Book Now button should be shown
  bool _shouldShowBookNowButton() {
    final trimmedName = _getTrimmedServiceName();
    return trimmedName == "Fitness Care" || trimmedName == "Beauty Care";
  }

  Future<void> loadServiceDetails() async {
    try {
      final data = await fetchServiceDetails1(widget.serviceId);

      // Initialize YouTube controller if available
      if (data['youtubeLink'] != null &&
          data['youtubeLink'].toString().isNotEmpty) {
        final videoId = YoutubePlayer.convertUrlToId(data['youtubeLink']);
        if (videoId != null) {
          _youtubeController = YoutubePlayerController(
            initialVideoId: videoId,
            flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
          );
        }
      }

      // Load reviews
      await fetchServiceReviews();

      setState(() {
        serviceDetails = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchServiceReviews() async {
    try {
      final response = await ApiServices.get(
        '/service/${widget.serviceId}/reviews',
      );

      if (response['result'] == 'Success' && response['resultData'] is List) {
        setState(() {
          reviews = List<Map<String, dynamic>>.from(response['resultData']);
        });
      }
    } catch (e) {
      print('Error fetching reviews: $e');
    }
  }

  Future<void> submitReview() async {
    final comment = commentController.text.trim();
    if (comment.isEmpty || selectedRating == 0) return;

    try {
      await ApiServices.post('/service/${widget.serviceId}/review', {
        "comment": comment,
        "rating": selectedRating,
      });

      await fetchServiceReviews();

      setState(() {
        commentController.clear();
        selectedRating = 0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review submitted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to submit review: $e')));
    }
  }

  void _launchCaller(String phone) async {
    final url = Uri.parse("tel:$phone");
    if (await canLaunchUrl(url)) await launchUrl(url);
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
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

  Widget _actionButton(IconData icon, Color color) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(child: FaIcon(icon, color: Colors.white, size: 18)),
    );
  }

  Widget _buildReviewItem(Map<String, dynamic> review) {
    final reviewerName = review['name'] ?? "Anonymous";
    final date = review['date'] ?? review['createdAt'] ?? '';
    final rating = double.tryParse(review['rating'].toString()) ?? 0;
    final comment = review['comment'] ?? '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                reviewerName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              if (date.isNotEmpty)
                Text(
                  date,
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: List.generate(5, (i) {
              return Icon(
                i < rating.round() ? Icons.star : Icons.star_border_outlined,
                color: Colors.orange,
                size: 18,
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            comment,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final address =
        '${serviceDetails?['addressLine1'] ?? ''}, ${serviceDetails?['addressLine2'] ?? ''}';
    final phoneNumber = serviceDetails?['phoneNumber']?.toString() ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 225, 119, 20), // Orange
                Color.fromARGB(255, 239, 48, 34), // Red
              ],
              stops: [0.0, 0.5],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            title: const Text(
              "Description",
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
          : serviceDetails == null
          ? const Center(child: Text("No details available"))
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Banner + Profile Image
                  Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.bottomCenter,
                    children: [
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(
                              serviceDetails!['bannerUrl'] ?? '',
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
                              serviceDetails!['imageUrl'] ?? '',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.image),
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 80),

                  // Info Card
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
                              serviceDetails!['serviceName'] ?? '',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              serviceDetails!['businessName'] ?? '',
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
                                Text(
                                  serviceDetails!['rating']?.toString() ??
                                      '5.0',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  "• ${reviews.length} reviews",
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () => _makePhoneCall(phoneNumber),
                                    child: _actionButton(
                                      FontAwesomeIcons.phone,
                                      Colors.lightBlueAccent,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  GestureDetector(
                                    onTap: () => _launchWhatsApp(phoneNumber),
                                    child: _actionButton(
                                      FontAwesomeIcons.whatsapp,
                                      Colors.green,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  GestureDetector(
                                    onTap: () => _launchMapLink(address),
                                    child: _actionButton(
                                      FontAwesomeIcons.mapMarkerAlt,
                                      const Color(0xFFFF5722),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            // ⭐ Conditionally show Book Now button based on mainServiceName
                            if (_shouldShowBookNowButton())
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ServiceSchedule(
                                        serviceName: serviceDetails?['serviceName']?.toString() ?? '',
                                        serviceId: serviceDetails?['_id']?.toString() ?? '',
                                        servicePhone: phoneNumber,
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(
                                    255,
                                    234,
                                    29,
                                    29,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 30,
                                    vertical: 12,
                                  ),
                                ),
                                child: const Text(
                                  "Book Now",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            const SizedBox(height: 12),
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
                              "About Service",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              serviceDetails!['about'] ?? '',
                              style: const TextStyle(fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ⭐ Reviews Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "⭐ Reviews",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Reviews Carousel
                        if (!showAllReviews && reviews.isNotEmpty)
                          SizedBox(
                            height: 210,
                            child: PageView.builder(
                              padEnds: false,
                              controller: _reviewPageController,
                              itemCount: reviews.length,
                              itemBuilder: (context, index) {
                                return _buildReviewItem(reviews[index]);
                              },
                            ),
                          ),

                        // Show More Button
                        if (!showAllReviews && reviews.isNotEmpty)
                          Center(
                            child: ElevatedButton(
                              onPressed: () =>
                                  setState(() => showAllReviews = true),
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

                        // All Reviews List
                        if (showAllReviews && reviews.isNotEmpty)
                          ...reviews.map((review) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildReviewItem(review),
                            );
                          }),

                        // See Less Button
                        if (showAllReviews && reviews.isNotEmpty)
                          Center(
                            child: ElevatedButton(
                              onPressed: () =>
                                  setState(() => showAllReviews = false),
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
                                "See Less Reviews",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),

                        // No Reviews Message
                        if (reviews.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Text(
                                "No reviews yet. Be the first to review!",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Add Review Section
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
                              "Leave a Review",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 15),
                            Row(
                              children: [
                                const Text(
                                  "Rating: ",
                                  style: TextStyle(fontSize: 16),
                                ),
                                for (int i = 1; i <= 5; i++)
                                  IconButton(
                                    icon: Icon(
                                      Icons.star,
                                      size: 30,
                                      color: i <= selectedRating
                                          ? Colors.orange
                                          : Colors.grey,
                                    ),
                                    onPressed: () => setState(
                                      () => selectedRating = i.toDouble(),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            TextField(
                              controller: commentController,
                              decoration: InputDecoration(
                                hintText: "Share your experience...",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                contentPadding: const EdgeInsets.all(12),
                              ),
                              maxLines: 4,
                            ),
                            const SizedBox(height: 15),
                            Center(
                              child: ElevatedButton(
                                onPressed: submitReview,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 30,
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
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // YouTube Video
                  if (_youtubeController != null)
                    Padding(
                      padding: EdgeInsets.zero,
                      child: YoutubePlayerBuilder(
                        player: YoutubePlayer(
                          controller: _youtubeController!,
                          showVideoProgressIndicator: true,
                          progressIndicatorColor: Colors.redAccent,
                        ),
                        builder: (context, player) => ClipRRect(
                          child: player,
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Gallery
                  if (serviceDetails!['gallery'] != null &&
                      (serviceDetails!['gallery'] as List).isNotEmpty)
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
                              itemCount: serviceDetails!['gallery'].length,
                              itemBuilder: (context, index) {
                                final imageUrl =
                                    serviceDetails!['gallery'][index];
                                return Container(
                                  margin: const EdgeInsets.only(right: 10),
                                  width: 150,
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
                ],
              ),
            ),
      bottomNavigationBar: const Footer(title: "none"),
    );
  }
}