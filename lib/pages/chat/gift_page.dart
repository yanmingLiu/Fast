import 'package:fast_ai/component/f_button.dart';
import 'package:fast_ai/component/f_icon.dart';
import 'package:fast_ai/component/f_image.dart';
import 'package:fast_ai/component/linked_tab_page_controller.dart';
import 'package:fast_ai/data/clothing_data.dart';
import 'package:fast_ai/data/toys_data.dart';
import 'package:fast_ai/gen/assets.gen.dart';
import 'package:fast_ai/generated/locales.g.dart';
import 'package:fast_ai/pages/chat/msg_ctr.dart';
import 'package:fast_ai/services/app_log_event.dart';
import 'package:fast_ai/services/app_user.dart';
import 'package:fast_ai/values/app_colors.dart'; // 统一颜色管理
import 'package:fast_ai/values/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GiftPage extends StatefulWidget {
  const GiftPage({super.key});

  @override
  State<GiftPage> createState() => _GiftPageState();
}

enum MsgGiftViewCategory { clothing, toys }

/// 礼物页面常量
class _GiftPageConstants {
  // 使用统一颜色管理
  static const Color backgroundColor = Color(0xFF333333);
  static const Color primaryBlue = AppColors.primary; // 使用AppColors
  static const Color primaryBlueLight = AppColors.primaryLight; // 使用AppColors
  static const Color borderColor = Color(0x33FFFFFF);
  static const Color backgroundLight = Color(0x1AFFFFFF);
  static const Color priceTagBackground = Color(0x801C1C1C);
  static const Color redText = Color(0xFFF04A4C);

  // 尺寸常量
  static const double borderRadius = 16.0;
  static const double tabBorderRadius = 24.0;
  static const double itemSpacing = 8.0;
  static const double gridAspectRatio = 168.0 / 247.0;
  static const double clipSize = 50.0;

  // 边距常量
  static const EdgeInsets contentPadding = EdgeInsets.symmetric(horizontal: 16.0);
  static const EdgeInsets tabPadding = EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0);
}

class _GiftPageState extends State<GiftPage> {
  /// 当前选中的分类
  MsgGiftViewCategory? _selectedCategory;

  /// 消息控制器
  final MsgCtr _ctr = Get.find<MsgCtr>();

  /// 玩具数据列表
  List<ToysData>? _toys;

  /// 当前选中的玩具
  ToysData? _selectedToy;

  /// 服装数据列表
  List<ClothingData>? _clothings;

  /// 当前选中的服装
  ClothingData? _selectedClothing;

  /// 是否显示服装选项
  bool _showClothing = false;

  /// 分类标题
  final List<String> _categoryTitles = [LocaleKeys.clothing.tr, LocaleKeys.toys.tr];

  /// 标签页控制器
  late LinkedTabPageController _linkedController;

  @override
  void initState() {
    super.initState();
    _linkedController = LinkedTabPageController(items: _categoryTitles);
    _loadData();
  }

