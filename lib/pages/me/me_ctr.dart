import 'dart:io';

import 'package:fast_ai/component/app_dialog.dart';
import 'package:fast_ai/component/f_loading.dart';
import 'package:fast_ai/component/f_toast.dart';
import 'package:fast_ai/generated/locales.g.dart';
import 'package:fast_ai/pages/me/me_chat_bg.dart';
import 'package:fast_ai/services/api.dart';
import 'package:fast_ai/services/app_cache.dart';
import 'package:fast_ai/services/app_service.dart';
import 'package:fast_ai/services/app_user.dart';
import 'package:fast_ai/tools/app_router.dart';
import 'package:fast_ai/values/app_values.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class MeCtr extends GetxController {
  final FocusNode _focusNode = FocusNode();
  late TextEditingController _textEditingController;
  var version = ''.obs;
  var chatbgImagePath = ''.obs;
  var nickname = ''.obs;

  @override
  void onInit() {
    super.onInit();

    nickname.value = AppUser().user?.nickname ?? '';

    _loadData();
  }

  void _loadData() async {
    final v = await AppService().version();
    final n = await AppService().buildNumber();
    version.value = '$v  $n';

    chatbgImagePath.value = AppCache().chatBgImagePath;
  }

  void changeNickName() {
    nickname.value = AppUser().user?.nickname ?? '';
    _textEditingController = TextEditingController(text: nickname.value);

    AppDialog.input(
      title: LocaleKeys.your_nickname.tr,
      hintText: LocaleKeys.input_your_nickname.tr,
      focusNode: _focusNode,
      textEditingController: _textEditingController,
      onConfirm: () async {
        if (_textEditingController.text.trim().isEmpty) {
          FToast.toast(LocaleKeys.input_your_nickname.tr);
          return;
        }
        nickname.value = _textEditingController.text.trim();
        FLoading.showLoading();
        await AppUser().updateUser(nickname.value);
        await FLoading.dismiss();
        AppDialog.dismiss();
      },
    );
  }

  void resetChatBackground() async {
    await AppDialog.dismiss();

    AppCache().chatBgImagePath = '';
    chatbgImagePath.value = '';
  }

  void changeChatBackground() async {
    AppDialog.show(
      child: MeChatBg(
        onTapUpload: uploadImage,
        onTapUseChat: resetChatBackground,
        isUseChater: chatbgImagePath.isEmpty,
      ),
    );
  }

  void uploadImage() async {
    await AppDialog.dismiss();

    final List<AssetEntity>? result = await AssetPicker.pickAssets(
      Get.context!,

      pickerConfig: const AssetPickerConfig(
        maxAssets: 1,
        requestType: RequestType.image,
        themeColor: Color(0xFF3F8DFD),
      ),
    );
    if (result != null && result.isNotEmpty) {
      final iamge = result.first;
      final pickedFile = await iamge.file;
      if (pickedFile != null) {
        final directory = await getApplicationDocumentsDirectory();
        final fileName = path.basename(pickedFile.path);
        final cachedImagePath = path.join(directory.path, fileName);
        final File cachedImage = await File(pickedFile.path).copy(cachedImagePath);
        AppCache().chatBgImagePath = cachedImage.path;
        chatbgImagePath.value = cachedImage.path;
      }
    }
  }

  void autoTranslation(bool value) async {
    if (AppUser().isVip.value) {
      FLoading.showLoading();
      await Api.updateEventParams(autoTranslate: value);
      await AppUser().getUserInfo();
      FLoading.dismiss();
    } else {
      AppRouter.pushVip(VipFrom.trans);
    }
  }
}
