import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Private constants for default values and styles.
const double _kDefaultHeight = 48.0;
const Color _kDefaultColor = Color(0x33FFFFFF);
const Color _kShadowColor = Color(0x4D77AFFF);
const Offset _kShadowOffset = Offset(0, 4);
const double _kShadowBlurRadius = 4.0;
const double _kShadowSpreadRadius = 0.0;

/// A custom button component that supports optional shadow, custom styling,
/// and adapts its rendering based on interactivity.
///
/// If [onTap] is provided, it renders a [CupertinoButton] wrapped in a
/// [DecoratedBox] if extra styling (shadow, size) is needed.
/// If [onTap] is null, it renders a static [DecoratedBox].
class FButton extends StatelessWidget {
  const FButton({
    super.key,
    this.child,
    this.borderRadius,
    this.focusColor,
    this.hoverColor,
    this.highlightColor,
    this.height = _kDefaultHeight,
    this.width,
    this.constraints,
    this.onTap,
    this.padding,
    this.margin,
    this.color = _kDefaultColor,
    this.hasShadow = false,
    this.boxShadows,
    this.border,
  });

  /// The widget below this widget in the tree.
  final Widget? child;

  /// The border radius of the button. Defaults to half of the height.
  final BorderRadius? borderRadius;

  /// Color when the button is focused. (Currently unused in implementation).
  final Color? focusColor;

  /// Color when the button is hovered. (Currently unused in implementation).
  final Color? hoverColor;

  /// Color when the button is highlighted. (Currently unused in implementation).
  final Color? highlightColor;

  /// The height of the button. Defaults to 48.0.
  final double? height;

  /// The width of the button.
  final double? width;

  /// Additional constraints for the button.
  /// Note: These are currently used only to trigger the wrapper creation logic
  /// and are not directly applied to the container in the current implementation.
  final BoxConstraints? constraints;

  /// Called when the button is tapped. If null, the button is non-interactive.
  final VoidCallback? onTap;

  /// Padding inside the button.
  final EdgeInsetsGeometry? padding;

  /// Margin around the button.
  final EdgeInsetsGeometry? margin;

  /// Background color of the button. Defaults to a translucent white.
  final Color color;

  /// Whether to show a shadow. Defaults to false.
  final bool hasShadow;

  /// Custom list of box shadows. If provided, overrides the default shadow.
  final List<BoxShadow>? boxShadows;

  /// A border to draw above the background color.
  final BoxBorder? border;

  static final BorderRadius _defaultBorderRadius =
      BorderRadius.circular(_kDefaultHeight / 2);

  static const List<BoxShadow> _defaultBoxShadow = [
    BoxShadow(
      color: _kShadowColor,
      offset: _kShadowOffset,
      blurRadius: _kShadowBlurRadius,
      spreadRadius: _kShadowSpreadRadius,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final BorderRadius effectiveBorderRadius =
        borderRadius ?? _defaultBorderRadius;

    final List<BoxShadow>? effectiveBoxShadow =
        boxShadows ?? (hasShadow ? _defaultBoxShadow : null);

    final Widget content = child ?? const SizedBox.shrink();

    Widget result;

    if (onTap != null) {
      // Interactive mode: Use CupertinoButton for platform-adaptive behavior
      result = CupertinoButton(
        padding: padding ?? EdgeInsets.zero,
        borderRadius: effectiveBorderRadius,
        color: color,
        onPressed: onTap,
        child: content,
      );

      // Wrap with DecoratedBox/SizedBox if we need shadow or specific dimensions
      // that CupertinoButton doesn't handle exactly as desired, or to match
      // original logic.
      if (hasShadow ||
          height != null ||
          width != null ||
          constraints != null ||
          border != null) {
        result = DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: effectiveBorderRadius,
            boxShadow: effectiveBoxShadow,
            border: border,
          ),
          child: SizedBox(
            height: height,
            width: width,
            child: result,
          ),
        );
      }
    } else {
      // Non-interactive mode: Static container
      result = DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          borderRadius: effectiveBorderRadius,
          boxShadow: effectiveBoxShadow,
          border: border,
        ),
        child: SizedBox(
          height: height,
          width: width,
          child: Padding(
            padding: padding ?? EdgeInsets.zero,
            child: content,
          ),
        ),
      );
    }

    if (onTap == null) {
      result = Opacity(
        opacity: 0.6,
        child: result,
      );
    }

    if (margin != null) {
      result = Padding(
        padding: margin!,
        child: result,
      );
    }

    return result;
  }
}
