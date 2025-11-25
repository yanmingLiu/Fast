import 'package:fast_ai/component/f_button.dart';
import 'package:fast_ai/component/f_link_tab_controller.dart';
import 'package:fast_ai/gen/assets.gen.dart';
import 'package:fast_ai/generated/locales.g.dart';
import 'package:fast_ai/pages/chat/chat_ctr.dart';
import 'package:fast_ai/pages/chat/chat_list_view.dart';
import 'package:fast_ai/pages/chat/liked_ctr.dart';
import 'package:fast_ai/pages/chat/liked_list_view.dart';
import 'package:fast_ai/services/f_service.dart';
import 'package:fast_ai/values/theme_colors.dart'; // 统一颜色管理
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../component/f_keep_alive.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final chatCtr = Get.put(ChatCtr());
  final likedCtr = Get.put(LikedCtr());

  final titles = [LocaleKeys.chatted.tr, LocaleKeys.liked.tr];
  late FLinkTabController _linkedController;

  @override
  void initState() {
    super.initState();

    _linkedController = FLinkTabController(
      items: titles,
      onIndexChanged: (value) {
        log.d("value: $value");
        if (value == 0) {
          chatCtr.onRefresh();
        } else {
          likedCtr.onRefresh();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
              top: 0, left: 0, right: 0, child: Assets.images.pageBg.image()),
          SafeArea(
            child: Column(
              children: [
                buildCategory(),
                Expanded(
                  child: PageView(
                    controller: _linkedController.pageController,
                    pageSnapping: true,
                    onPageChanged: (index) {
                      _linkedController.handlePageChanged(index);
                    },
                    physics: BouncingScrollPhysics(),
                    children: [
                      FKeepAlive(child: ChatListView(controller: chatCtr)),
                      FKeepAlive(child: LikedListView(controller: likedCtr)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCategory() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        height: 48,
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: ThemeColors.white10,
          border: BoxBorder.all(color: ThemeColors.white20, width: 1),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          spacing: 12,
          children: [
            Expanded(
                child: _buildItem(
                    Assets.images.chatted.image(width: 20), titles[0], 0)),
            Expanded(
                child: _buildItem(
                    Assets.images.liked.image(width: 20), titles[1], 1)),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(Widget icon, String title, int index) {
    return GestureDetector(
      child: AnimatedBuilder(
        animation: _linkedController,
        builder: (_, v) {
          return GestureDetector(
            child: AnimatedBuilder(
              animation: _linkedController,
              builder: (_, v) {
                final isActive = _linkedController.index == index;
                return buildTabItem(
                  key: _linkedController.getTabKey(index),
                  icon: icon,
                  title: title,
                  isActive: isActive,
                  onTap: () {
                    _linkedController.select(index);
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget buildTabItem({
    Key? key,
    required Widget icon,
    required String title,
    required bool isActive,
    void Function()? onTap,
  }) {
    return FButton(
      key: key,
      borderRadius: BorderRadius.circular(16),
      color: isActive ? ThemeColors.primary : Colors.transparent,
      highlightColor: ThemeColors.primaryLight,
      onTap: onTap,
      padding: EdgeInsets.symmetric(horizontal: 8),
      constraints: BoxConstraints(minWidth: 50),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 4,
        children: [
          isActive ? icon : SizedBox(width: 20),
          Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isActive ? Colors.white : Color(0xFF727374),
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
