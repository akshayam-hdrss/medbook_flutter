// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:flutter/material.dart';

// class ImageCarousel extends StatelessWidget {
//   final List<String> imageUrls;

//   const ImageCarousel({super.key, required this.imageUrls});

//   @override
//   Widget build(BuildContext context) {
//     final double screenWidth = MediaQuery.of(context).size.width;
//     final double carouselHeight = screenWidth >= 600 ? 280 : 200;

//     return SizedBox(
//       width: double.infinity,
//       height: carouselHeight,
//       child: CarouselSlider(
//         options: CarouselOptions(
//           height: carouselHeight,
//           autoPlay: true,
//           viewportFraction: 1.0,
//           enlargeCenterPage: false,
//           autoPlayInterval: const Duration(seconds: 3),
//         ),
//         items: imageUrls.map((url) {
//           return Image.network(
//             url,
//             width: double.infinity,
//             height: carouselHeight,
//             fit: BoxFit.cover,
//             errorBuilder: (context, error, stackTrace) {
//               return const Center(child: Icon(Icons.broken_image));
//             },
//           );
//         }).toList(),
//       ),
//     );
//   }
// }

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class ImageCarousel extends StatelessWidget {
  final List<String> imageUrls;

  const ImageCarousel({super.key, required this.imageUrls});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double carouselHeight = screenWidth >= 600 ? 280 : 200;

    return SizedBox(
      width: double.infinity,
      height: carouselHeight,
      child: CarouselSlider.builder(
        itemCount: imageUrls.length,
        itemBuilder: (context, index, realIndex) {
          final url = imageUrls[index];
          return SizedBox(
            width: double.infinity,
            child: Image.network(
              url,
              width: double.infinity,
              height: carouselHeight,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Center(child: Icon(Icons.broken_image));
              },
            ),
          );
        },
        options: CarouselOptions(
          height: carouselHeight,
          autoPlay: true,
          viewportFraction: 1.0, // Ensures full width
          enlargeCenterPage: false,
          autoPlayInterval: const Duration(seconds: 3),
        ),
      ),
    );
  }
}
