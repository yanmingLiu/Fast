import 'dart:io';

import 'package:fast_ai/component/f_dialog.dart';
import 'package:fast_ai/component/f_loading.dart';
import 'package:fast_ai/component/f_toast.dart';
import 'package:fast_ai/data/a_pop.dart';
import 'package:fast_ai/generated/locales.g.dart';
import 'package:fast_ai/pages/router/routers.dart';
import 'package:fast_ai/services/f_api.dart';
import 'package:fast_ai/services/f_cache.dart';
import 'package:fast_ai/services/f_service.dart';
import 'package:fast_ai/services/m_y.dart';
import 'package:fast_ai/values/theme_style.dart';
import 'package:fast_ai/values/values.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class AppRouter {
  AppRouter._();

  /// 导航到搜索页面
  static void pushSearch() async {
    Get.toNamed(Routers.search);
  }

  static Future<void> pushChat(String? roleId,
      {bool showLoading = true}) async {
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
        FApi.loadRoleById(roleId), // 查角色
        FApi.addSession(roleId), // 查会话
      ]);

      var role = results[0];
      var session = results[1];

      // 检查角色和会话是否为 null
      if (role == null) {
        _dismissAndShowErrorToast('roleId is null, please check!');
        return;
      }
      if (session == null) {
        _dismissAndShowErrorToast('sessionId is null, please check!');
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
  static void pushVip(ProFrom from) {
    Get.toNamed(Routers.vip, arguments: from);
  }

  /// 导航到角色资料页面
  ///
  /// [role] 要查看的角色信息
  static void pushProfile(APop role) {
    Get.toNamed(Routers.profile, arguments: role);
  }

  /// 导航到宝石/钻石页面
  ///
  /// [from] 表示从哪个入口进入宝石页面
  static void pushGem(GemsFrom from) {
    Get.toNamed(Routers.gems, arguments: from);
  }

  /// 导航到Undr页面
  ///
  /// [role] 可选的角色信息
  static void pushUndr(APop? role) {
    Get.toNamed(Routers.undr, arguments: role);
  }

  static Future<T?>? pushPhone<T>({
    required int sessionId,
    required APop role,
    required bool showVideo,
    CallState callState = CallState.calling,
  }) async {
    // 检查 Mic 权限 和 语音权限
    final res = await checkPermissions();
    if (!res) {
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
    required APop role,
    required bool showVideo,
    CallState callState = CallState.calling,
  }) async {
    final roleId = role.id;
    if (roleId == null) {
      FToast.toast('roleId is null, please check!');
      Get.back();
      return null;
    }

    var seesion = await FApi.addSession(roleId); // 查会话
    final sessionId = seesion?.id;
    if (sessionId == null) {
      FToast.toast('sessionId is null, please check!');
      Get.back();
      return null;
    }
    // 检查 Mic 权限 和 语音权限
    if (!await checkPermissions()) {
      showNoPermissionDialog();
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
    try {
      // 先检查当前权限状态
      PermissionStatus micStatus = await Permission.microphone.status;
      PermissionStatus speechStatus = await Permission.speech.status;

      log.d(
        'AppRouter checkPermissions - Current status - Microphone: $micStatus, Speech: $speechStatus',
      );

      // 如果权限已经授予，直接返回 true
      if (micStatus.isGranted && speechStatus.isGranted) {
        return true;
      }

      // 如果权限被永久拒绝，直接返回 false
      if (micStatus.isPermanentlyDenied || speechStatus.isPermanentlyDenied) {
        log.d('Permissions permanently denied');
        return false;
      }

      // 请求权限
      log.d('Requesting permissions...');
      Map<Permission, PermissionStatus> statuses = await [
        Permission.microphone,
        Permission.speech,
      ].request();

      bool allGranted = statuses.values.every((status) => status.isGranted);
      log.d('Permission request result: $statuses, allGranted: $allGranted');

      return allGranted;
    } catch (e) {
      log.e('Error checking/requesting permissions in AppRouter: $e');
      return false;
    }
  }

  // 没有权限提示
  static Future<void> showNoPermissionDialog() async {
    FDialog.alert(
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
  static Future<T?>? pushPhoneGuide<T>({required APop role}) async {
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
    final version = await FService().version();
    final device = await FCache().phoneId();
    final uid = MY().user?.id;

    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: FService.email, // 收件人
      query:
          "subject=Feedback&body=version: $version\ndevice: $device\nuid: $uid\nPlease input your problem:\n", // 设置默认主题和正文内容
    );

    launchUrl(emailUri);
  }

  static void toPrivacy() {
    launchUrl(Uri.parse(FService.privacy));
  }

  static void toTerms() {
    launchUrl(Uri.parse(FService.terms));
  }

  static Future<void> openAppStoreReview() async {
    if (Platform.isIOS) {
      // iOS App Store review URL
      const String appId = '6740072684'; // App Store的应用程序ID
      final Uri url =
          Uri.parse('https://apps.apple.com/app/id$appId?action=write-review');

      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        _showError('Could not launch $url');
      }
    } else if (Platform.isAndroid) {
      // Android Google Play review URL
      String packageName = await FService().packageName(); // 你的Android应用包名
      final Uri url = Uri.parse(
          'https://play.google.com/store/apps/details?id=$packageName');

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
        const String appId = '6751800550'; // 替换为你的App Store应用ID
        final Uri url = Uri.parse('https://apps.apple.com/app/id$appId');

        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        } else {
          _showError('Could not launch $url');
        }
      } else if (Platform.isAndroid) {
        // Android Google Play应用详情页URL
        String packageName =
            await FService().packageName(); // 替换为获取Android应用包名的方法
        final Uri url = Uri.parse(
            'https://play.google.com/store/apps/details?id=$packageName');

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

      FDialog.dismiss();
    }

    Map<String, Function> actsion = {
      LocaleKeys.spam.tr: request,
      LocaleKeys.violence.tr: request,
      LocaleKeys.child_abuse.tr: request,
      LocaleKeys.copyright.tr: request,
      LocaleKeys.personal_details.tr: request,
      LocaleKeys.illegal_drugs.tr: request,
    };

    FDialog.show(
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
                    style: ThemeStyle.openSans(
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
