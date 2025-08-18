import 'package:fast_ai/gen/assets.gen.dart';
import 'package:fast_ai/generated/locales.g.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class FEmpty extends StatelessWidget {
  const FEmpty({
    super.key,
    required this.type,
    this.hintText,
    this.image,
    this.physics,
    this.size,
    this.loadingIconColor,
    this.onReload,
  });

  final EmptyType type;
  final String? hintText;
  final Widget? image;
  final Size? size;
  final ScrollPhysics? physics;
  final Color? loadingIconColor;
  final void Function()? onReload;

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [];
    if (type == EmptyType.loading) {
      widgets.add(CupertinoActivityIndicator(radius: 16.0, color: loadingIconColor ?? Colors.grey));
    } else {
      String hint = type.text();
      widgets.add(type.image());

      widgets.add(
        Text(
          hintText ?? hint,
          style: GoogleFonts.openSans(
            fontSize: 14,
            color: const Color(0xFFA8A8A8),
            fontWeight: FontWeight.w500,
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      );

      if (type == EmptyType.noNetwork && onReload != null) {
        widgets.add(SizedBox(height: 16));
        widgets.add(
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            child: Container(
              width: 81,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.black,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: const Color(0xFF3F8DFD),
                    ),
                  ),
                  Text(
                    LocaleKeys.reload.tr,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            onTap: () {
              onReload?.call();
            },
          ),
        );
      }
    }

    Widget createContent(double width, double height) {
      if (type != EmptyType.loading && height / width > 1.3) {
        widgets.add(SizedBox(height: 250));
      }
      return ListView(
        padding: EdgeInsets.zero,
        physics: physics ?? const NeverScrollableScrollPhysics(),
        children: [
          SizedBox(
            width: width,
            height: height - kToolbarHeight,
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: widgets),
          ),
        ],
      );
    }

    return size != null
        ? createContent(size!.width, size!.height)
        : createContent(Get.width, Get.height);
  }
}

enum EmptyType {
  // 加载中
  loading,
  // 空
  empty,
  //无网络
  noNetwork,
}

extension EmptyTypeExt on EmptyType {
  // 提供 image 方法，支持自定义宽度和高度，并设置默认宽高
  Widget image({double width = 250, double height = 250}) {
    switch (this) {
      case EmptyType.loading:
        return Assets.images.noLoading.image(width: width, height: height);
      case EmptyType.empty:
        return Assets.images.noData.image(width: width, height: height);
      case EmptyType.noNetwork:
        return Assets.images.noNetwork.image(width: width, height: height);
    }
  }

  String text() {
    switch (this) {
      case EmptyType.loading:
        return LocaleKeys.loading.tr;
      case EmptyType.empty:
        return LocaleKeys.no_data.tr;
      case EmptyType.noNetwork:
        return LocaleKeys.no_network.tr;
    }
  }
}