  /// 加载礼物数据
  Future<void> _loadData() async {
    await AppUser().loadToysAndClotheConfigs();

    // 加载玩具数据
    _toys = AppUser().toysConfigs;
    _selectedToy = _toys?.firstOrNull;

    // 加载服装数据
    final clotheConfigs = AppUser().clotheConfigs;
    final List<ChangeClothe> roleClothings = _ctr.role.changeClothes ?? [];

    // 过滤出角色可用的服装
    _clothings = [
      for (final clothing in clotheConfigs)
        if (roleClothings.any((role) => clothing.togsType == role.clothingType)) clothing,
    ];

    _selectedClothing = _clothings?.firstOrNull;

    // 判断是否显示服装选项
    _showClothing = _ctr.role.changeClothing == true && (_clothings?.isNotEmpty ?? false);

    // 根据缓存决定默认选中的分类
    _selectedCategory = _showClothing ? MsgGiftViewCategory.clothing : MsgGiftViewCategory.toys;

    // 更新UI
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: kToolbarHeight + 16),
      decoration: const BoxDecoration(
        color: _GiftPageConstants.backgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(_GiftPageConstants.borderRadius),
          topRight: Radius.circular(_GiftPageConstants.borderRadius),
        ),
      ),
      child: Column(
        children: [
          // 分类标签区域
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: _buildCategorySection(),
          ),

          // 内容区域
          Expanded(
            child: SafeArea(
              top: false,
              child: _showClothing
                  ? PageView(
                      controller: _linkedController.pageController,
                      pageSnapping: true,
                      onPageChanged: _handlePageChanged,
                      children: [_buildClothingList(), _buildToysList()],
                    )
                  : _buildToysList(),
            ),
          ),
        ],
      ),
    );
  }

  /// 处理页面切换事件
  void _handlePageChanged(int index) {
    _linkedController.handlePageChanged(index);
    setState(() {
      _selectedCategory = index == 0 ? MsgGiftViewCategory.clothing : MsgGiftViewCategory.toys;
    });
  }

  /// 构建分类选择区域
  Widget _buildCategorySection() {
    if (_showClothing) {
      return Container(
        height: 48,
        padding: _GiftPageConstants.tabPadding,
        decoration: BoxDecoration(
          color: _GiftPageConstants.backgroundLight,
          border: BoxBorder.all(color: _GiftPageConstants.borderColor, width: 1),
          borderRadius: BorderRadius.circular(_GiftPageConstants.tabBorderRadius),
        ),
        child: Row(
          children: [
            Expanded(child: _buildTabItem(_categoryTitles[0], 0)),
            const SizedBox(width: 12),
            Expanded(child: _buildTabItem(_categoryTitles[1], 1)),
          ],
        ),
      );
    }

    // 只显示玩具标题
    return Row(
      children: [
        Text(
          LocaleKeys.toys.tr,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ],
    );
  }

  /// 构建标签项
  Widget _buildTabItem(String title, int index) {
    return AnimatedBuilder(
      animation: _linkedController,
      builder: (_, __) {
        final isActive = _linkedController.index == index;
        return _buildTabButton(
          key: _linkedController.getTabKey(index),
          title: title,
          isActive: isActive,
          onTap: () => _linkedController.select(index),
        );
      },
    );
  }

  /// 构建标签按钮
  Widget _buildTabButton({
    Key? key,
    required String title,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return FButton(
      key: key,
      borderRadius: BorderRadius.circular(_GiftPageConstants.borderRadius),
      color: isActive ? _GiftPageConstants.primaryBlue : Colors.transparent,
      highlightColor: _GiftPageConstants.primaryBlueLight,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      constraints: const BoxConstraints(minWidth: 50),
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

  /// 构建服装列表
  Widget _buildClothingList() {
    final list = _clothings;

    if (list == null || list.isEmpty) {
      return const SizedBox();
    }

    return Padding(
      padding: _GiftPageConstants.contentPadding,
      child: Column(
        children: [
          // 顶部提示和发送按钮
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Text(
                  LocaleKeys.send_a_gift_and_get_a_picture.tr,
                  style: AppTextStyle.openSans(
                    color: _GiftPageConstants.redText,
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const Spacer(),
                _buildSendButton(),
              ],
            ),
          ),

          // 服装网格列表
          Expanded(
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: _GiftPageConstants.itemSpacing,
                crossAxisSpacing: _GiftPageConstants.itemSpacing,
                childAspectRatio: _GiftPageConstants.gridAspectRatio,
              ),
              itemBuilder: (BuildContext context, int index) {
                final item = list[index];
                return _buildListItem(
                  isSelected: _selectedClothing?.id == item.id,
                  imgUrl: item.img,
                  name: item.togsName,
                  price: item.itemPrice,
                  onTap: () {
                    setState(() {
                      _selectedClothing = item;
                    });
                  },
                );
              },
              itemCount: list.length,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建玩具列表
  Widget _buildToysList() {
    final list = _toys;

    if (list == null || list.isEmpty) {
      return const SizedBox();
    }

    return Padding(
      padding: _GiftPageConstants.contentPadding,
      child: Column(
        children: [
          // 顶部发送按钮
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(children: [const Spacer(), _buildSendButton()]),
          ),

          // 玩具网格列表
          Expanded(
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: _GiftPageConstants.itemSpacing,
                crossAxisSpacing: _GiftPageConstants.itemSpacing,
                childAspectRatio: _GiftPageConstants.gridAspectRatio,
              ),
              itemBuilder: (BuildContext context, int index) {
                final item = list[index];
                return _buildListItem(
                  isSelected: _selectedToy?.id == item.id,
                  imgUrl: item.img,
                  name: item.tipName,
                  price: item.itemPrice,
                  onTap: () {
                    setState(() {
                      _selectedToy = item;
                    });
                  },
                );
              },
              itemCount: list.length,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建礼物列表项
  Widget _buildListItem({
    required bool isSelected,
    required String? imgUrl,
    required String? name,
    required int? price,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(_GiftPageConstants.borderRadius),
      child: Column(
        children: [
          // 图片区域
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(_GiftPageConstants.borderRadius),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // 礼物图片
                  Positioned.fill(
                    child: FImage(
                      url: imgUrl,
                      borderRadius: BorderRadius.circular(_GiftPageConstants.borderRadius),
                    ),
                  ),

                  // 选中状态边框
                  if (isSelected)
                    Positioned.fill(
                      child: DiagonalClippedContainer(
                        clipSize: _GiftPageConstants.clipSize,
                        clipColor: _GiftPageConstants.primaryBlue,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(_GiftPageConstants.borderRadius),
                            border: Border.all(color: _GiftPageConstants.primaryBlue, width: 2),
                          ),
                        ),
                      ),
                    ),

                  // 选中状态图标
                  if (isSelected)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: FIcon(assetName: Assets.svg.choose, width: 16),
                    ),

                  // 价格标签
                  Positioned(
                    bottom: 10,
                    left: 10,
                    right: 10,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: _GiftPageConstants.priceTagBackground,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Assets.images.gems.image(width: 20),
                              const SizedBox(width: 2),
                              Text(
                                '${price ?? 0}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 礼物名称
          const SizedBox(height: 2),
          Text(
            name ?? '',
            style: AppTextStyle.openSans(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建发送按钮
  Widget _buildSendButton() {
    return FButton(
      height: 26,
      width: 80,
      color: _GiftPageConstants.primaryBlue,
      onTap: _handleSendGift,
      child: Center(
        child: Text(
          LocaleKeys.send.tr,
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  /// 处理发送礼物逻辑
  void _handleSendGift() {
    // 记录事件
    logEvent('c_gift');

    if (_showClothing) {
      // 有服装选项时，根据当前选中的分类决定发送什么
      switch (_selectedCategory) {
        case MsgGiftViewCategory.clothing:
          if (_selectedClothing != null) {
            _ctr.sendChothes(_selectedClothing!);
          }
          break;

        case MsgGiftViewCategory.toys:
          if (_selectedToy != null) {
            _ctr.sendToy(_selectedToy!);
          }
          break;

        default:
          // 未选择分类时不执行操作
          break;
      }
    } else {
      // 只有玩具选项时直接发送玩具
      if (_selectedToy != null) {
        _ctr.sendToy(_selectedToy!);
      }
    }
  }
}

/// 带有左上角三角形裁切的容器组件
class DiagonalClippedContainer extends StatelessWidget {
  /// 子组件
  final Widget child;

  /// 裁切区域的大小（正方形边长）
  final double clipSize;

  /// 左上方裁切区域的颜色
  final Color clipColor;

  const DiagonalClippedContainer({
    super.key,
    required this.child,
    this.clipSize = 40,
    this.clipColor = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 主内容区域（被裁切）
        ClipPath(clipper: _DiagonalClipper(clipSize), child: child),

        // 左上角三角形区域
        Positioned(
          top: 0,
          left: 0,
          child: CustomPaint(
            size: Size(clipSize, clipSize),
            painter: _TrianglePainter(color: clipColor),
          ),
        ),
      ],
    );
  }
}

/// 对角线裁切器
class _DiagonalClipper extends CustomClipper<Path> {
  final double clipSize;

  _DiagonalClipper(this.clipSize);

  @override
  Path getClip(Size size) {
    final path = Path();

    // 从左上角开始，但跳过三角形区域
    path.moveTo(clipSize, 0);
    path.lineTo(0, clipSize);

    // 绘制剩余的容器边界
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return oldClipper is _DiagonalClipper && oldClipper.clipSize != clipSize;
  }
}

/// 三角形绘制器
class _TrianglePainter extends CustomPainter {
  final Color color;

  _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // 绘制左上角三角形
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is _TrianglePainter && oldDelegate.color != color;
  }
}
