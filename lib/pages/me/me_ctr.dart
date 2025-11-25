import 'dart:io';

import 'package:fast_ai/component/f_dialog.dart';
import 'package:fast_ai/component/f_loading.dart';
import 'package:fast_ai/component/f_toast.dart';
import 'package:fast_ai/generated/locales.g.dart';
import 'package:fast_ai/pages/me/me_chat_bg.dart';
import 'package:fast_ai/pages/router/n_t_n.dart';
import 'package:fast_ai/services/f_api.dart';
import 'package:fast_ai/services/f_cache.dart';
import 'package:fast_ai/services/f_service.dart';
import 'package:fast_ai/services/m_y.dart';
import 'package:fast_ai/values/values.dart';
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

    nickname.value = MY().user?.nickname ?? '';

    _loadData();
  }

  void _loadData() async {
    final v = await FService().version();
    final n = await FService().buildNumber();
    version.value = '$v  $n';

    chatbgImagePath.value = FCache().chatBgImagePath;
  }

  void changeNickName() {
    nickname.value = MY().user?.nickname ?? '';
    _textEditingController = TextEditingController(text: nickname.value);

    FDialog.input(
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
        await MY().updateUser(nickname.value);
        await FLoading.dismiss();
        FDialog.dismiss();
      },
    );
  }

  void resetChatBackground() async {
    await FDialog.dismiss();

    FCache().chatBgImagePath = '';
    chatbgImagePath.value = '';
  }

  void changeChatBackground() async {
    FDialog.show(
      child: MeChatBg(
        onTapUpload: uploadImage,
        onTapUseChat: resetChatBackground,
        isUseChater: chatbgImagePath.isEmpty,
      ),
    );
  }

  void uploadImage() async {
    await FDialog.dismiss();

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
        FLoading.showLoading();
        final directory = await getApplicationDocumentsDirectory();
        final fileName = path.basename(pickedFile.path);
        final cachedImagePath = path.join(directory.path, fileName);
        final File cachedImage =
            await File(pickedFile.path).copy(cachedImagePath);
        FCache().chatBgImagePath = cachedImage.path;
        chatbgImagePath.value = cachedImage.path;
        await Future.delayed(Duration(seconds: 2));
        FLoading.dismiss();
        FToast.toast(LocaleKeys.back_updated_succ.tr);
      }
    }
  }

  void autoTranslation(bool value) async {
    if (MY().isVip.value) {
      FLoading.showLoading();
      await FApi.updateEventParams(autoTranslate: value);
      await MY().getUserInfo();
      FLoading.dismiss();
    } else {
      NTN.pushVip(ProFrom.trans);
    }
  }
}
