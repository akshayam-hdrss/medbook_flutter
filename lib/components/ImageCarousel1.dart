import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class ImageCarousel1 extends StatelessWidget {
  final List<String> imageUrls;

  const ImageCarousel1({super.key, required this.imageUrls});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double carouselHeight = screenWidth >= 600 ? 280 : 200;

    return SizedBox(
      height:
          carouselHeight +
          60, // Overall height adjusted to fit smaller background
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Shorter red rectangular background
          Positioned(
            bottom: 0, // 👈 This puts the red container at the bottom
            left: 0,
            right: 0,
            child: Container(height: 90, color: const Color(0xFFC72108)),
          ),

          // Carousel floating above red container
          Positioned(
            bottom: 30, // Position carousel above the red container
            left: 20,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: CarouselSlider(
                options: CarouselOptions(
                  height: carouselHeight,
                  autoPlay: true,
                  viewportFraction: 1.0,
                  enlargeCenterPage: false,
                  autoPlayInterval: const Duration(seconds: 3),
                ),
                // items: imageUrls.map((url) {
                //   return ClipRRect(
                //     // borderRadius: BorderRadius.circular(12),
                //     child: Image.network(
                //       url,
                //       width: double.infinity,
                //       height: carouselHeight,
                //       fit: BoxFit.cover,
                //       errorBuilder: (context, error, stackTrace) {
                //         return const Center(child: Icon(Icons.broken_image));
                //       },
                items: imageUrls.map((url) {
                  return ClipRRect(
                    // borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color.fromARGB(
                            255,
                            255,
                            255,
                            255,
                          ), // You can change the color here
                          width: 3.0, // Thickness of the border
                        ),
                      ),
                      child: Image.network(
                        url,
                        width: double.infinity,
                        height: carouselHeight,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(child: Icon(Icons.broken_image));
                        },
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
