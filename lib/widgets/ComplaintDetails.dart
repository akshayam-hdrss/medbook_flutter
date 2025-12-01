





import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

void showComplaintDetailsDialog(BuildContext context, Map<String, dynamic> complaint) {
  final List<String> gallery = List<String>.from(complaint['gallery'] ?? []);
  final ScrollController scrollController = ScrollController();

  showDialog(
    context: context,
    builder: (context) {
      // Delay scroll to top after the dialog is shown
      Future.delayed(const Duration(milliseconds: 300), () {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      });

      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Scrollbar(
            controller: scrollController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    complaint['subject'] ?? 'Complaint',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  if (gallery.isNotEmpty) ...[
                    const Text('Gallery:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 180,
                      child: CarouselSlider(
                        options: CarouselOptions(
                          height: 180,
                          enableInfiniteScroll: true,
                          enlargeCenterPage: true,
                          viewportFraction: 0.9,
                          autoPlay: true,
                          autoPlayInterval: const Duration(seconds: 3),
                          autoPlayAnimationDuration: const Duration(milliseconds: 800),
                          autoPlayCurve: Curves.fastOutSlowIn,
                        ),
                        items: gallery.map((imageUrl) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.broken_image),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (complaint['description'] != null) ...[
                    const Text('Description:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(complaint['description']),
                    const SizedBox(height: 12),
                  ],

                  if (complaint['location'] != null) ...[
                    const Text('Location:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(complaint['location']),
                    const SizedBox(height: 12),
                  ],

                  if (complaint['createdAt'] != null) ...[
                    const Text('Date:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(complaint['createdAt']),
                    const SizedBox(height: 12),
                  ],

                  const Divider(),

                  const Text('How we resolved it:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    complaint['resolution'] ?? 'Resolution details will appear here once available.',
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 16),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close'),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
