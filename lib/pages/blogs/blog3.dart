import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:medbook/components/Footer.dart';
import 'package:medbook/components/common/loading_widget.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class BlogPage3 extends StatefulWidget {
  final String blogId;

  const BlogPage3({super.key, required this.blogId});

  @override
  State<BlogPage3> createState() => _BlogPage3State();
}

class _BlogPage3State extends State<BlogPage3> {
  late YoutubePlayerController _controller;
  Map<String, dynamic> blogData = {};
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchBlogData();
  }

  Future<void> fetchBlogData() async {
    try {
      final response = await http.get(
        Uri.parse('https://medbook-backend-1.onrender.com/api/blog/${widget.blogId}'),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        setState(() {
          blogData = jsonResponse['resultData'] ?? {};
          // Initialize YouTube player if videoUrl exists
          if (blogData['videoUrl'] != null) {
            final videoId = YoutubePlayer.convertUrlToId(blogData['videoUrl']);
            _controller = YoutubePlayerController(
              initialVideoId: videoId ?? '',
              flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
            );
          }
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load blog data';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    if (blogData['videoUrl'] != null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: const AppLoadingWidget(),
        bottomNavigationBar: const Footer(title: "none"),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: Text(errorMessage)),
        bottomNavigationBar: const Footer(title: "none"),
      );
    }
    // title: Text(blogData['title'] ?? "Blog Details"),

    return Scaffold(
      backgroundColor: Colors.white,
     appBar: PreferredSize(
  preferredSize: const Size.fromHeight(kToolbarHeight),
  child: AppBar(
    centerTitle: true, 
    title: Text(
      (blogData['title'] ?? "Blog Details"),
      style: const TextStyle(color: Colors.white),
    ),
    flexibleSpace: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE85520), Color(0xFFEA7E4D)], // Your gradient colors
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    ),
    elevation: 2,
    backgroundColor: Colors.transparent, // ✅ Transparent to show gradient
    iconTheme: const IconThemeData(color: Colors.white),
  ),
),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Banner with rounded edges and overlapping profile image
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Banner Image from API
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                  child: blogData['bannerImage'] != null
                      ? Image.network(
                          blogData['bannerImage'],
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 200,
                            color: Colors.grey[300],
                            child: const Icon(Icons.broken_image),
                          ),
                        )
                      : Container(
                          height: 200,
                          color: Colors.grey[300],
                          child: const Center(child: Icon(Icons.image)),
                        ),
                ),
                
                // Profile image overlapping the banner
                Positioned(
                  bottom: -50,
                  left: MediaQuery.of(context).size.width / 2 - 60,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.white, width: 2),
                        image: blogData['imageUrl'] != null
                            ? DecorationImage(
                                image: NetworkImage(blogData['imageUrl']),
                                fit: BoxFit.cover,
                              )
                            : const DecorationImage(
                                image: AssetImage('lib/Assets/images/DoctorPic.png'),
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 60), // Space for the overlapping image

            // Rest of your content...
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Author Name
                  Center(
                    child: Text(
                      blogData['author'] ?? "Unknown Author",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    blogData['title'] ?? "No Title",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Content
                  Text(
                    blogData['content'] ?? "No content available",
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 24),

                  // YouTube Video
                  if (blogData['videoUrl'] != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Video Content",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        YoutubePlayer(
                          controller: _controller,
                          showVideoProgressIndicator: true,
                          progressColors: const ProgressBarColors(
                            playedColor: Colors.red,
                            handleColor: Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 24),

                  // Gallery
                  if (blogData['gallery'] != null && blogData['gallery'].isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Gallery",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 120,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: blogData['gallery'].length,
                            separatorBuilder: (_, __) => const SizedBox(width: 10),
                            itemBuilder: (context, index) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  blogData['gallery'][index],
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    width: 120,
                                    height: 120,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.broken_image),
                                  ),
                                ),
                              );
                            },
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
      bottomNavigationBar: const Footer(title: "none"),
    );
  }
}