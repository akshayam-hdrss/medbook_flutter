// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:flutter/material.dart';
// import 'package:youtube_player_flutter/youtube_player_flutter.dart';

// class VideoCarousel extends StatefulWidget {
//   final List<String> videoUrls;

//   const VideoCarousel({super.key, required this.videoUrls});

//   @override
//   State<VideoCarousel> createState() => _VideoCarouselState();
// }

// class _VideoCarouselState extends State<VideoCarousel> {
//   final List<YoutubePlayerController> _controllers = [];
//   bool _isAnyVideoPlaying = false; // Track if any video is playing

//   @override
//   void initState() {
//     super.initState();
//     _initControllers();
//   }

//   @override
//   void didUpdateWidget(VideoCarousel oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.videoUrls != widget.videoUrls) {
//       _disposeControllers();
//       _initControllers();
//       setState(() {});
//     }
//   }

//   void _initControllers() {
//     _controllers.clear();
//     for (var url in widget.videoUrls) {
//       final videoId = YoutubePlayer.convertUrlToId(url);
//       if (videoId != null) {
//         final controller = YoutubePlayerController(
//           initialVideoId: videoId,
//           flags: const YoutubePlayerFlags(
//             autoPlay: true,
//             mute: true,
//             loop: true,
//             disableDragSeek: false,
//             hideControls: false,
//             controlsVisibleAtStart: true,
//           ),
//         );

//         // Listen for play/pause
//         controller.addListener(() {
//           if (!mounted) return;
//           final isPlaying = controller.value.isPlaying;
//           if (isPlaying != _isAnyVideoPlaying) {
//             setState(() {
//               _isAnyVideoPlaying = isPlaying;
//             });
//           }
//         });

//         _controllers.add(controller);
//       }
//     }
//   }

//   void _disposeControllers() {
//     for (var controller in _controllers) {
//       controller.dispose();
//     }
//     _controllers.clear();
//   }

//   @override
//   void dispose() {
//     _disposeControllers();
//     super.dispose();
//   }

