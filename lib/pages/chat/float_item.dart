import 'package:fast_ai/component/f_image.dart';
import 'package:fast_ai/data/role_data.dart';
import 'package:fast_ai/gen/assets.gen.dart';
import 'package:fast_ai/services/app_log_event.dart';
import 'package:fast_ai/pages/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FloatItem extends StatelessWidget {
  const FloatItem({super.key, required this.role, required this.sessionId});

  final Role role;
  final int sessionId;

  @override
  Widget build(BuildContext context) {
    if (role.videoChat == true) return _buildVideoItem();
    return const SizedBox();
  }

  void _onTapPhoneVideo() {
    logEvent('c_videocall');
    AppRouter.pushPhoneGuide(role: role);
  }

  Widget _buildVideoItem() {
    final guide = role.characterVideoChat?.firstWhereOrNull((e) => e.tag == 'guide');
    final url = guide?.gifUrl ?? role.avatar;

    return GestureDetector(
      onTap: _onTapPhoneVideo,
      child: Stack(
        alignment: AlignmentDirectional.bottomEnd,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: FImage(
              url: url,
              width: 64,
              height: 64,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
          Assets.images.videoCall.image(width: 20, height: 20),
        ],
      ),
    );
  }
}
