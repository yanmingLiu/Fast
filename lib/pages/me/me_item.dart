import 'package:fast_ai/values/app_text_style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MeItem extends StatefulWidget {
  const MeItem({
    super.key,
    required this.title,
    this.subtitle,
    this.onTap,
    this.sectionTitle,
    this.top = 0.0,
    this.onTapSection,
    this.showLine = false,
    this.showTopRadius = false,
    this.showBottomRadius = false,
    this.subWidget,
  });

  final String title;
  final String? subtitle;
  final String? sectionTitle;
  final void Function()? onTap;
  final void Function()? onTapSection;
  final double top;
  final bool showLine;
  final bool showTopRadius;
  final bool showBottomRadius;
  final Widget? subWidget;

  @override
  State<MeItem> createState() => _MeItemState();
}

class _MeItemState extends State<MeItem> {
  int _tapCount = 0;
  DateTime? _lastTapTime;

  // 样式全部用局部变量，避免 static final 导致内存无法释放

  void _handleSectionTap() {
    if (widget.onTapSection == null) return;

    final now = DateTime.now();

    // 重置计数器如果距离上次点击超过2秒
    if (_lastTapTime == null || now.difference(_lastTapTime!).inSeconds > 2) {
      _tapCount = 1;
    } else {
      _tapCount++;
    }

    _lastTapTime = now;

    // 点击7次触发回调
    if (_tapCount >= 7) {
      _tapCount = 0;
      _lastTapTime = null;
      widget.onTapSection!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final sectionTitleStyle = AppTextStyle.openSans(
      color: const Color(0xFF858585),
      fontSize: 12,
      fontWeight: FontWeight.w400,
    );
    final titleStyle = AppTextStyle.openSans(
      color: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.w700,
    );
    final subtitleStyle = AppTextStyle.openSans(
      color: const Color(0xFF858585),
      fontSize: 12,
      fontWeight: FontWeight.w500,
    );
    const spacing8 = SizedBox(width: 8);
    const spacing4 = SizedBox(width: 4);
    const chevronIcon = Icon(Icons.chevron_right, color: Color(0xFF808080));

    final borderRadius = BorderRadius.vertical(
      top: widget.showTopRadius ? const Radius.circular(8) : Radius.zero,
      bottom: widget.showBottomRadius ? const Radius.circular(8) : Radius.zero,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.top > 0) SizedBox(height: widget.top),
        if (widget.sectionTitle != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              onTap: _handleSectionTap,
              child: Text(widget.sectionTitle!, style: sectionTitleStyle),
            ),
          ),
        Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: borderRadius,
          ),
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            borderRadius: borderRadius,
            onPressed: widget.onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 52,
              child: Column(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Text(widget.title, style: titleStyle),
                        spacing8,
                        Expanded(
                          child: widget.subtitle != null
                              ? Text(
                                  widget.subtitle!,
                                  textAlign: TextAlign.right,
                                  style: subtitleStyle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                )
                              : const SizedBox.shrink(),
                        ),
                        if (widget.subWidget != null)
                          widget.subWidget!
                        else ...[
                          spacing4,
                          chevronIcon,
                        ],
                      ],
                    ),
                  ),
                  if (widget.showLine)
                    const Divider(
                      color: Color(0xFF858585),
                      height: 1,
                      thickness: 1,
                      indent: 0,
                      endIndent: 0,
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
