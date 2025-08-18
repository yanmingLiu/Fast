import 'dart:io';

import 'package:fast_ai/component/app_dialog.dart';
import 'package:fast_ai/component/f_toast.dart';
import 'package:fast_ai/data/role.dart';
import 'package:fast_ai/generated/locales.g.dart';
import 'package:fast_ai/pages/mian/launch_page.dart';
import 'package:fast_ai/pages/mian/main_page.dart';
import 'package:fast_ai/services/api.dart';
import 'package:fast_ai/services/app_cache.dart';
import 'package:fast_ai/services/app_service.dart';
import 'package:fast_ai/services/app_user.dart';
import 'package:fast_ai/values/app_values.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:url_launcher/url_launcher.dart';

class Routers {
  Routers._();

  static const String main = '/';
  static const String splash = '/splash';
  static const String phone = '/phone';
  static const String phoneGuide = '/phoneGuide';
  static const String vip = '/vip';
  static const String imagePreview = '/imagePreview';
  static const String videoPreview = '/videoPreview';
  static const String search = '/search';
  static const String genPage = '/genPage';
  static const String gems = '/gems';
  static const String msg = '/msg';
  static const String profile = '/profile';
  static const String undr = '/undr';
  static const String undrSku = '/undrSku';
  static const String mask = '/mask';
  static const String maskEdit = '/maskEdit';

  static final List<GetPage> pages = [
    GetPage(name: main, page: () => const MainPage()),
    GetPage(name: splash, page: () => const LaunchPage()),
    // GetPage(name: phone, page: () => const PhonePage()),
    // GetPage(name: phoneGuide, page: () => const PhoneGuidePage()),
    // GetPage(name: vip, page: () => const VipPage()),
    // GetPage(
    //   name: imagePreview,
    //   page: () => const ImagePreviewPage(),
    //   transition: Transition.zoom,
    //   fullscreenDialog: true,
    // ),
    // GetPage(name: videoPreview, page: () => const VideoPreviewPage(), fullscreenDialog: true),
    // GetPage(name: search, page: () => const SearchPage()),
    // GetPage(name: genPage, page: () => const GenPage()),
    // GetPage(name: gems, page: () => const GemsPage()),
    // GetPage(name: msg, page: () => MsgPage()),
    // GetPage(name: profile, page: () => const RoleProfilePage()),
    // GetPage(
    //   name: undr,
    //   page: () => UndrPage(),
    //   fullscreenDialog: true,
    //   transition: Transition.downToUp,
    // ),
    // GetPage(
    //   name: undrSku,
    //   page: () => UndrSkuList(),
    //   fullscreenDialog: true,
    //   transition: Transition.downToUp,
    // ),
    // GetPage(name: mask, page: () => MaskPage()),
    // GetPage(name: maskEdit, page: () => MaskEditPage()),
  ];
}

class AppRouter {
  AppRouter._();

  static void pushSearch() async {
    Get.toNamed(Routers.search);
  }

  static Future<void> pushChat(String? roleId, {bool showLoading = true}) async {
    if (roleId == null) {
      SmartDialog.showToast('roleId is null');
      return;
    }

    try {
      if (showLoading) {
        SmartDialog.showLoading();
      }

      // 使用 Future.wait 来同时执行查角色和查会话
      var results = await Future.wait([
        Api.loadRoleById(roleId), // 查角色
        Api.addSession(roleId), // 查会话
      ]);

      var role = results[0];
      var session = results[1];

      // 检查角色和会话是否为 null
      if (role == null) {
        _dismissAndShowErrorToast('role is null');
        return;
      }
      if (session == null) {
        _dismissAndShowErrorToast('session is null');
        return;
      }

      SmartDialog.dismiss();
      Get.toNamed(Routers.msg, arguments: {'role': role, 'session': session});
    } catch (e) {
      SmartDialog.dismiss(); // 确保发生异常时关闭加载提示
      SmartDialog.showNotify(msg: e.toString(), notifyType: NotifyType.error);
    }
  }

  static void _dismissAndShowErrorToast(String message) {
    SmartDialog.dismiss();
    SmartDialog.showToast(message);
  }

  static void pushVip(VipFrom from) {
    Get.toNamed(Routers.vip, arguments: from);
  }

  static void pushProfile(Role role) {
    Get.toNamed(Routers.profile, arguments: role);
  }

  static void pushGem(ConsumeFrom from) {
    Get.toNamed(Routers.gems, arguments: from);
  }

  static void pushUndr(Role? role) {
    Get.toNamed(Routers.undr, arguments: role);
  }

  static Future<T?>? pushPhone<T>({
    required int sessionId,
    required Role role,
    required bool showVideo,
    CallState callState = CallState.calling,
  }) async {
    // 检查 Mic 权限 和 语音权限
    if (!await checkPermissions()) {
      showNoPermissionDialog();
      return null;
    }

    return Get.toNamed(
      Routers.phone,
      arguments: {
        'sessionId': sessionId,
        'role': role,
        'callState': callState,
        'showVideo': showVideo,
      },
    );
  }

