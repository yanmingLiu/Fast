import 'package:fast_ai/component/f_button.dart';
import 'package:fast_ai/component/f_icon.dart';
import 'package:fast_ai/component/f_image.dart';
import 'package:fast_ai/data/clothing_data.dart';
import 'package:fast_ai/data/toys_data.dart';
import 'package:fast_ai/gen/assets.gen.dart';
import 'package:fast_ai/generated/locales.g.dart';
import 'package:fast_ai/pages/chat/msg_ctr.dart';
import 'package:fast_ai/services/app_cache.dart';
import 'package:fast_ai/services/app_log_event.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class GiftPage extends StatefulWidget {
  const GiftPage({super.key});

  @override
  State<GiftPage> createState() => _GiftPageState();
}

enum MsgGiftViewCategroy { clothing, toys }

class _GiftPageState extends State<GiftPage> {
  MsgGiftViewCategroy? selectedCate;

  MsgCtr ctr = Get.find<MsgCtr>();

  List<ToysData>? toys;
  ToysData? chooseToys;

  List<ClothingData>? clothings;
  ClothingData? chooseClothing;

  bool showClothing = false;

  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();

    setup();
  }

  void setup() async {
    await ctr.loadToysAndClotheConfigs();

    if (AppCache().isBig) {
      selectedCate = MsgGiftViewCategroy.clothing;
    } else {
      selectedCate = MsgGiftViewCategroy.toys;
    }

    toys = ctr.toysConfigs;
    chooseToys = toys?.firstOrNull;

    var clotheConfigs = ctr.clotheConfigs;
    List<ChangeClothe> roleClothings = ctr.role.changeClothes ?? [];

    clothings = [
      for (var e in clotheConfigs)
        if (roleClothings.any((r) => e.togsType == r.clothingType)) e,
    ];

    chooseClothing = clothings?.firstOrNull;

    showClothing = ctr.role.changeClothing == true && (clothings?.isNotEmpty == true);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: kToolbarHeight + 16),
      decoration: const BoxDecoration(
        color: Color(0xFF333333),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: showClothing
                  ? [
                      _buildItem(title: LocaleKeys.clothing.tr, cate: MsgGiftViewCategroy.clothing),
                      const SizedBox(width: 32),
                      _buildItem(title: LocaleKeys.toys.tr, cate: MsgGiftViewCategroy.toys),
                      const Spacer(),
                      _buildSend(),
                    ]
                  : [
                      _buildItem(title: LocaleKeys.toys.tr, cate: MsgGiftViewCategroy.toys),
                      const Spacer(),
                      _buildSend(),
                    ],
            ),
          ),
          Expanded(
            child: SafeArea(
              top: false,
              child: showClothing
                  ? PageView(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          selectedCate = index == 0
                              ? MsgGiftViewCategroy.clothing
                              : MsgGiftViewCategroy.toys;
                        });
                      },
                      children: [_buildClothingList(), _buildToysList()],
                    )
                  : _buildToysList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClothingList() {
    var list = clothings;

    if (list == null || list.isEmpty) {
      return const SizedBox();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            LocaleKeys.send_a_gift_and_get_a_picture.tr,
            style: GoogleFonts.openSans(
              color: Color(0xFFF04A4C),
              fontSize: 10,
              fontWeight: FontWeight.w400,
            ),
          ),
          GridView.builder(
            padding: const EdgeInsets.symmetric(vertical: 16),
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 9,
              crossAxisSpacing: 9,
              childAspectRatio: 167.0 / 270.0,
            ),
            itemBuilder: (BuildContext context, int index) {
              var item = list[index];
              return _buildListItem(
                isSelected: chooseClothing?.id == item.id,
                imgUrl: item.img,
                name: item.togsName,
                price: item.itemPrice,
                onTap: () {
                  chooseClothing = item;
                  setState(() {});
                },
              );
            },
            itemCount: list.length,
          ),
        ],
      ),
    );
  }

  Widget _buildToysList() {
    var list = toys;

    if (list == null || list.isEmpty) {
      return const SizedBox();
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 9,
        crossAxisSpacing: 9,
        childAspectRatio: 167.0 / 270.0,
      ),
      itemBuilder: (BuildContext context, int index) {
        var item = list[index];
        return _buildListItem(
          isSelected: chooseToys?.id == item.id,
          imgUrl: item.img,
          name: item.tipName,
          price: item.itemPrice,
          onTap: () {
            chooseToys = item;
            setState(() {});
          },
        );
      },
      itemCount: list.length,
    );
  }

  Widget _buildListItem({
    required bool isSelected,
    required String? imgUrl,
    required String? name,
    required int? price,
    required void Function() onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: FImage(url: imgUrl, borderRadius: BorderRadius.circular(16)),
                  ),
                  if (isSelected)
                    Positioned.fill(
                      child: DiagonalClippedContainer(
                        clipSize: 50,
                        clipColor: Colors.blue,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Color(0xFF3F8DFD), width: 2),
                          ),
                        ),
                      ),
                    ),
                  if (isSelected)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: FIcon(assetName: Assets.svg.choose, width: 16),
                    ),

                  Positioned(
                    bottom: 10,
                    left: 10,
                    right: 10,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Color(0x801C1C1C),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Assets.images.gems.image(width: 20),
                              const SizedBox(width: 2),
                              Text(
                                '$price',
                                style: GoogleFonts.montserrat(
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
          const SizedBox(height: 2),
          Text(
            name ?? '',
            style: GoogleFonts.openSans(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSend() {
    return FButton(
      height: 26,
      width: 80,
      color: Color(0xFF3F8DFD),
      child: Center(
        child: Text(
          LocaleKeys.send.tr,
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
      onTap: () {
        logEvent('c_gift');

        if (showClothing) {
          switch (selectedCate) {
            case MsgGiftViewCategroy.clothing:
              if (chooseClothing != null) {
                ctr.sendChothes(chooseClothing!);
              }
              break;

            default:
              if (chooseToys != null) {
                ctr.sendToy(chooseToys!);
              }
          }
        } else {
          if (chooseToys != null) {
            ctr.sendToy(chooseToys!);
          }
        }
      },
    );
  }

  Widget _buildItem({required String title, required MsgGiftViewCategroy cate}) {
    final isSelected = cate == selectedCate;
    final index = MsgGiftViewCategroy.values.indexOf(cate);
    return InkWell(
      onTap: () {
        selectedCate = cate;
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        setState(() {});
      },
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white,
                  fontSize: isSelected ? 16 : 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DiagonalClippedContainer extends StatelessWidget {
  final Widget child;
  final double clipSize; // 裁切区域的大小（正方形边长）
  final Color clipColor; // 左上方裁切区域的颜色

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
        // 左上角蓝色三角形区域（在裁切区域上方）
        Positioned(
          top: 0,
          left: 0,
          child: CustomPaint(
            size: Size(clipSize, clipSize),
            painter: _BlueTrianglePainter(color: clipColor),
          ),
        ),
      ],
    );
  }
}

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

class _BlueTrianglePainter extends CustomPainter {
  final Color color;

  _BlueTrianglePainter({required this.color});

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
    return oldDelegate is _BlueTrianglePainter && oldDelegate.color != color;
  }
}
