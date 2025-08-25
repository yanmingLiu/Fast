import 'package:dotted_border/dotted_border.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:fast_ai/component/app_dialog.dart';
import 'package:fast_ai/component/f_button.dart';
import 'package:fast_ai/component/f_empty.dart';
import 'package:fast_ai/component/f_icon.dart';
import 'package:fast_ai/data/mask_data.dart';
import 'package:fast_ai/gen/assets.gen.dart';
import 'package:fast_ai/generated/locales.g.dart';
import 'package:fast_ai/pages/chat/msg_ctr.dart';
import 'package:fast_ai/pages/router/routers.dart';
import 'package:fast_ai/services/api.dart';
import 'package:fast_ai/values/app_values.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class MaskPage extends StatefulWidget {
  const MaskPage({super.key});

  @override
  State<MaskPage> createState() => _MaskPageState();
}

class _MaskPageState extends State<MaskPage> {
  final EasyRefreshController _controller = EasyRefreshController(
    controlFinishRefresh: true,
    controlFinishLoad: true,
  );

  final List<MaskData> _maskList = [];
  bool _hasMore = true;
  int _currentPage = 1;
  final int _pageSize = 10;
  EmptyType? _emptyType;
  bool _isLoading = false;

  MaskData? _selectedMask;

  final msgCtr = Get.find<MsgCtr>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(milliseconds: 300)).then((_) {
        _controller.callRefresh();
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 下拉刷新
  Future<void> _onRefresh() async {
    _currentPage = 1;
    await _fetchData();
    _controller.finishRefresh();
    _controller.resetFooter();
  }

  /// 上拉加载更多
  Future<void> _onLoad() async {
    _currentPage += 1;
    await _fetchData();
    _controller.finishLoad(_hasMore ? IndicatorResult.none : IndicatorResult.noMore);
  }

  /// 获取数据
  Future<void> _fetchData() async {
    if (_isLoading) {
      return;
    }
    try {
      _isLoading = true;
      final response = await Api.getMaskList(page: _currentPage, size: _pageSize);

      _hasMore = (response?.records?.length ?? 0) >= _pageSize;

      if (_currentPage == 1) {
        _maskList.clear();
      }
      _maskList.addAll(response?.records ?? []);

      if (_selectedMask == null && _maskList.isNotEmpty && msgCtr.session.profileId != null) {
        _selectedMask = _maskList.firstWhereOrNull(
          (element) => element.id == msgCtr.session.profileId,
        );
      }

      _emptyType = _maskList.isEmpty ? EmptyType.noData : null;
      setState(() {});
    } catch (e) {
      _emptyType = _maskList.isEmpty ? EmptyType.noNetwork : null;
      if (_currentPage > 1) _currentPage--;
      setState(() {});
    } finally {
      _isLoading = false;
    }
  }

  void _pushEditPage({MaskData? mask}) async {
    await Get.toNamed(Routers.maskEdit, arguments: mask);
    _onRefresh();
  }

  void _changeMask() async {
    final maskId = _selectedMask?.id;
    if (maskId == null) {
      return;
    }

    if (maskId == msgCtr.session.profileId) {
      Get.back();
      return;
    }

    void changeMaskId() async {
      final res = await msgCtr.changeMask(maskId);
      if (res) {
        Get.back();
      }
    }

    if (msgCtr.session.profileId != maskId) {
      AppDialog.alert(
        message: LocaleKeys.mask_already_loaded.tr,
        cancelText: LocaleKeys.cancel.tr,
        confirmText: LocaleKeys.confirm.tr,
        onConfirm: () async {
          AppDialog.dismiss();
          changeMaskId();
        },
      );
    } else {
      changeMaskId();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
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
        title: Text(
          LocaleKeys.select_profile_mask.tr,
          style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: EasyRefresh.builder(
              controller: _controller,
              onRefresh: _onRefresh,
              onLoad: _onLoad,
              childBuilder: (context, physics) {
                return _buildContent(physics);
              },
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 68).copyWith(
                bottom: MediaQuery.of(context).padding.bottom > 0
                    ? MediaQuery.of(context).padding.bottom
                    : 16,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF111111), Color(0xFF111111)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.1, 0.15],
                ),
              ),
              child: FButton(
                onTap: _changeMask,
                color: Color(0xFF3F8DFD),
                hasShadow: true,
                child: Center(
                  child: Text(
                    LocaleKeys.pick_it.tr,
                    style: GoogleFonts.openSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建主要内容
  Widget _buildContent(ScrollPhysics physics) {
    final bottom = MediaQuery.of(context).padding.bottom + 44;
    return SingleChildScrollView(
      physics: physics,
      padding: EdgeInsets.all(16).copyWith(bottom: bottom),
      child: Column(
        children: [
          Text(
            LocaleKeys.profile_mask_description.tr,
            style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 16),
          InkWell(
            onTap: () {
              _pushEditPage();
            },
            child: DottedBorder(
              options: RoundedRectDottedBorderOptions(
                color: Color(0x803F8DFD),
                strokeWidth: 1,
                dashPattern: [6, 6],
                radius: Radius.circular(16),
              ),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12),
                width: double.infinity,
                child: Column(
                  spacing: 4,
                  children: [
                    Assets.images.add.image(width: 24),
                    Text(
                      LocaleKeys.create.tr,
                      style: TextStyle(
                        color: Color(0xFF3F8DFD),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 22),
          if (_maskList.isEmpty && _emptyType != null)
            SizedBox(
              width: double.infinity,
              height: 400,
              child: FEmpty(
                type: _emptyType!,
                paddingTop: 20,
                physics: NeverScrollableScrollPhysics(),
                onReload: _emptyType == EmptyType.noNetwork
                    ? () => _controller.callRefresh()
                    : null,
              ),
            ),
          if (_maskList.isNotEmpty) _buildGridItems(),
        ],
      ),
    );
  }

  /// 构建网格项目列表
  Widget _buildGridItems() {
    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (_, index) {
        return _buildItem(_maskList[index]);
      },
      separatorBuilder: (_, _) => SizedBox(height: 16),
      itemCount: _maskList.length,
    );
  }

  /// 构建Mask项目
  Widget _buildItem(MaskData mask) {
    final isSelected = _selectedMask?.id == mask.id;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMask = mask;
        });
      },
      child: Row(
        spacing: 8,
        children: [
          GestureDetector(
            onTap: () => _pushEditPage(mask: mask),
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Assets.images.editm.image(width: 24),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  margin: EdgeInsets.only(top: 12),
                  width: double.infinity,
                  constraints: BoxConstraints(minHeight: 64),
                  decoration: BoxDecoration(
                    color: Color(0x333F8DFD),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? Color(0xFF3F8DFD) : Colors.transparent,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mask.description ?? '',
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.start,
                        maxLines: 2,
                        style: GoogleFonts.openSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    SizedBox(width: 12),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Color(0xFF3F8DFD),
                        border: Border.all(color: Color(0x33FFFFFF), width: 1),
                      ),
                      child: Row(
                        spacing: 4,
                        children: [
                          Gender.fromValue(mask.gender).icon,
                          Text(
                            mask.profileName ?? '',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
