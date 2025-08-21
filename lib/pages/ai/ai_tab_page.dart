import 'package:fast_ai/gen/assets.gen.dart';
import 'package:flutter/material.dart';

class AiTabPage extends StatelessWidget {
  const AiTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [Positioned(top: 0, left: 0, right: 0, child: Assets.images.pageBg.image())],
      ),
    );
  }
}
