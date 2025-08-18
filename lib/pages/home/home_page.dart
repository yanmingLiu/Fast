import 'package:fast_ai/component/f_button.dart';
import 'package:fast_ai/component/f_icon.dart';
import 'package:fast_ai/component/f_keep_alive.dart';
import 'package:fast_ai/component/f_loading.dart';
import 'package:fast_ai/gen/assets.gen.dart';
import 'package:fast_ai/pages/home/home_call_ctr.dart';
import 'package:fast_ai/pages/home/home_ctr.dart';
import 'package:fast_ai/pages/home/home_list_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final ctr = Get.put(HomeCtr());

  late PageController _pageController;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    Get.put(HomeCallCtr());

    _pageController = PageController();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleTabSelection(int index) async {
    // 避免重复触发逻辑
    if (ctr.categroy.value.index == index) return;

    ctr.categroy.value = ctr.categroyList[index];
    // 滚动到指定 Tab
    await _scrollToSelectedTab(index);
  }

  Future<void> _scrollToSelectedTab(int index) async {
    final count = ctr.categroyList.isNotEmpty ? ctr.categroyList.length : 1;
    final tabWidth = (MediaQuery.of(context).size.width - 32 - 44 - 12) / count;
    final targetOffset = index * tabWidth - (MediaQuery.of(context).size.width - tabWidth) / 2;

    // 计算目标偏移量
    final scrollOffset = targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent);

    // 滚动到目标偏移量
    return _scrollController.animateTo(
      scrollOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(top: 0, left: 0, right: 0, child: Assets.images.pageBg.image()),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: _buildAppBar(),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                SizedBox(height: 16),
                _buildCategory(),
                Expanded(
                  child: Obx(() {
                    final list = ctr.categroyList;

                    List<Widget> children = list.map((element) {
                      return KeepAliveWrapper(child: HomeListView(cate: element));
                    }).toList();

                    return PageView(
                      controller: _pageController,
                      onPageChanged: _handleTabSelection,
                      physics: BouncingScrollPhysics(),
                      children: children,
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategory() {
    return Row(
      spacing: 12,
      children: [
        FButton(
          onTap: ctr.onTapFilter,
          width: 44,
          height: 44,
          borderRadius: BorderRadius.all(Radius.circular(22)),
          child: Center(child: FIcon(assetName: Assets.svg.filter)),
        ),
        Expanded(
          child: Container(
            height: 44,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Color(0x1AFFFFFF),
              border: BoxBorder.all(color: Color(0x33FFFFFF), width: 1),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Obx(() {
              final cate = ctr.categroy.value;
              final list = ctr.categroyList;
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: list.length,
                separatorBuilder: (context, index) => SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final data = list[index];
                  return _buildTabItem(
                    title: data.title,
                    isActive: cate == data,
                    onTap: () => ctr.onTapCate(data),
                  );
                },
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildTabItem({required String title, required bool isActive, void Function()? onTap}) {
    return FButton(
      borderRadius: BorderRadius.circular(16),
      color: isActive ? Color(0xFF3F8DFD) : Colors.transparent,
      onTap: onTap,
      padding: EdgeInsets.symmetric(horizontal: 8),
      constraints: BoxConstraints(minWidth: 50),
      child: Center(
        child: Text(
          title,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      leadingWidth: 200,
      leading: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          spacing: 8,
          children: [
            FButton(
              onTap: () {
                FLoading.showLoading();
                Future.delayed(Duration(seconds: 2)).then((v) => FLoading.dismiss());
              },
              width: 44,
              height: 44,
              borderRadius: BorderRadius.all(Radius.circular(22)),
              child: Center(child: Assets.images.member.image(width: 24)),
            ),
            FButton(
              height: 44,
              borderRadius: BorderRadius.circular(22),
              constraints: BoxConstraints(minWidth: 44),
              padding: EdgeInsets.symmetric(horizontal: 8),
              onTap: () {},
              child: Center(
                child: Row(
                  spacing: 4,
                  children: [
                    Assets.images.gems.image(width: 24),
                    Text(
                      '100',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Spacer(),
          ],
        ),
      ),
      actions: [
        FButton(
          onTap: () {},
          width: 44,
          height: 44,
          borderRadius: BorderRadius.all(Radius.circular(22)),
          child: Center(child: FIcon(assetName: Assets.svg.search)),
        ),
        SizedBox(width: 16),
      ],
    );
  }
}
