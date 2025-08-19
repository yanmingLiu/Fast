import 'package:extended_image/extended_image.dart';
import 'package:fast_ai/gen/assets.gen.dart';
import 'package:flutter/material.dart';

class FImage extends StatefulWidget {
  const FImage({
    super.key,
    this.url,
    this.width,
    this.height,
    this.shape,
    this.border,
    this.borderRadius,
    this.color,
  });

  final String? url;
  final double? width;
  final double? height;
  final BoxShape? shape;
  final BoxBorder? border;
  final BorderRadius? borderRadius;
  final Color? color;

  @override
  State<FImage> createState() => _FImageState();
}

class _FImageState extends State<FImage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    // 初始化动画控制器，持续时间300ms
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // 透明度从0到1的动画
    _opacityAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: widget.width,
      height: widget.height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: widget.borderRadius,
        border: widget.border,
      ),
      child: Assets.images.imagePlace.image(width: 24),
    );

    if (widget.url == null || widget.url!.isEmpty) {
      return placeholder;
    }

    return ExtendedImage.network(
      widget.url!,
      width: widget.width,
      height: widget.height,
      fit: BoxFit.cover,
      borderRadius: widget.borderRadius,
      shape: widget.shape ?? BoxShape.rectangle,
      border: widget.border,
      color: widget.color,
      loadStateChanged: (state) {
        switch (state.extendedImageLoadState) {
          case LoadState.loading:
          case LoadState.failed:
            return Center(child: placeholder);

          case LoadState.completed:
            // 图片加载完成后启动淡入动画
            _animationController.forward();
            // 使用FadeTransition包裹图片实现透明度过渡
            return FadeTransition(opacity: _opacityAnimation, child: state.completedWidget);
        }
      },
    );
  }
}
