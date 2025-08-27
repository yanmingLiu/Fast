import 'package:fast_ai/values/app_colors.dart'; // 统一颜色管理
import 'package:flutter/material.dart';

class FSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color activeColor;
  final Color thumbColor;
  final Color trackColor;

  const FSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.activeColor = AppColors.primary,
    this.thumbColor = const Color(0xFFFFFFFF),
    this.trackColor = const Color(0xFFB3B3B3),
  });

  @override
  State<FSwitch> createState() => _FSwitchState();
}

class _FSwitchState extends State<FSwitch> {
  @override
  Widget build(BuildContext context) {
    bool value = widget.value; // 直接使用传入的 value 控制外观
    final width = 50.0;
    final height = 30.0;
    final thumbWidth = 26.0;
    final radius = 2.0;
    final space = width - thumbWidth - radius * 2;

    return GestureDetector(
      onTap: () {
        setState(() {
          value = !value;
          if (widget.onChanged != null) {
            widget.onChanged!(value);
          }
        });
      },
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: value ? widget.activeColor : widget.trackColor,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              left: value ? space : radius,
              right: value ? radius : space,
              child: Container(
                width: thumbWidth,
                height: thumbWidth,
                decoration: BoxDecoration(shape: BoxShape.circle, color: widget.thumbColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
