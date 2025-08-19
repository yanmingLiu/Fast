import 'package:fast_ai/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

class FLoading {
  static Future showLoading() {
    return SmartDialog.showLoading();
  }

  static Future dismiss() {
    return SmartDialog.dismiss(status: SmartStatus.loading);
  }

  static Widget custom() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(8)),
      child: Center(child: RotationWrapper(child: Assets.images.loading.image(width: 30))),
    );
  }

  static Widget loadingWidget() {
    return Center(child: RotationWrapper(child: Assets.images.loading.image(width: 30)));
  }
}

// 封装动画状态的StatefulWidget（可复用）
class RotationWrapper extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const RotationWrapper({
    super.key,
    required this.child,
    this.duration = const Duration(seconds: 1),
  });

  @override
  State<RotationWrapper> createState() => _RotationWrapperState();
}

class _RotationWrapperState extends State<RotationWrapper> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    _animation = Tween<double>(
      begin: 0,
      end: 2 * 3.14159,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.rotate(angle: _animation.value, child: child);
      },
      child: widget.child,
    );
  }
}
