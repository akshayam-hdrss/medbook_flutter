import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:medbook/components/Footer.dart';
import 'package:medbook/components/common/loading_widget.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class EventsPage3 extends StatefulWidget {
  final String eventId;
  const EventsPage3({super.key, required this.eventId});

  @override
  State<EventsPage3> createState() => _EventsPage3State();
}

class _EventsPage3State extends State<EventsPage3> {
  Map<String, dynamic>? eventDetails;
  bool isLoading = true;
  String errorMessage = '';
  YoutubePlayerController? _youtubeController;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _fetchEventDetails();
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    super.dispose();
  }

  Future<void> _fetchEventDetails() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://medbook-backend-cd0b.onrender.com/api/event/${widget.eventId}',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final eventData = data['event'] ?? {};

        // Initialize YouTube controller if available
        if (eventData['youtubeLink'] != null &&
            eventData['youtubeLink'].toString().isNotEmpty) {
          final videoId = YoutubePlayer.convertUrlToId(
            eventData['youtubeLink'],
          );
          if (videoId != null) {
            _youtubeController = YoutubePlayerController(
              initialVideoId: videoId,
              flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
            );
          }
        }

        setState(() {
          eventDetails = eventData;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load event: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading event: $e';
        isLoading = false;
      });
    }
  }

  Widget _actionButton(IconData icon, Color color, VoidCallback onPressed) =>
      GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: FaIcon(icon, color: color, size: 22),
        ),
      );

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
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.grey[200],
              child: const Icon(Icons.broken_image),
            ),
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
              "Event Details",
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
          : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage))
          : eventDetails == null
          ? const Center(child: Text('Event not found'))
          : SingleChildScrollView(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final bool isWideScreen = constraints.maxWidth >= 600;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Banner (Always Full Width)
                      Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.bottomCenter,
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 200,
                            child: _buildImageWithPlaceholder(
                              eventDetails?['banner_image'],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 80),

                      // Centered content wrapper (About, YouTube, Gallery)
                      Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: isWideScreen ? 800 : double.infinity,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // About Section
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  color: const Color(0xFFF6F9FF),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "About Event",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          eventDetails?['description'] ??
                                              'No description available',
                                          maxLines: _isExpanded ? null : 3,
                                          overflow: _isExpanded
                                              ? TextOverflow.visible
                                              : TextOverflow.ellipsis,
                                        ),
                                        TextButton(
                                          onPressed: () => setState(
                                            () => _isExpanded = !_isExpanded,
                                          ),
                                          child: Text(
                                            _isExpanded
                                                ? 'Show Less'
                                                : 'Read More',
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
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
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

                              // Gallery Section
                              if (eventDetails?['gallery'] != null &&
                                  (eventDetails!['gallery'] as List).isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                          itemCount:
                                              eventDetails!['gallery'].length,
                                          itemBuilder: (context, index) {
                                            final imageUrl =
                                                eventDetails!['gallery'][index];
                                            return Container(
                                              margin: const EdgeInsets.only(
                                                right: 10,
                                              ),
                                              width: 150,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12),
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
                      ),
                    ],
                  );
                },
              ),
            ),

      bottomNavigationBar: const Footer(title: "none"),
    );
  }
}
