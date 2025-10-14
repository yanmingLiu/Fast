import 'dart:ui';

import 'package:fast_ai/component/f_image.dart';
import 'package:fast_ai/data/role_data.dart';
import 'package:fast_ai/gen/assets.gen.dart';
import 'package:fast_ai/pages/chat/msg_ctr.dart';
import 'package:fast_ai/services/app_cache.dart';
import 'package:fast_ai/values/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PhotoAlbum extends StatefulWidget {
  const PhotoAlbum({super.key});

  @override
  State<PhotoAlbum> createState() => _PhotoAlbumState();
}

class _PhotoAlbumState extends State<PhotoAlbum> {
  final imageHeight = 64.0;
  bool _isExpanded = true;

  final ctr = Get.find<MsgCtr>();

  RxList<RoleImage> images = <RoleImage>[].obs;

  @override
  void initState() {
    super.initState();

    images.value = ctr.role.images ?? [];

    ever(ctr.roleImagesChaned, (_) {
      images.value = ctr.role.images ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Obx(() {
          return _buildImages();
        }),
      ],
    );
  }

  Widget _buildImages() {
    final imageCount = images.length;

    if (!AppCache().isBig || imageCount == 0 || images.isEmpty) {
      return Container(height: 1, color: const Color(0x801C1C1C));
    }

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300), // 动画持续时间
          curve: Curves.easeInOut, // 动画曲线
          margin: const EdgeInsets.only(bottom: 12),
          height: _isExpanded ? 64 : 0, // 根据状态动态调整高度
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemBuilder: (_, idx) {
              final image = images[idx];
              final unlocked = image.unlocked ?? false;
              return PhotoAlbumItem(
                imageHeight: imageHeight,
                image: image,
                avatar: ctr.role.avatar,
                unlocked: unlocked,
                onTap: () {
                  if (unlocked) {
                    ctr.onTapImage(image);
                  } else {
                    ctr.onTapUnlockImage(image);
                  }
                },
              );
            },
            separatorBuilder: (context, index) {
              return const SizedBox(width: 12);
            },
            itemCount: imageCount,
          ),
        ),
        Container(height: 1, color: const Color(0x4D333333)),
        SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Container(
            width: 40,
            height: 16,
            decoration: BoxDecoration(
              color: Color(0x801C1C1C),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(
                color: Colors.white,
                _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class PhotoAlbumItem extends StatelessWidget {
  const PhotoAlbumItem({
    super.key,
    required this.imageHeight,
    required this.image,
    required this.unlocked,
    this.onTap,
    this.avatar,
  });

  final double imageHeight;
  final RoleImage image;
  final bool unlocked;
  final void Function()? onTap;
  final String? avatar;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: imageHeight,
          width: imageHeight,
          color: const Color(0xff1C1C1C),
          child: Stack(
            children: [
              FImage(
                url: !unlocked ? avatar : image.imageUrl,
                width: imageHeight,
                height: imageHeight,
                cacheWidth: 800,
                cacheHeight: 800,
                // fit: BoxFit.fill,
              ),
              if (!unlocked)
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                  child: Container(
                    color: const Color(0x901C1C1C),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 20,
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Assets.images.gems.image(width: 16, height: 16),
                                Text(
                                  '${image.gems ?? 0}',
                                  style: AppTextStyle.openSans(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
