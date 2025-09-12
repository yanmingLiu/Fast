import 'package:fast_ai/component/f_button.dart';
import 'package:fast_ai/component/linked_tab_page_controller.dart';
import 'package:fast_ai/gen/assets.gen.dart';
import 'package:fast_ai/generated/locales.g.dart';
import 'package:fast_ai/pages/chat/chat_ctr.dart';
import 'package:fast_ai/pages/chat/chat_list_view.dart';
import 'package:fast_ai/pages/chat/liked_ctr.dart';
import 'package:fast_ai/pages/chat/liked_list_view.dart';
import 'package:fast_ai/services/app_service.dart';
import 'package:fast_ai/values/app_colors.dart'; // 统一颜色管理
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
  late LinkedTabPageController _linkedController;

  @override
  void initState() {
    super.initState();

    _linkedController = LinkedTabPageController(
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
          Positioned(top: 0, left: 0, right: 0, child: Assets.images.pageBg.image()),
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
                      KeepAliveWrapper(child: ChatListView(controller: chatCtr)),
                      KeepAliveWrapper(child: LikedListView(controller: likedCtr)),
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
          color: AppColors.white10,
          border: BoxBorder.all(color: AppColors.white20, width: 1),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          spacing: 12,
          children: [
            Expanded(child: _buildItem(titles[0], 0)),
            Expanded(child: _buildItem(titles[1], 1)),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(String title, int index) {
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
    required String title,
    required bool isActive,
    void Function()? onTap,
  }) {
    return FButton(
      key: key,
      borderRadius: BorderRadius.circular(16),
      color: isActive ? AppColors.primary : Colors.transparent,
      highlightColor: AppColors.primaryLight,
      onTap: onTap,
      padding: EdgeInsets.symmetric(horizontal: 8),
      constraints: BoxConstraints(minWidth: 50),
      child: Center(
        child: Text(
          title,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
