// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:medbook/components/Events/EventsPage2.dart';
// import 'package:medbook/components/Events/EventsPage3.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class EventsPage1 extends StatefulWidget {
//   const EventsPage1({super.key});

//   @override
//   State<EventsPage1> createState() => _EventsCarouselComponentState();
// }

// class _EventsCarouselComponentState extends State<EventsPage1> {
//   late PageController _pageController;
//   int _currentPage = 0;
//   List<Map<String, String>> events = [];
//   late List<Map<String, String>> infiniteEvents;
//   Timer? _timer;
//   bool isLoading = true;
//   String errorMessage = '';

//   @override
//   void initState() {
//     super.initState();
//     _pageController = PageController();
//     _fetchEvents();
//   }

//   Future<void> _fetchEvents() async {
//     try {
//       final response = await http.get(
//         Uri.parse('https://medbook-backend-cd0b.onrender.com/api/event'),
//       );

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> responseData = json.decode(response.body);
//         final List<dynamic> eventList = responseData['resultData'] ?? [];

//         setState(() {
//           events = eventList.map<Map<String, String>>((event) {
//             return {
//               "id": event['id']?.toString() ?? '',
//               "title": event['title']?.toString() ?? 'Event',
//               "image":
//                   event['banner_image']?.toString() ??
//                   'lib/Assets/images/Ads/default.png',
//               "description": event['description']?.toString() ?? '',
//               "youtubeLink": event['youtubeLink']?.toString() ?? '',
//               // You can add gallery images if needed
//             };
//           }).toList();

//           if (events.isNotEmpty) {
//             _initializeCarousel();
//           }
//           isLoading = false;
//         });
//       } else {
//         setState(() {
//           errorMessage = 'Failed to load events: ${response.statusCode}';
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         errorMessage = 'Error fetching events: $e';
//         isLoading = false;
//       });
//     }
//   }

//   void _initializeCarousel() {
//     if (events.isNotEmpty) {
//       infiniteEvents = List.generate(
//         1000,
//         (index) => events[index % events.length],
//       );
//       _currentPage = events.length * 100;
//       _pageController = PageController(initialPage: _currentPage);
//       _startAutoScroll();
//     }
//   }

//   void _startAutoScroll() {
//     _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
//       if (_pageController.hasClients && events.isNotEmpty) {
//         _currentPage++;
//         _pageController.animateToPage(
//           _currentPage,
//           duration: const Duration(milliseconds: 500),
//           curve: Curves.easeInOut,
//         );
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     _pageController.dispose();
//     super.dispose();
//   }

//   @override
//   @override
//   Widget build(BuildContext context) {
//     
//     }

//     if (errorMessage.isNotEmpty) {
//       return Center(child: Text(errorMessage));
//     }

//     if (events.isEmpty) {
//       return const Center(child: Text('No events available'));
//     }

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const SizedBox(height: 20),
//         const SizedBox(height: 20),
//         SizedBox(
//           height: 320, // enough for image + spacing + title
//           child: PageView.builder(
//             controller: _pageController,
//             itemBuilder: (context, index) {
//               final event = infiniteEvents[index];
//               return Material(
//                 elevation: 4,
//                 color: Colors.white,
//                 child: InkWell(
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => EventsPage3(eventId: event["id"]!),
//                       ),
//                     );
//                   },
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Image.network(
//                         event["image"]!,
//                         width: double.infinity,
//                         height: 250,
//                         fit: BoxFit.cover,
//                         errorBuilder: (context, error, stackTrace) =>
//                             Image.asset(''),
//                       ),
//                       const SizedBox(height: 10),
//                       Center(
//                         child: Text(
//                           event["title"] ?? 'No Title',
//                           style: const TextStyle(
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),

//         const SizedBox(height: 12),

//         const SizedBox(height: 12),
//         Padding(
//           padding: const EdgeInsets.symmetric(
//             horizontal: 16.0,
//           ), // Add horizontal padding
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.end, // Align to left
//             children: [
//               SizedBox(
//                 width: 100,
//                 height: 40,
//                 child: ElevatedButton(
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (_) => EventsPage2()),
//                     );
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.deepOrange,
//                     foregroundColor: Colors.white,
//                     textStyle: const TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w500,
//                     ),
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 4,
//                     ),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                   ),
//                   child: const Text("All Events"),
//                 ),
//               ),
//             ],
//           ),
//         ),

//         const SizedBox(height: 20),
//       ],
//     );
//   }
// }

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:medbook/components/Events/EventsPage2.dart';
import 'package:medbook/components/Events/EventsPage3.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:medbook/components/common/loading_widget.dart';

class EventsPage1 extends StatefulWidget {
  const EventsPage1({super.key});

  @override
  State<EventsPage1> createState() => _EventsCarouselComponentState();
}

class _EventsCarouselComponentState extends State<EventsPage1> {
  late PageController _pageController;
  int _currentPage = 0;
  List<Map<String, String>> events = [];
  Timer? _timer;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    try {
      final response = await http.get(
        Uri.parse('https://medbook-backend-cd0b.onrender.com/api/event'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> eventList = responseData['resultData'] ?? [];

        setState(() {
          events = eventList.map<Map<String, String>>((event) {
            return {
              "id": event['id']?.toString() ?? '',
              "title": event['title']?.toString() ?? 'Event',
              "image":
                  event['banner_image']?.toString() ??
                  'lib/Assets/images/Ads/default.png',
              "description": event['description']?.toString() ?? '',
              "youtubeLink": event['youtubeLink']?.toString() ?? '',
            };
          }).toList();

          if (events.isNotEmpty) {
            _initializeCarousel();
          }
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

  void _initializeCarousel() {
    if (events.isNotEmpty) {
      _currentPage = events.length * 100; // start somewhere in the middle
      _pageController = PageController(initialPage: _currentPage);
      _startAutoScroll();
    }
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients && events.isNotEmpty) {
        _currentPage++;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const AppLoadingWidget();
    }

    if (errorMessage.isNotEmpty) {
      return Center(child: Text(errorMessage));
    }

    if (events.isEmpty) {
      return const Center(child: Text('No events available'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const SizedBox(height: 20),
        SizedBox(
          height: 250, // enough for image + spacing + title
          child: PageView.builder(
            controller: _pageController,
            itemBuilder: (context, index) {
              // 🔑 Loop infinitely using modulo
              final event = events[index % events.length];

              return Material(
                elevation: 4,
                color: Colors.white,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EventsPage3(eventId: event["id"]!),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.network(
                        (event["image"] != null && event["image"]!.isNotEmpty)
                            ? event["image"]!
                            : "",
                        width: double.infinity,
                        height: 180,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'lib/Assets/images/product_page2/dummy.jpg',
                            width: double.infinity,
                            height: 180,
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: Text(
                          event["title"] ?? 'No Title',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                width: 100,
                height: 40,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => EventsPage2()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text("All Events"),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
