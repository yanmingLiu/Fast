import 'dart:math' as math;

import 'package:fast_ai/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

class FLoading {
  // 缓存常用的装饰和样式对象，避免重复创建
  static final BoxDecoration _defaultDecoration = BoxDecoration(
    color: Color(0x33FFFFFF),
    borderRadius: BorderRadius.circular(8),
  );

  // 缓存加载图片Widget，避免重复创建
  static Widget? _cachedLoadingImage;

  static Widget get _loadingImage {
    return _cachedLoadingImage ??= Assets.images.loading.image(width: 30);
  }

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
      decoration: _defaultDecoration,
      child: Center(child: RotationWrapper(child: _loadingImage)),
    );
  }

  static Widget loadingWidget() {
    return Center(child: RotationWrapper(child: _loadingImage));
  }
}

// 封装动画状态的StatefulWidget（可复用）
class RotationWrapper extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final bool enableAnimation;

  const RotationWrapper({
    super.key,
    required this.child,
    this.duration = const Duration(seconds: 1),
    this.enableAnimation = true,
  });

  @override
  State<RotationWrapper> createState() => _RotationWrapperState();
}

class _RotationWrapperState extends State<RotationWrapper> with SingleTickerProviderStateMixin {
  // 使用常量避免重复计算
  static const double _fullRotation = 2 * math.pi;

  AnimationController? _controller;
  Animation<double>? _animation;

  // 缓存Tween对象，避免重复创建
  static final Tween<double> _rotationTween = Tween<double>(begin: 0, end: _fullRotation);

  // 缓存CurvedAnimation，减少对象创建
  static const Curve _animationCurve = Curves.linear;

  @override
  void initState() {
    super.initState();

    // 只在需要动画时创建控制器
    if (widget.enableAnimation) {
      _controller = AnimationController(vsync: this, duration: widget.duration);

      _animation = _rotationTween.animate(
        CurvedAnimation(parent: _controller!, curve: _animationCurve),
      );

      _controller!.repeat();
    }
  }

  @override
  void didUpdateWidget(RotationWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 处理动画启用状态变化
    if (widget.enableAnimation != oldWidget.enableAnimation) {
      if (widget.enableAnimation && _controller == null) {
        _controller = AnimationController(vsync: this, duration: widget.duration);
        _animation = _rotationTween.animate(
          CurvedAnimation(parent: _controller!, curve: _animationCurve),
        );
        _controller!.repeat();
      } else if (!widget.enableAnimation && _controller != null) {
        _controller!.stop();
        _controller!.dispose();
        _controller = null;
        _animation = null;
      }
    }

    // 处理持续时间变化
    if (widget.duration != oldWidget.duration && _controller != null) {
      _controller!.duration = widget.duration;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 如果不启用动画，直接返回子widget
    if (!widget.enableAnimation || _animation == null) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _animation!,
      builder: (context, child) {
        // 使用Transform.rotate进行优化的旋转变换
        return Transform.rotate(angle: _animation!.value, child: child);
      },
      child: widget.child,
    );
  }
}
