import 'package:fast_ai/component/f_image.dart';
import 'package:fast_ai/component/f_progress.dart';
import 'package:fast_ai/gen/assets.gen.dart';
import 'package:fast_ai/pages/chat/msg_ctr.dart';
import 'package:fast_ai/pages/router/app_router.dart';
import 'package:fast_ai/values/theme_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LevelView extends StatelessWidget {
  const LevelView({super.key});

  String formatNumber(double? value) {
    if (value == null) {
      return '0';
    }
    if (value % 1 == 0) {
      // 如果小数部分为 0，返回整数
      return value.toInt().toString();
    } else {
      // 如果有小数部分，返回原值
      return value.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctr = Get.find<MsgCtr>();
    return Obx(() {
      final data = ctr.chatLevel.value;
      if (data == null) {
        return const SizedBox();
      }

      var level = data.level ?? 1;
      var progress = (data.progress ?? 0) / 100.0;
      var rewards = '+${data.rewards ?? 0}';

      var value = formatNumber(data.progress);
      // var total = data.upgradeRequirements?.toInt() ?? 0;
      // var proText = '$value/$total';

      return GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
          AppRouter.pushProfile(ctr.role);
        },
        child: Container(
          width: 160,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0x801C1C1C),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                spacing: 4,
                children: [
                  Row(
                    spacing: 4,
                    children: [
                      FImage(
                        url: ctr.role.avatar,
                        width: 20,
                        height: 20,
                        shape: BoxShape.circle,
                        cacheWidth: 80,
                        cacheHeight: 80,
                      ),
                      Expanded(
                        child: Text(
                          ctr.role.name ?? '',
                          overflow: TextOverflow.ellipsis,
                          style: ThemeStyle.openSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  AnimationProgress(
                      progress: progress,
                      height: 4,
                      borderRadius: 2,
                      width: 128),
                  Row(
                    spacing: 4,
                    children: [
                      Text(
                        'Lv $level',
                        style: ThemeStyle.openSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFFE4E5FF),
                        ),
                      ),
                      Text(
                        '$value%',
                        style: ThemeStyle.openSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      ),
                      Spacer(),
                      Assets.images.gems.image(width: 16),
                      Text(
                        rewards,
                        style: ThemeStyle.openSans(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}
