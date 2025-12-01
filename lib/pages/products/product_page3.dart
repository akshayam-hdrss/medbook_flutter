import 'dart:async';
import 'package:flutter/material.dart';
import 'package:medbook/components/Footer.dart';
import 'package:medbook/components/common/loading_widget.dart';
import 'package:medbook/utils/api_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ProductPage3 extends StatefulWidget {
  final String productId;

  const ProductPage3({super.key, required this.productId});

  @override
  State<ProductPage3> createState() => _ProductPage3State();
}

class _ProductPage3State extends State<ProductPage3> {
  Map<String, dynamic>? productDetails;
  bool isLoading = true;
  YoutubePlayerController? _youtubeController;
  bool _isExpanded = false;
  final TextEditingController commentController = TextEditingController();
  double selectedRating = 0;
  PageController? _reviewPageController;
  Timer? _autoScrollTimer;
  int _currentPage = 0;
  bool showAllReviews = false;
  List<Map<String, dynamic>> productReviews = [];

  @override
  void initState() {
    super.initState();
    fetchProductDetails();
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    _reviewPageController?.dispose();
    _autoScrollTimer?.cancel();
    super.dispose();
  }

  void _setupReviewCarousel() {
    _autoScrollTimer?.cancel();
    _reviewPageController = PageController(viewportFraction: 0.5);

    if (productReviews.isNotEmpty) {
      final totalPages = productReviews.length > 5 ? 5 : productReviews.length;

      _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
        if (_reviewPageController != null &&
            _reviewPageController!.hasClients) {
          setState(() {
            _currentPage = (_currentPage + 1) % totalPages;
          });
          _reviewPageController!.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  Future<void> fetchProductDetails() async {
    try {
      final data = await ApiService.fetchProductDetailsById(widget.productId);
      final details = data['resultData'];

      if (details['youtubeLink'] != null &&
          details['youtubeLink'].toString().isNotEmpty) {
        final videoId = YoutubePlayer.convertUrlToId(details['youtubeLink']);
        _youtubeController = YoutubePlayerController(
          initialVideoId: videoId ?? '',
          flags: const YoutubePlayerFlags(autoPlay: false),
        );
      }

      // Mock reviews data
      productReviews = [
        {'name': 'John Doe', 'rating': 4.5, 'comment': 'Great product!'},
        {'name': 'Jane Smith', 'rating': 5.0, 'comment': 'Highly recommended'},
        {
          'name': 'Robert Brown',
          'rating': 4.0,
          'comment': 'Good value for money',
        },
      ];

      setState(() {
        productDetails = details;
        isLoading = false;
      });

      _setupReviewCarousel();
    } catch (e) {
      setState(() => isLoading = false);
      print("Error: $e");
    }
  }

  Future<void> submitReview() async {
    final comment = commentController.text.trim();
    if (comment.isEmpty || selectedRating == 0) return;

    setState(() {
      productReviews.insert(0, {
        'name': 'You',
        'rating': selectedRating,
        'comment': comment,
        'date': 'Just now',
      });
      commentController.clear();
      selectedRating = 0;
      _setupReviewCarousel();
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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: AppLoadingWidget());
    }

    if (productDetails == null) {
      return const Scaffold(
        body: Center(child: Text("No product details available")),
      );
    }

    final product = productDetails!;
    final imageUrl = product['imageUrl']?.toString() ?? '';
    final gallery =
        (product['gallery'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
    final address = '${product['addressLine1']}, ${product['addressLine2']}';

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
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              "Product Details",
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner + Product Image
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    image: gallery.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(gallery.first),
                            fit: BoxFit.cover,
                          )
                        : null,
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
                      child: imageUrl.isNotEmpty
                          ? Image.network(imageUrl, fit: BoxFit.cover)
                          : const Icon(Icons.image, size: 50),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 80),

            // Product Info Card
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
                        product['productName'] ?? 'Product Name',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "₹${product['price']}",
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.star, color: Colors.amber),
                          SizedBox(width: 5),
                          Text(
                            "4.8",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 5),
                          Text(
                            "• 128 reviews",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Center(
                        // <--- ADD THIS CENTER WIDGET
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment
                              .center, // <--- ADD THIS PROPERTY
                          children: [
                            GestureDetector(
                              onTap: () =>
                                  _launchCaller(product['phoneNumber'] ?? ''),
                              child: _actionButton(
                                FontAwesomeIcons.phone,
                                Colors.lightBlueAccent,
                              ),
                            ),
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: () =>
                                  _launchWhatsApp(product['phoneNumber'] ?? ''),
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
                          ],
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
                        "About Product",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product['about']?.toString() ??
                            'No description available',
                        maxLines: _isExpanded ? null : 3,
                        overflow: _isExpanded ? null : TextOverflow.ellipsis,
                      ),
                      if ((product['about']?.toString().length ?? 0) > 100)
                        TextButton(
                          onPressed: () =>
                              setState(() => _isExpanded = !_isExpanded),
                          child: Text(_isExpanded ? 'Show Less' : 'Read More'),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ⭐ Reviews Section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
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

            if (!showAllReviews && productReviews.isNotEmpty)
              SizedBox(
                height: 210,
                child: PageView.builder(
                  padEnds: false,
                  controller: _reviewPageController,
                  itemCount: productReviews.length > 5
                      ? 5
                      : productReviews.length,
                  itemBuilder: (context, index) {
                    final review = productReviews[index];
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                review['name'] ?? 'Anonymous',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              if (review['date'] != null)
                                Text(
                                  review['date'],
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
                                i < (review['rating'] ?? 0).round()
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
                ),
              ),

            if (!showAllReviews && productReviews.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: Text("No reviews yet")),
              ),

            const SizedBox(height: 10),
            if (!showAllReviews && productReviews.isNotEmpty)
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
                child: Column(
                  children: productReviews.map((review) {
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                review['name'] ?? 'Anonymous',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              if (review['date'] != null)
                                Text(
                                  review['date'],
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
                                i < (review['rating'] ?? 0).round()
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
                  //   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                          onPressed: () =>
                              setState(() => selectedRating = i.toDouble()),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: commentController,
                    decoration: InputDecoration(
                      hintText: "Enter your review...",
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
                      backgroundColor: Colors.redAccent,
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

            // YouTube Video
            if (_youtubeController != null)
              Padding(
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Product Video",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    YoutubePlayer(
                      controller: _youtubeController!,
                      showVideoProgressIndicator: true,
                      progressIndicatorColor: Colors.redAccent,
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // Gallery
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
      ),
      bottomNavigationBar: const Footer(title: "none"),
    );
  }
}

// Action button widget
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