//   bool isValidYoutubeUrl(String url) {
//     final uri = Uri.tryParse(url);
//     return uri != null &&
//         (uri.host.contains('youtube.com') || uri.host.contains('youtu.be'));
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (widget.videoUrls.isEmpty ||
//         _controllers.length != widget.videoUrls.length) {
//       return const Center(
//         child: Text(
//           'No valid YouTube videos available.',
//           style: TextStyle(color: Colors.grey),
//         ),
//       );
//     }

//     return SizedBox(
//       width: double.infinity,
//       child: CarouselSlider.builder(
//         itemCount: widget.videoUrls.length,
//         itemBuilder: (context, index, realIndex) {
//           final url = widget.videoUrls[index];
//           final isValid = isValidYoutubeUrl(url);

//           if (!isValid || YoutubePlayer.convertUrlToId(url) == null) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Icon(Icons.error, color: Colors.red, size: 40),
//                   const SizedBox(height: 8),
//                   Text(
//                     'Invalid YouTube link:\n$url',
//                     textAlign: TextAlign.center,
//                     style: const TextStyle(color: Colors.red),
//                   ),
//                 ],
//               ),
//             );
//           }

//           final controller = _controllers[index];

//           return Stack(
//             alignment: Alignment.bottomRight,
//             children: [
//               YoutubePlayer(
//                 controller: controller,
//                 showVideoProgressIndicator: true,
//                 progressColors: const ProgressBarColors(
//                   playedColor: Colors.red,
//                   handleColor: Colors.redAccent,
//                 ),
//               ),
//               Positioned(
//                 bottom: 10,
//                 right: 10,
//                 child: IconButton(
//                   icon: Icon(
//                     controller.value.volume == 0
//                         ? Icons.volume_off
//                         : Icons.volume_up,
//                     color: Colors.white,
//                     size: 30,
//                   ),
//                   onPressed: () {
//                     setState(() {
//                       if (controller.value.volume == 0) {
//                         controller.setVolume(100); // Unmute
//                       } else {
//                         controller.setVolume(0); // Mute
//                       }
//                     });
//                   },
//                 ),
//               ),
//             ],
//           );
//         },
//         options: CarouselOptions(
//           height: 300,
//           autoPlay: !_isAnyVideoPlaying, // 🚀 Stop autoplay when video plays
//           autoPlayInterval: const Duration(seconds: 10),
//           enlargeCenterPage: false,
//           viewportFraction: 1.0,
//           aspectRatio: 16 / 9,
//         ),
//       ),
//     );
//   }
// }

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoCarousel extends StatefulWidget {
  final List<String> videoUrls;

  const VideoCarousel({super.key, required this.videoUrls});

  @override
  State<VideoCarousel> createState() => _VideoCarouselState();
}

class _VideoCarouselState extends State<VideoCarousel> {
  final List<YoutubePlayerController> _controllers = [];
  final List<bool> _isMuted = []; // Track mute state manually
  bool _isAnyVideoPlaying = false;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  @override
  void didUpdateWidget(VideoCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrls != widget.videoUrls) {
      _disposeControllers();
      _initControllers();
      setState(() {});
    }
  }

  void _initControllers() {
    _controllers.clear();
    _isMuted.clear();

    for (var url in widget.videoUrls) {
      final videoId = YoutubePlayer.convertUrlToId(url);
      if (videoId != null) {
        final controller = YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(
            autoPlay: true,
            mute: true, // start muted
            loop: true,
            hideControls: false,
            controlsVisibleAtStart: true,
          ),
        );

        _controllers.add(controller);
        _isMuted.add(true); // start as muted

        controller.addListener(() {
          if (!mounted) return;
          final anyPlaying = _controllers.any((c) => c.value.isPlaying == true);
          if (anyPlaying != _isAnyVideoPlaying) {
            setState(() {
              _isAnyVideoPlaying = anyPlaying;
            });
          }
        });
      }
    }
  }

  void _disposeControllers() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    _controllers.clear();
    _isMuted.clear();
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  bool isValidYoutubeUrl(String url) {
    final uri = Uri.tryParse(url);
    return uri != null &&
        (uri.host.contains('youtube.com') || uri.host.contains('youtu.be'));
  }

  void _toggleMute(int index) {
    final controller = _controllers[index];
    final muted = _isMuted[index];

    if (muted) {
      controller.unMute();
    } else {
      controller.mute();
    }

    setState(() {
      _isMuted[index] = !muted;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.videoUrls.isEmpty ||
        _controllers.length != widget.videoUrls.length) {
      return const Center(
        child: Text(
          'No valid YouTube videos available.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: CarouselSlider.builder(
        itemCount: widget.videoUrls.length,
        itemBuilder: (context, index, realIndex) {
          final url = widget.videoUrls[index];
          if (!isValidYoutubeUrl(url)) {
            return const Center(
              child: Icon(Icons.error, color: Colors.red, size: 40),
            );
          }

          final controller = _controllers[index];

          return Stack(
            alignment: Alignment.bottomRight,
            children: [
              YoutubePlayer(
                controller: controller,
                showVideoProgressIndicator: true,
                progressColors: const ProgressBarColors(
                  playedColor: Colors.red,
                  handleColor: Colors.redAccent,
                ),
              ),
              Positioned(
                bottom: 10,
                right: 10,
                child: IconButton(
                  icon: Icon(
                    _isMuted[index] ? Icons.volume_off : Icons.volume_up,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: () => _toggleMute(index),
                ),
              ),
            ],
          );
        },
        options: CarouselOptions(
          height: 300,
          autoPlay: !_isAnyVideoPlaying, // stop autoplay when a video plays
          autoPlayInterval: const Duration(seconds: 10),
          viewportFraction: 1.0,
          aspectRatio: 16 / 9,
        ),
      ),
    );
  }
}
