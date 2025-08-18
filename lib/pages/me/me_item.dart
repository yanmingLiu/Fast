import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MeItem extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: top),
        if (sectionTitle != null)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              onLongPress: onTapSection,
              child: Text(
                sectionTitle!,
                style: GoogleFonts.openSans(
                  color: Color(0xFF858585),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              height: 52,
              child: Column(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.openSans(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            subtitle ?? '',
                            textAlign: TextAlign.right,
                            style: GoogleFonts.openSans(
                              color: Color(0xFF858585),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (subWidget != null) subWidget!,
                        if (subWidget == null) const SizedBox(width: 4),
                        if (subWidget == null)
                          const Icon(Icons.chevron_right, color: Color(0xFF808080)),
                      ],
                    ),
                  ),
                  if (showLine) Container(color: Color(0xFF858585), height: 1),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
