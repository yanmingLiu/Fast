import 'package:fast_ai/component/f_button.dart';
import 'package:fast_ai/component/f_image.dart';
import 'package:fast_ai/tools/ext.dart';
import 'package:fast_ai/values/app_text_style.dart';
import 'package:flutter/material.dart';

class ChatItem extends StatelessWidget {
  const ChatItem({
    super.key,
    this.onTap,
    required this.avatar,
    required this.name,
    this.updateTime,
    this.lastMsg,
  });

  final void Function()? onTap;
  final String avatar;
  final String name;
  final String? lastMsg;
  final int? updateTime;

  @override
  Widget build(BuildContext context) {
    return FButton(
      height: 52,
      borderRadius: BorderRadius.circular(0),
      color: Colors.transparent,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        height: 48,
        child: Row(
          spacing: 12,
          children: [
            FImage(
              url: avatar,
              width: 52,
              height: 52,
              shape: BoxShape.circle,
              cacheWidth: 180,
              cacheHeight: 180,
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyle.openSans(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        formatSessionTime(updateTime ?? DateTime.now().millisecondsSinceEpoch),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.openSans(
                          color: Color(0xFF797C7B),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    lastMsg ?? '-',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.openSans(
                      color: Color(0xFF797C7B),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
