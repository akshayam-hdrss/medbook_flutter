import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class AppLoadingWidget extends StatelessWidget {
  final double size;
  final Color leftColor;
  final Color rightColor;

  const AppLoadingWidget({
    super.key,
    this.size = 40,
    this.leftColor = const Color.fromARGB(255, 252, 9, 9),
    this.rightColor = const Color.fromARGB(255, 252, 250, 251),
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LoadingAnimationWidget.flickr(
        leftDotColor: leftColor,
        rightDotColor: rightColor,
        size: size,
      ),
    );
  }
}