  static Future<T?>? offPhone<T>({
    required Role role,
    required bool showVideo,
    CallState callState = CallState.calling,
  }) async {
    // 检查 Mic 权限 和 语音权限
    if (!await checkPermissions()) {
      showNoPermissionDialog();
      return null;
    }
    var seesion = await Api.addSession(role.id ?? ''); // 查会话
    final sessionId = seesion?.id;
    if (sessionId == null) {
      SmartDialog.showToast('sessionId is null');
      return null;
    }

    return Get.offNamed(
      Routers.phone,
      arguments: {
        'sessionId': sessionId,
        'role': role,
        'callState': callState,
        'showVideo': showVideo,
      },
    );
  }

  /// 检查麦克风和语音识别权限，返回是否已授予所有权限
  static Future<bool> checkPermissions() async {
    // 初始化 SpeechToText 以检查语音识别权限
    SpeechToText speechToText = SpeechToText();
    bool available = await speechToText.initialize(
      onStatus: (status) => log.d('onStatus: $status'),
      onError: (error) => log.e('onError: $error'),
    );

    log.d('语音识别是否可用: $available');

    // 如果语音识别未初始化成功，返回 false
    if (!available) {
      return false;
    }

    // 如果麦克风和语音识别权限均已授予，返回 true
    return true;
  }

  // 没有权限提示
  static Future<void> showNoPermissionDialog() async {
    AppDialog.alert(
      message: LocaleKeys.mic_permission.tr,
      onConfirm: () async {
        await openAppSettings();
      },
      cancelText: LocaleKeys.cancel.tr,
      confirmText: LocaleKeys.open_settings.tr,
    );
  }

  static Future<T?>? pushPhoneGuideFormHome<T>({required Role role}) async {
    final roleId = role.id;
    if (roleId == null) {
      SmartDialog.showToast('roleId is null');
      return null;
    }
    return null;
  }

  static Future<T?>? pushPhoneGuide<T>({required Role role}) {
    return Get.toNamed(Routers.phoneGuide, arguments: {'role': role});
  }

  static Future<T?>? pushCreate<T>({required Role role, required CreateType type}) {
    return Get.toNamed(Routers.genPage, arguments: {'role': role, 'type': type});
  }

  static void pushImagePreview(String imageUrl) {
    Get.toNamed(Routers.imagePreview, arguments: imageUrl);
  }

  static void pushVideoPreview(String url) {
    Get.toNamed(Routers.videoPreview, arguments: url);
  }

  static void pushMask() {
    Get.toNamed(Routers.mask);
  }

  static void toEmail() async {
    final version = await AppService().version();
    final device = await AppCache().phoneId();
    final uid = AppUser().user?.id;

    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: AppService.email, // 收件人
      query:
          "subject=Feedback&body=version: $version\ndevice: $device\nuid: $uid\nPlease input your problem:\n", // 设置默认主题和正文内容
    );

    launchUrl(emailUri);
  }

  static void toPrivacy() {
    launchUrl(Uri.parse(AppService.privacy));
  }

  static void toTerms() {
    launchUrl(Uri.parse(AppService.terms));
  }

  static Future<void> openAppStoreReview() async {
    if (Platform.isIOS) {
      // iOS App Store review URL
      const String appId = '6740072684'; // App Store的应用程序ID
      final Uri url = Uri.parse('https://apps.apple.com/app/id$appId?action=write-review');

      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        _showError('Could not launch $url');
      }
    } else if (Platform.isAndroid) {
      // Android Google Play review URL
      String packageName = await AppService().packageName(); // 你的Android应用包名
      final Uri url = Uri.parse('https://play.google.com/store/apps/details?id=$packageName');

      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        _showError('Could not launch $url');
      }
    } else {
      _showError('Unsupported platform');
    }
  }

  static Future<void> openAppStore() async {
    try {
      if (Platform.isIOS) {
        // iOS App Store应用详情页URL
        const String appId = '6499512711'; // 替换为你的App Store应用ID
        final Uri url = Uri.parse('https://apps.apple.com/app/id$appId');

        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        } else {
          _showError('Could not launch $url');
        }
      } else if (Platform.isAndroid) {
        // Android Google Play应用详情页URL
        String packageName = await AppService().packageName(); // 替换为获取Android应用包名的方法
        final Uri url = Uri.parse('https://play.google.com/store/apps/details?id=$packageName');

        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        } else {
          _showError('Could not launch $url');
        }
      } else {
        _showError('Unsupported platform');
      }
    } catch (e) {
      _showError('Could not launch ${e.toString()}');
    }
  }

  static void _showError(String message) {
    FToast.toast(message);
  }
}
