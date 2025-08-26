import 'dart:io';

import 'package:fast_ai/component/app_dialog.dart';
import 'package:fast_ai/component/f_loading.dart';
import 'package:fast_ai/component/f_toast.dart';
import 'package:fast_ai/data/role_data.dart';
import 'package:fast_ai/generated/locales.g.dart';
import 'package:fast_ai/pages/router/routers.dart';
import 'package:fast_ai/services/api.dart';
import 'package:fast_ai/services/app_cache.dart';
import 'package:fast_ai/services/app_service.dart';
import 'package:fast_ai/services/app_user.dart';
import 'package:fast_ai/values/app_values.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:url_launcher/url_launcher.dart';

class AppRouter {
  AppRouter._();

  /// 导航到搜索页面
  static void pushSearch() async {
    Get.toNamed(Routers.search);
  }

  static Future<void> pushChat(String? roleId, {bool showLoading = true}) async {
    if (roleId == null) {
      FToast.toast('roleId is null, please check!');
      return;
    }

    try {
      if (showLoading) {
        FLoading.showLoading();
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

      FLoading.dismiss();
      Get.toNamed(Routers.msg, arguments: {'role': role, 'session': session});
    } catch (e) {
      FLoading.dismiss();
      FToast.toast(e.toString());
    }
  }

  static void _dismissAndShowErrorToast(String message) {
    FLoading.dismiss();
    FToast.toast(message);
  }

  /// 导航到VIP页面
  ///
  /// [from] 表示从哪个入口进入VIP页面
  static void pushVip(VipFrom from) {
    Get.toNamed(Routers.vip, arguments: from);
  }

  /// 导航到角色资料页面
  ///
  /// [role] 要查看的角色信息
  static void pushProfile(Role role) {
    Get.toNamed(Routers.profile, arguments: role);
  }

  /// 导航到宝石/钻石页面
  ///
  /// [from] 表示从哪个入口进入宝石页面
  static void pushGem(ConsumeFrom from) {
    Get.toNamed(Routers.gems, arguments: from);
  }

  /// 导航到Undr页面
  ///
  /// [role] 可选的角色信息
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
      FToast.toast('sessionId is null, please check!');
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
    bool available = await speechToText.initialize();

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

  /// 导航到电话引导页面
  ///
  /// [role] 角色信息
  static Future<T?>? pushPhoneGuide<T>({required Role role}) {
    return Get.toNamed(Routers.phoneGuide, arguments: {'role': role});
  }

  /// 导航到图片预览页面
  ///
  /// [imageUrl] 要预览的图片URL
  static void pushImagePreview(String imageUrl) {
    Get.toNamed(Routers.imagePreview, arguments: imageUrl);
  }

  /// 导航到视频预览页面
  ///
  /// [url] 要预览的视频URL
  static void pushVideoPreview(String url) {
    Get.toNamed(Routers.videoPreview, arguments: url);
  }

  /// 导航到蒙版页面
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

  static void report() {
    void request() async {
      FLoading.showLoading();
      await Future.delayed(const Duration(seconds: 1));
      FLoading.dismiss();
      FToast.toast(LocaleKeys.report_successful.tr);

      AppDialog.dismiss();
    }

    Map<String, Function> actsion = {
      LocaleKeys.spam.tr: request,
      LocaleKeys.violence.tr: request,
      LocaleKeys.child_abuse.tr: request,
      LocaleKeys.copyright.tr: request,
      LocaleKeys.personal_details.tr: request,
      LocaleKeys.illegal_drugs.tr: request,
    };

    AppDialog.show(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Color(0xFF333333),
        ),
        child: ListView.separated(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: actsion.keys.length,
          itemBuilder: (_, index) {
            final fn = actsion.values.toList()[index];
            return InkWell(
              onTap: () {
                fn.call();
              },
              child: SizedBox(
                height: 54,
                child: Center(
                  child: Text(
                    actsion.keys.toList()[index],
                    textAlign: TextAlign.center,
                    style: GoogleFonts.openSans(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            );
          },
          separatorBuilder: (context, index) {
            return Container(height: 1, color: const Color(0x1AFFFFFF));
          },
        ),
      ),
      clickMaskDismiss: false,
    );
  }
}
