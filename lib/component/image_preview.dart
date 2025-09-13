import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';

class ImagePreview extends StatefulWidget {
  const ImagePreview({super.key});

  @override
  State<ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  late String imageUrl;

  // 添加下滑关闭所需的状态变量
  double _dragDistance = 0.0;
  double _opacity = 1.0;
  static const double _dragThreshold = 150.0; // 下滑多少距离后关闭

  // 用于判断当前PhotoView是否在缩放状态
  final PhotoViewScaleStateController _scaleStateController = PhotoViewScaleStateController();
  bool get _canDragToClose => _scaleStateController.scaleState == PhotoViewScaleState.initial;

  @override
  void initState() {
    imageUrl = Get.arguments;
    super.initState();
  }

  @override
  void dispose() {
    _scaleStateController.dispose();
    super.dispose();
  }

  // 处理垂直拖动
  void _handleVerticalDrag(DragUpdateDetails details) {
    // 只有在PhotoView未缩放时才允许下滑关闭
    if (_canDragToClose && details.delta.dy > 0) {
      setState(() {
        _dragDistance += details.delta.dy;
        // 计算不透明度，随着拖动距离增加而降低
        _opacity = 1.0 - (_dragDistance / _dragThreshold).clamp(0.0, 0.6);
      });
    }
  }

  // 处理拖动结束
  void _handleDragEnd(DragEndDetails details) {
    if (_dragDistance > _dragThreshold) {
      // 超过阈值，关闭页面
      Get.back();
    } else {
      // 未超过阈值，恢复原状
      setState(() {
        _dragDistance = 0.0;
        _opacity = 1.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // 添加垂直拖动手势，但不干扰PhotoView的其他手势
      onVerticalDragUpdate: _canDragToClose ? _handleVerticalDrag : null,
      onVerticalDragEnd: _canDragToClose ? _handleDragEnd : null,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // 使用Transform和Opacity实现拖动效果
            Transform.translate(
              offset: Offset(0, _dragDistance),
              child: Opacity(
                opacity: _opacity,
                child: Center(
                  child: PhotoView(
                    tightMode: true,
                    imageProvider: ExtendedNetworkImageProvider(imageUrl, cache: true),
                    scaleStateController: _scaleStateController,
                    scaleStateChangedCallback: (state) {
                      // 当缩放状态改变时触发setState以更新_canDragToClose
                      setState(() {});
                    },
                    minScale: PhotoViewComputedScale.contained,
                    maxScale: PhotoViewComputedScale.covered * 2,
                  ),
                ),
              ),
            ),
            SafeArea(
              child: GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  margin: const EdgeInsets.only(left: 16),
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Color(0x26000000),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(child: Icon(Icons.close, color: Colors.white, size: 22)),
                ),
              ),
            ),
            // 下滑指示器
            if (_dragDistance > 0)
              Positioned(
                top: 80,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    'Swipe down to close',
                    style: TextStyle(color: Color(0xCCFFFFFF), fontSize: 14),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
