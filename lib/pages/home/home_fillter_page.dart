import 'package:fast_ai/component/f_button.dart';
import 'package:fast_ai/component/f_icon.dart';
import 'package:fast_ai/component/f_loading.dart';
import 'package:fast_ai/data/role_tags.dart';
import 'package:fast_ai/pages/home/home_ctr.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../gen/assets.gen.dart';
import '../../generated/locales.g.dart';

class HomeFiltterPage extends StatefulWidget {
  const HomeFiltterPage({super.key});

  @override
  State<HomeFiltterPage> createState() => _HomeFiltterPageState();
}

class _HomeFiltterPageState extends State<HomeFiltterPage> {
  final ctr = Get.find<HomeCtr>();

  RoleTagRes? selectedType;

  @override
  void initState() {
    super.initState();

    loadData();
  }

  void loadData() async {
    if (ctr.roleTags.isEmpty) {
      FLoading.showLoading();
      await ctr.loadTags();
      FLoading.dismiss();
    }

    selectedType = ctr.roleTags.firstOrNull;
  }

  @override
  Widget build(BuildContext context) {
    final tags = selectedType?.tags;

    bool containsAll = false;
    if (tags != null && tags.isNotEmpty) {
      containsAll = ctr.selectTags.containsAll(tags);
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        titleSpacing: 0.0,
        leadingWidth: 100,
        actionsPadding: const EdgeInsets.symmetric(horizontal: 8),
        leading: Row(
          children: [
            SizedBox(width: 16),
            FButton(
              width: 44,
              height: 44,
              borderRadius: BorderRadius.circular(22),
              onTap: () {
                Get.back();
              },
              child: Center(child: FIcon(assetName: Assets.svg.close)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (containsAll) {
                ctr.selectTags.removeAll(tags ?? []);
              } else {
                ctr.selectTags.addAll(tags ?? []);
              }
              setState(() {});
            },
            child: Text(
              containsAll ? LocaleKeys.unselect_all.tr : LocaleKeys.select_all.tr,
              style: GoogleFonts.openSans(
                color: Color(0xFF3F8DFD),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocaleKeys.choose_your_tags.tr,
              style: GoogleFonts.montserrat(
                fontSize: 32,
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 24),
            _buildType(),

            const SizedBox(height: 24),
            Expanded(child: _buildTags()),
            const SizedBox(height: 16),
            FButton(
              color: Color(0xFF3F8DFD),
              height: 48,
              borderRadius: BorderRadius.circular(24),
              hasShadow: true,
              onTap: () {
                Get.back();
                ctr.filterEvent.value = (
                  Set<RoleTag>.from(ctr.selectTags),
                  DateTime.now().millisecondsSinceEpoch,
                );
                ctr.filterEvent.refresh();
              },
              child: Center(
                child: Text(
                  LocaleKeys.confirm.tr,
                  style: GoogleFonts.openSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTags() {
    final tags = selectedType?.tags;
    if (tags == null || tags.isEmpty) {
      return const SizedBox();
    }

    return SingleChildScrollView(
      child: SizedBox(
        width: double.infinity,
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          direction: Axis.horizontal, // 显示为水平布局
          alignment: WrapAlignment.start,
          children: tags.map((e) {
            var isSelected = ctr.selectTags.contains(e);

            return InkWell(
              splashColor: Colors.transparent, // 去除水波纹
              highlightColor: Colors.transparent, // 去除点击高亮
              onTap: () {
                if (ctr.selectTags.contains(e)) {
                  ctr.selectTags.remove(e);
                } else {
                  ctr.selectTags.add(e);
                }
                setState(() {});
              },
              child: Row(mainAxisSize: MainAxisSize.min, children: [_buildItem(isSelected, e)]),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildItem(bool isSelected, RoleTag e) {
    return Container(
      height: 32,
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        border: Border.all(color: isSelected ? Color(0xFF3F8DFD) : Color(0xFFA8A8A8), width: 1.0),
      ),
      child: Center(
        child: Text(
          e.name ?? '',
          style: GoogleFonts.openSans(
            color: isSelected ? Color(0xFF3F8DFD) : Color(0xFFA8A8A8),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildType() {
    var tags = ctr.roleTags;
    List<RoleTagRes> result = (tags.length > 2) ? tags.take(2).toList() : tags;

    RoleTagRes type1 = result[0];

    RoleTagRes? type2;
    if (result.length > 1) {
      type2 = result[1];
    }

    return Container(
      height: 64,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Color(0x1AFFFFFF),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Color(0x33FFFFFF), width: 1.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        spacing: 20,
        children: [
          Expanded(
            child: InkWell(
              splashColor: Colors.transparent, // 去除水波纹
              highlightColor: Colors.transparent, // 去除点击高亮
              onTap: () {
                selectedType = type1;
                setState(() {});
              },
              child: _buildTypeItem1(type1),
            ),
          ),
          if (type2 != null)
            Expanded(
              child: InkWell(
                splashColor: Colors.transparent, // 去除水波纹
                highlightColor: Colors.transparent, // 去除点击高亮
                onTap: () {
                  selectedType = type2;
                  setState(() {});
                },
                child: _buildTypeItem1(type2),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTypeItem1(RoleTagRes type) {
    bool isSelected = type == selectedType;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        color: isSelected ? Color(0xFF3F8DFD) : Colors.transparent,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            type.labelType ?? '',
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.openSans(
              color: isSelected ? Colors.white : Color(0xFF727374),
              fontSize: isSelected ? 16 : 14,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
