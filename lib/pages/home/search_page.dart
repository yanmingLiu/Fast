import 'package:fast_ai/component/f_button.dart';
import 'package:fast_ai/component/f_empty.dart';
import 'package:fast_ai/component/f_icon.dart';
import 'package:fast_ai/data/role_data.dart';
import 'package:fast_ai/gen/assets.gen.dart';
import 'package:fast_ai/generated/locales.g.dart';
import 'package:fast_ai/pages/home/home_ctr.dart';
import 'package:fast_ai/pages/home/home_item.dart';
import 'package:fast_ai/pages/home/search_ctr.dart';
import 'package:fast_ai/values/app_text_style.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final focusNode = FocusNode();
  final textController = TextEditingController();
  final scrollController = ScrollController();

  final ctr = Get.put<SearchCtr>(SearchCtr());

  @override
  void initState() {
    super.initState();
    focusNode.requestFocus();

    // 添加滚动监听器，滚动时关闭键盘
    scrollController.addListener(() {
      if (scrollController.position.isScrollingNotifier.value) {
        focusNode.unfocus();
      }
    });
  }

  @override
  void dispose() {
    focusNode.unfocus();
    focusNode.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        title: Container(
          height: 48,
          width: double.infinity,
          margin: const EdgeInsetsDirectional.only(end: 16),
          padding: EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Color(0x1AFFFFFF),
            borderRadius: BorderRadius.circular(24.0),
          ),
          child: Row(
            children: [
              Expanded(
                child: Center(
                  child: TextField(
                    onChanged: (query) {
                      // 更新 searchQuery
                      ctr.searchQuery.value = query;
                    },
                    autofocus: false,
                    textInputAction: TextInputAction.done,
                    onEditingComplete: () {},
                    minLines: 1,
                    maxLength: 20,
                    style: AppTextStyle.openSans(
                      height: 1,
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                    controller: textController,
                    enableInteractiveSelection: true, // 确保文本选择功能启用
                    dragStartBehavior: DragStartBehavior.down, // 优化拖拽行为
                    decoration: InputDecoration(
                      hintText: LocaleKeys.search_sirens.tr,
                      counterText: '', // 去掉字数显示
                      hintStyle: AppTextStyle.openSans(color: Color(0x33FFFFFF)),
                      fillColor: Colors.transparent,
                      border: InputBorder.none,
                      filled: true,
                      isDense: true,
                    ),
                    focusNode: focusNode,
                  ),
                ),
              ),
              FButton(
                width: 44,
                height: 44,
                color: Colors.transparent,
                onTap: () {
                  ctr.searchQuery.value = textController.text;
                },
                child: Center(
                  child: Obx(
                    () => FIcon(
                      assetName: Assets.svg.search,
                      width: 24,
                      color: ctr.searchQuery.value.isEmpty ? Colors.white : const Color(0xFF3F8DFD),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Obx(() {
        final list = ctr.list;
        final type = ctr.type.value;

        if (type != null) {
          return GestureDetector(
            child: FEmpty(type: type),
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
            },
          );
        }
        return Padding(
          padding: const EdgeInsets.only(top: 16),
          child: MasonryGridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            itemCount: list.length,
            controller: scrollController,
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              final role = list[index];
              return SizedBox(
                height: index.isOdd ? 300 : 250,
                child: HomeItem(
                  role: role,
                  onCollect: (Role role) {
                    ctr.onCollect(index, role);
                  },
                  cate: HomeListCategroy.all,
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
