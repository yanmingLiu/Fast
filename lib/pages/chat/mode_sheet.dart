import 'package:fast_ai/gen/assets.gen.dart';
import 'package:fast_ai/generated/locales.g.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ModeSheet extends StatelessWidget {
  const ModeSheet({super.key, required this.isLong, required this.onTap});

  final bool isLong;
  final Function(bool) onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF333333),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      child: Stack(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8),
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  LocaleKeys.reply_mode.tr,
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 16),
                _buildItem(
                  LocaleKeys.short_reply.tr,
                  !isLong,
                  onTap: () {
                    onTap(false);
                  },
                ),
                SizedBox(height: 12),
                _buildItem(
                  LocaleKeys.long_reply.tr,
                  isLong,
                  onTap: () {
                    onTap(true);
                  },
                ),
                SizedBox(height: 34),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(String title, bool isSelected, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Color(0x1AFFFFFF),
          borderRadius: BorderRadius.circular(32),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            if (isSelected) Assets.images.selected.image(width: 24),
          ],
        ),
      ),
    );
  }
}
