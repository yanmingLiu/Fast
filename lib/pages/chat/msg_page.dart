import 'dart:io';

import 'package:fast_ai/component/app_dialog.dart';
import 'package:fast_ai/component/f_button.dart';
import 'package:fast_ai/component/f_icon.dart';
import 'package:fast_ai/component/f_image.dart';
import 'package:fast_ai/component/f_toast.dart';
import 'package:fast_ai/gen/assets.gen.dart';
import 'package:fast_ai/pages/chat/chat_input.dart';
import 'package:fast_ai/pages/chat/float_item.dart';
import 'package:fast_ai/pages/chat/level_view.dart';
import 'package:fast_ai/pages/chat/msg_ctr.dart';
import 'package:fast_ai/pages/chat/photo_album.dart';
import 'package:fast_ai/pages/chat/role_lock_view.dart';
import 'package:fast_ai/services/app_cache.dart';
import 'package:fast_ai/services/app_event.dart';
import 'package:fast_ai/services/app_user.dart';
import 'package:fast_ai/tools/app_router.dart';
import 'package:fast_ai/values/app_values.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MsgPage extends StatelessWidget {
  MsgPage({super.key});

  final ctr = Get.put(MsgCtr());

  @override
  Widget build(BuildContext context) {
    final role = ctr.role;

    double bottomPadding = MediaQuery.of(context).viewPadding.bottom;
    var msgBottom = 4 + bottomPadding + 48 + 12 + 26 + 4;

    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Stack(
        children: [
          Positioned.fill(child: FImage(url: ctr.session.background ?? role.avatar)),
          if (AppCache().chatBgImagePath.isNotEmpty)
            Positioned.fill(child: Image.file(File(AppCache().chatBgImagePath), fit: BoxFit.cover)),

          Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              titleSpacing: 0.0,
              leadingWidth: 48,
              leading: FButton(
                width: 44,
                height: 44,
                color: Colors.transparent,
                onTap: () => Get.back(),
                child: Center(child: FIcon(assetName: Assets.svg.back)),
              ),
              actions: [
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: () {
                    AppDialog.showChatLevel();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    padding: EdgeInsets.all(4),
                    child: Center(
                      child: Obx(() {
                        var data = ctr.chatLevel.value;
                        var level = data?.level ?? 1;
                        final map = ctr.chatLevelConfigs.firstWhereOrNull(
                          (element) => element['level'] == level,
                        );
                        var levelStr = map?['icon'] as String?;
                        return Text(levelStr ?? '👋', style: const TextStyle(fontSize: 17));
                      }),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    logEvent('c_call');
                    if (!AppUser().isVip.value) {
                      AppRouter.pushVip(VipFrom.call);
                      return;
                    }

                    if (!AppUser().isBalanceEnough(ConsumeFrom.call)) {
                      AppRouter.pushGem(ConsumeFrom.call);
                      return;
                    }

                    final sessionId = ctr.sessionId;
                    if (sessionId == null) {
                      FToast.toast('Please select a user to call.');
                      return;
                    }

                    AppRouter.pushPhone(sessionId: sessionId, role: role, showVideo: false);
                  },
                  icon: Image.asset(Assets.images.phone.path, width: 24, height: 24),
                ),
                SizedBox(width: 8),
                FButton(
                  height: 24,
                  color: Color(0x801C1C1C),
                  borderRadius: BorderRadius.circular(12),
                  constraints: BoxConstraints(minWidth: 44),
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  onTap: () {
                    AppRouter.pushGem(ConsumeFrom.chat);
                  },
                  child: Center(
                    child: Row(
                      spacing: 4,
                      children: [
                        Assets.images.gems.image(width: 16),
                        Obx(
                          () => Text(
                            AppUser().balance.toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 20),
              ],
            ),
            extendBodyBehindAppBar: true,
            extendBody: true,
            backgroundColor: Colors.transparent,
            body: Stack(
              children: [
                // Positioned.fill(
                //   bottom: msgBottom,
                //   child: MsgListView(role: role, ctr: ctr),
                // ),
                Positioned(bottom: 0, left: 0, right: 0, child: ChatInput()),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: kToolbarHeight,
            child: SafeArea(
              child: Column(
                spacing: 8,
                children: [
                  const PhotoAlbum(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        if (AppCache().isBig) FloatItem(role: role, sessionId: ctr.sessionId ?? 0),
                        const Spacer(),
                        const LevelView(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Obx(() {
            final vip = AppUser().isVip.value;
            if (role.vip == true && !vip) return const Positioned.fill(child: RoleLockView());
            return const SizedBox();
          }),
        ],
      ),
    );
  }
}
