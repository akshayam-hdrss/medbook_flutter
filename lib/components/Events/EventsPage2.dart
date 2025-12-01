import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:medbook/components/Events/EventsPage3.dart';
import 'package:medbook/components/Footer.dart';
import 'package:medbook/components/common/loading_widget.dart';

class EventsPage2 extends StatefulWidget {
  const EventsPage2({super.key});

  @override
  State<EventsPage2> createState() => _EventsPage2State();
}

class _EventsPage2State extends State<EventsPage2> {
  List<Map<String, dynamic>> events = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    final url = Uri.parse(
      'https://medbook-backend-cd0b.onrender.com/api/event/',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> eventList = responseData['resultData'] ?? [];

        setState(() {
          events = eventList.map<Map<String, dynamic>>((event) {
            return {
              'id': event['id']?.toString(),
              'title': event['title']?.toString() ?? 'No Title',
              'description': event['description']?.toString() ?? '',
              'banner_image': event['banner_image']?.toString() ?? '',
              'youtubeLink': event['youtubeLink']?.toString() ?? '',
              'gallery': List<String>.from(
                event['gallery']?.map((img) => img.toString()) ?? [],
              ),
            };
          }).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load events: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching events: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 225, 119, 20), // Orange
                Color.fromARGB(255, 239, 48, 34), // Red
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 2,
            centerTitle: true,
            iconTheme: const IconThemeData(color: Colors.white),
            title: const Text(
              "All Events",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
        ),
      ),

      body: isLoading
          ? const AppLoadingWidget()
          : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage))
          : events.isEmpty
          ? const Center(child: Text('No events available'))
          : LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount;
                double cardWidth = constraints.maxWidth;

                if (cardWidth >= 1024) {
                  crossAxisCount = 3;
                } else if (cardWidth >= 600) {
                  crossAxisCount = 2;
                } else {
                  crossAxisCount = 1;
                }

                // Declare childAspectRatio first
                double childAspectRatio;

                if (constraints.maxWidth < 400) {
                  childAspectRatio = 1.2;
                } else if (constraints.maxWidth < 600) {
                  childAspectRatio = 1.1;
                } else {
                  childAspectRatio = 1.4;
                }

                double itemWidth = (cardWidth / crossAxisCount) - 16;
                double itemHeight = itemWidth * 0.75 + 80;

                Widget grid = GridView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  itemCount: events.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: childAspectRatio,
                  ),
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EventsPage3(eventId: event["id"]),
                          ),
                        );
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(8),
                              ),
                              child: Image.network(
                                event["banner_image"] ?? '',
                                width: double.infinity,
                                height: itemWidth * 0.5,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      height: itemWidth * 0.5,
                                      color: Colors.grey[200],
                                      child: const Center(
                                        child: Icon(Icons.broken_image),
                                      ),
                                    ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: Text(
                                  event["title"] ?? 'No Title',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );

                return constraints.maxWidth < 600
                    ? Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 400),
                          child: grid,
                        ),
                      )
                    : grid;
              },
            ),
      bottomNavigationBar: const Footer(title: "none"),
    );
  }
}
