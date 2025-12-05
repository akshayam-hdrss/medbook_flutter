import 'dart:async';
import 'package:flutter/material.dart';
import 'package:medbook/components/Footer.dart';
import 'package:medbook/components/common/loading_widget.dart';
import 'package:medbook/utils/api_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Traditional4 extends StatefulWidget {
  final String doctorId;
  const Traditional4({super.key, required this.doctorId});

  @override
  _Traditional4State createState() => _Traditional4State();
}

class _Traditional4State extends State<Traditional4> {
  final bool _isExpanded = false;
  late Future<Map<String, dynamic>> doctorDetails;
  late Future<List<Map<String, dynamic>>> doctorReviews;
  final TextEditingController commentController = TextEditingController();
  double selectedRating = 0;
  late YoutubePlayerController _youtubeController;
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

    const videoId = 'YE7VzlLtp-4';
    _youtubeController = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
    );
  }

  @override
  void dispose() {
    _youtubeController.dispose();
    _reviewPageController.dispose();
    _autoScrollTimer?.cancel();
    super.dispose();
  }

  Future<Map<String, dynamic>> fetchDoctorDetails(String id) async {
    final res = await ApiServices.get('/doctor/$id');
    return res['resultData'] is Map<String, dynamic> ? res['resultData'] : {};
  }

  Future<List<Map<String, dynamic>>> fetchDoctorReviews() async {
    final res = await ApiServices.get('/doctor/${widget.doctorId}/reviews');
    if (res['result'] == 'Success' && res['resultData'] is List) {
      return List<Map<String, dynamic>>.from(res['resultData']);
    }
    return [];
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
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            title: FutureBuilder<Map<String, dynamic>>(
              future: doctorDetails,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const AppLoadingWidget();
                }
                final data = snapshot.data ?? {};
                final hasHospital = data['hospitalId'] != null;
                final title = hasHospital ? "Profile" : "Overview";
                return Text(title, style: const TextStyle(color: Colors.white));
              },
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
          ),
        ),
      ),
      body: buildBody(),
      bottomNavigationBar: const Footer(title: "none"),
    );
  }

  Widget buildBody() {
    return FutureBuilder<Map<String, dynamic>>(
      future: doctorDetails,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const AppLoadingWidget();
          
        }
        if (!snapshot.hasData || snapshot.hasError || snapshot.data!.isEmpty) {
          return const Center(child: Text("No doctor details found."));
        }

        final data = snapshot.data!;
        final name = data['name'] ?? 'Unknown';
        final specialization = data['specialization'] ?? '';
        final phone = data['phone'] ?? '';
        final address = data['address'] ?? '';

        return SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16),
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(data['image'] ?? ''),
                backgroundColor: Colors.grey[300],
              ),
              const SizedBox(height: 8),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(specialization, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => _launchCaller(phone),
                    child: _actionButton(Icons.phone, Colors.green),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => _launchWhatsApp(phone),
                    child: _actionButton(
                      FontAwesomeIcons.whatsapp,
                      Colors.teal,
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => _launchMapLink(address),
                    child: _actionButton(Icons.location_on, Colors.red),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // YouTube video
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: YoutubePlayer(controller: _youtubeController),
              ),
              const SizedBox(height: 20),

              // Reviews
              const Text(
                "Patient Reviews",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: doctorReviews,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const AppLoadingWidget();
                  }
                  final reviews = snapshot.data!;
                  if (reviews.isEmpty) return const Text("No reviews yet.");
                  return SizedBox(
                    height: 150,
                    child: PageView.builder(
                      controller: _reviewPageController,
                      itemCount: reviews.length,
                      itemBuilder: (context, index) {
                        final review = reviews[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('"${review['comment']}"'),
                                const SizedBox(height: 4),
                                Text("Rating: ${review['rating']} ⭐"),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Submit review form
              Padding(
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
                    const SizedBox(height: 8),
                    TextField(
                      controller: commentController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Write your feedback...',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: List.generate(5, (index) {
                        final starIndex = index + 1;
                        return IconButton(
                          icon: Icon(
                            Icons.star,
                            color: selectedRating >= starIndex
                                ? Colors.orange
                                : Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              selectedRating = starIndex.toDouble();
                            });
                          },
                        );
                      }),
                    ),
                    ElevatedButton(
                      onPressed: submitReview,
                      child: const Text("Submit Review"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
