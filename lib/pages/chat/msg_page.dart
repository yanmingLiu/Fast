import 'dart:io';

import 'package:fast_ai/component/f_button.dart';
import 'package:fast_ai/component/f_dialog.dart';
import 'package:fast_ai/component/f_icon.dart';
import 'package:fast_ai/component/f_image.dart';
import 'package:fast_ai/component/f_toast.dart';
import 'package:fast_ai/gen/assets.gen.dart';
import 'package:fast_ai/pages/chat/chat_input.dart';
import 'package:fast_ai/pages/chat/float_item.dart';
import 'package:fast_ai/pages/chat/level_view.dart';
import 'package:fast_ai/pages/chat/msg_ctr.dart';
import 'package:fast_ai/pages/chat/msg_list_view.dart';
import 'package:fast_ai/pages/chat/photo_album.dart';
import 'package:fast_ai/pages/chat/role_lock_view.dart';
import 'package:fast_ai/pages/router/n_t_n.dart';
import 'package:fast_ai/services/f_cache.dart';
import 'package:fast_ai/services/f_log_event.dart';
import 'package:fast_ai/services/m_y.dart';
import 'package:fast_ai/values/values.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MsgPage extends StatelessWidget {
  MsgPage({super.key});

  final ctr = Get.put(MsgCtr());

  @override
  Widget build(BuildContext context) {
    final role = ctr.role;

    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Stack(
        children: [
          Positioned.fill(
            child: FImage(url: ctr.session.background ?? role.avatar),
          ),
          if (FCache().chatBgImagePath.isNotEmpty)
            Positioned.fill(
              child: Image.file(
                File(FCache().chatBgImagePath),
                fit: BoxFit.cover,
              ),
            ),
          Scaffold(
            appBar: _buildAppBar(),
            extendBodyBehindAppBar: true,
            extendBody: true,
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: Column(
                children: [
                  const PhotoAlbum(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        if (FCache().isBig)
                          FloatItem(role: role, sessionId: ctr.sessionId ?? 0),
                        const Spacer(),
                        const LevelView(),
                      ],
                    ),
                  ),
                  Expanded(child: MsgListView()),
                  ChatInput(),
                ],
              ),
            ),
          ),
          Obx(() {
            final vip = MY().isVip.value;
            if (role.vip == true && !vip) {
              return const Positioned.fill(child: RoleLockView());
            }
            return const SizedBox();
          }),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
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
            FDialog.showChatLevel();
          },
          child: Container(
            decoration: BoxDecoration(
              color: Color(0x4D000000),
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
                return Text(
                  levelStr ?? '👋',
                  style: const TextStyle(fontSize: 17),
                );
              }),
            ),
          ),
        ),
        IconButton(
          onPressed: () {
            logEvent('c_call');
            if (!MY().isVip.value) {
              NTN.pushVip(ProFrom.call);
              return;
            }

            if (!MY().isBalanceEnough(GemsFrom.call)) {
              NTN.pushGem(GemsFrom.call);
              return;
            }

            final sessionId = ctr.sessionId;
            if (sessionId == null) {
              FToast.toast('Please select a user to call.');
              return;
            }

            NTN.pushPhone(
              sessionId: sessionId,
              role: ctr.role,
              showVideo: false,
            );
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
            NTN.pushGem(GemsFrom.chat);
          },
          child: Center(
            child: Row(
              spacing: 4,
              children: [
                Assets.images.gems.image(width: 16),
                Obx(
                  () => Text(
                    MY().balance.toString(),
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
    );
  }
}
