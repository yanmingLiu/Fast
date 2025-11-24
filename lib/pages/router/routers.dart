import 'package:fast_ai/component/f_image_preview.dart';
import 'package:fast_ai/component/video_preview.dart';
import 'package:fast_ai/pages/chat/mask_edit_page.dart';
import 'package:fast_ai/pages/chat/mask_page.dart';
import 'package:fast_ai/pages/chat/msg_page.dart';
import 'package:fast_ai/pages/chat/phone_guide_page.dart';
import 'package:fast_ai/pages/chat/phone_page.dart';
import 'package:fast_ai/pages/chat/role_center_page.dart';
import 'package:fast_ai/pages/home/home_fillter_page.dart';
import 'package:fast_ai/pages/home/search_page.dart';
import 'package:fast_ai/pages/mian/launch_page.dart';
import 'package:fast_ai/pages/mian/main_page.dart';
import 'package:fast_ai/pages/vip/gems_page.dart';
import 'package:fast_ai/pages/vip/vip_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';

/// 应用路由定义类
class Routers {
  // 私有构造函数，防止实例化
  Routers._();

  /// 应用路由路径定义
  static const String main = '/';
  static const String splash = '/zx001';
  static const String phone = '/zx002';
  static const String phoneGuide = '/zx003';
  static const String vip = '/zx004';
  static const String imagePreview = '/zx005';
  static const String videoPreview = '/zx006';
  static const String search = '/zx007';
  static const String gems = '/zx008';
  static const String msg = '/zx009';
  static const String profile = '/zx010';
  static const String undr = '/zx011';
  static const String undrSku = '/zx012';
  static const String mask = '/zx013';
  static const String maskEdit = '/zx014';
  static const String homeFilter = '/zx015';

  /// 应用路由页面定义列表
  static final List<GetPage> pages = [
    // 主要路由
    GetPage(name: main, page: () => const MainPage()),
    GetPage(name: splash, page: () => const LaunchPage()),
    GetPage(name: gems, page: () => const GemsPage()),
    GetPage(name: search, page: () => const SearchPage()),
    GetPage(name: msg, page: () => MsgPage()),
    GetPage(name: profile, page: () => const RoleCenterPage()),
    GetPage(name: mask, page: () => MaskPage()),
    GetPage(name: maskEdit, page: () => MaskEditPage()),
    GetPage(name: phone, page: () => const PhonePage()),
    GetPage(name: phoneGuide, page: () => const PhoneGuidePage()),

    // 特殊过渡效果路由
    GetPage(
      name: imagePreview,
      page: () => const FImagePreview(),
      transition: Transition.zoom,
      fullscreenDialog: true,
    ),
    GetPage(
        name: videoPreview,
        page: () => const VideoPreview(),
        fullscreenDialog: true),
    GetPage(
        name: homeFilter,
        page: () => const HomeFiltterPage(),
        transition: Transition.downToUp),

    GetPage(
      name: vip,
      page: () => PopScope(
        canPop: false, // 禁止返回键
        child: const VipPage(),
      ),
      popGesture: false, // 禁用 iOS 侧滑返回
    ),

    // 已注释路由（暂未启用）
    // GetPage(name: genPage, page: () => const GenPage()),
    // GetPage(name: undr, page: () => UndrPage(), fullscreenDialog: true, transition: Transition.downToUp),
    // GetPage(name: undrSku, page: () => UndrSkuList(), fullscreenDialog: true, transition: Transition.downToUp),
  ];
}
