import 'package:fast_ai/gen/assets.gen.dart';
import 'package:fast_ai/generated/locales.g.dart';
import 'package:fast_ai/values/app_colors.dart'; // 统一颜色管理
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// A customizable empty state widget that can display loading, empty data,
/// or network error states with appropriate visuals and actions.
class FEmpty extends StatelessWidget {
  // Constants
  static const double _defaultPaddingTop = 100.0;
  static const double _defaultImageSize = 200.0;
  // 使用统一颜色管理，不再需要本地常量
  // static const Color _primaryColor = Color(0xFF3F8DFD);
  // static const Color _hintTextColor = Color(0xFFA8A8A8);

  const FEmpty({
    super.key,
    required this.type,
    this.hintText,
    this.image,
    this.physics,
    this.size,
    this.loadingIconColor,
    this.onReload,
    this.paddingTop,
  });

  /// The type of empty state to display (loading, empty, or no network)
  final EmptyType type;

  /// Optional custom hint text to override the default text for the type
  final String? hintText;

  /// Optional custom image to override the default image for the type
  final Widget? image;

  /// Optional custom size for the container
  final Size? size;

  /// Optional scroll physics for the SingleChildScrollView
  final ScrollPhysics? physics;

  /// Optional color for the loading indicator
  final Color? loadingIconColor;

  /// Optional callback when the reload button is pressed
  final VoidCallback? onReload;

  /// Optional padding from the top of the container
  final double? paddingTop;

  /// Builds a reload button with consistent styling
  Widget _buildReloadButton() {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onReload,
      child: Container(
        width: 81,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColors.primary,
        ),
        child: Text(
          LocaleKeys.reload.tr,
          style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  /// Creates the content with appropriate dimensions
  Widget _createContent(double width, double height, List<Widget> widgets) {
    // Add extra space for tall screens
    if (type != EmptyType.loading && height / width > 1.3) {
      widgets.add(const SizedBox(height: _defaultImageSize));
    }

    return SingleChildScrollView(
      padding: EdgeInsets.zero,
      physics: physics ?? const NeverScrollableScrollPhysics(),
      child: Container(
        width: width,
        height: height - kToolbarHeight,
        padding: EdgeInsets.only(top: paddingTop ?? _defaultPaddingTop),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: widgets,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgets = [];

    if (type == EmptyType.loading) {
      // Loading state - show activity indicator
      widgets.add(
        CupertinoActivityIndicator(radius: 16.0, color: loadingIconColor ?? AppColors.primary),
      );
    } else {
      // Empty or No Network state
      // Use custom image if provided, otherwise use default for the type
      widgets.add(image ?? type.image());

      // Add hint text
      final String hint = type.text();
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            hintText ?? hint,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.hintText,
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );

      // Add reload button for network error if callback is provided
      if (type == EmptyType.noNetwork && onReload != null) {
        widgets.add(const SizedBox(height: 16));
        widgets.add(_buildReloadButton());
      }
    }

    // Use provided size or get screen dimensions
    final Size screenSize = size ?? Size(Get.width, Get.height);
    return _createContent(screenSize.width, screenSize.height, widgets);
  }
}

/// Represents different types of empty states that can be displayed
enum EmptyType {
  /// Loading state - shows a loading indicator
  loading,

  /// Empty state - shows an empty data image and message
  noData,

  /// No network state - shows a network error image, message and reload button
  noNetwork,
}

/// Extension methods for EmptyType to provide associated assets and text
extension EmptyTypeExt on EmptyType {
  /// Returns the appropriate image widget for this empty state type
  ///
  /// [width] and [height] can be customized (defaults to the default image size)
  Widget image({
    double width = FEmpty._defaultImageSize,
    double height = FEmpty._defaultImageSize,
  }) {
    switch (this) {
      case EmptyType.loading:
        return Assets.images.noLoading.image(width: width, height: height);
      case EmptyType.noData:
        return Assets.images.noData.image(width: width, height: height);
      case EmptyType.noNetwork:
        return Assets.images.noNetwork.image(width: width, height: height);
    }
  }

  /// Returns the localized text message for this empty state type
  String text() {
    switch (this) {
      case EmptyType.loading:
        return LocaleKeys.loading.tr;
      case EmptyType.noData:
        return LocaleKeys.no_data.tr;
      case EmptyType.noNetwork:
        return LocaleKeys.no_network.tr;
    }
  }
}
