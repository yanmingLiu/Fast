import 'dart:async';
import 'dart:math';

import 'package:extended_image/extended_image.dart';
import 'package:fast_ai/component/app_dialog.dart';
import 'package:fast_ai/component/f_loading.dart';
import 'package:fast_ai/component/f_toast.dart';
import 'package:fast_ai/data/clothing_data.dart';
import 'package:fast_ai/data/msg_data.dart';
import 'package:fast_ai/data/role_data.dart';
import 'package:fast_ai/data/session_data.dart';
import 'package:fast_ai/data/toys_data.dart';
import 'package:fast_ai/gen/assets.gen.dart';
import 'package:fast_ai/generated/locales.g.dart';
import 'package:fast_ai/pages/chat/chat_ctr.dart';
import 'package:fast_ai/pages/router/app_router.dart';
import 'package:fast_ai/services/api.dart';
import 'package:fast_ai/services/app_cache.dart';
import 'package:fast_ai/services/app_log_event.dart';
import 'package:fast_ai/services/app_service.dart';
import 'package:fast_ai/services/app_user.dart';
import 'package:fast_ai/tools/trans_tool.dart';
import 'package:fast_ai/values/app_values.dart';
import 'package:flutter/material.dart';
import 'package:flutter_client_sse/constants/sse_request_type_enum.dart';
import 'package:flutter_client_sse/flutter_client_sse.dart';
import 'package:get/get.dart';

class MsgCtr extends GetxController {
  var list = <MsgData>[].obs;

  RxList inputTags = [].obs;

  late Role role;
  late SessionData session;
  int? get sessionId => session.id;

  bool isNewChat = false;

  // 相册变动
  var roleImagesChaned = 0.obs;

  // 聊天等级变动
  Rx<ChatAnserLevel?> chatLevel = Rx<ChatAnserLevel?>(null);

  List<Map<String, dynamic>> chatLevelConfigs = [];

  List<Map<String, dynamic>> chatLevelList = [
    {'icon': '👋', 'text': 'Level 1 Reward', 'level': 1, 'gems': 0},
    {'icon': '🥱', 'text': 'Level 2 Reward', 'level': 2, 'gems': 0},
    {'icon': '😊', 'text': 'Level 3 Reward', 'level': 3, 'gems': 0},
    {'icon': '💓', 'text': 'Level 4 Reward', 'level': 4, 'gems': 0},
  ];

  // 发送id
  var tmpSendId = '16549084165484';
  MsgData? tmpSendMsg;

  // 显示文字流的临时消息 id
  var tempId = '';

  bool isRecieving = false; // 正在接收消息
  bool isMediaStarted = false; // json 解析中
  bool isLock = false; // 是否加密

  final kTagNormal = 'TEXT-LOCK:NORMAL';
  final kTagPrivate = 'TEXT-LOCK:PRIVATE';
  final kErrorMsg = 'Hmm… we lost connection for a bit. Please try again!';

  StringBuffer buffer = StringBuffer();

  @override
  void onInit() {
    super.onInit();

    // 获取传递的参数
    var arguments = Get.arguments;
    if (arguments != null) {
      role = arguments['role'];
      session = arguments['session'];
    }

    setupTease();

    loadMsg();

    loadChatLevel();

    AppUser().loadToysAndClotheConfigs();
    AppUser().getPriceConfig();
    AppUser().getUserInfo();
  }

  @override
  void onClose() {
    closeSSE();
    super.onClose();
  }

  Future loadMsg() async {
    if (sessionId == null) {
      return;
    }
    list.clear();
    _addDefaaultTips();
    final page = await Api.messageList(1, 10000, sessionId!);
    if (page != null) {
      final records = page.records ?? [];

      // 获取已翻译消息 id
      final Set<String> ids = AppCache().translationMsgIds;
      // 遍历消息列表，赋值 showTranslate
      for (var msg in records) {
        if (msg.id != null && ids.contains(msg.id)) {
          msg.showTranslate = true;
        }
        if (AppUser().user?.autoTranslate == true && msg.translateAnswer != null) {
          msg.showTranslate = true;
        }
      }

      list.addAll(records);
    }
  }

  void _addDefaaultTips() {
    final tips = MsgData();
    tips.source = MsgSource.tips;
    list.add(tips);

    var scenario = session.scene ?? role.scenario;

    if (scenario != null && scenario.isNotEmpty) {
      final intro = MsgData();
      intro.source = MsgSource.scenario;
      intro.answer = scenario;
      list.add(intro);
    } else {
      if (role.aboutMe != null && role.aboutMe!.isNotEmpty) {
        final intro = MsgData();
        intro.source = MsgSource.intro;
        intro.answer = role.aboutMe;
        list.add(intro);
      }
    }
    _addRandomGreetings();
  }

  Future<void> _addRandomGreetings() async {
    final greetings = role.greetings;
    // final greetingsVoices = role.greetingsVoice;
    if (greetings == null || greetings.isEmpty) {
      return;
    }
    int randomIndex = Random().nextInt(greetings.length);
    var str = greetings[randomIndex];

    // String? voiceUrl;
    // int voiceDur = 0;
    // if (greetingsVoices != null && greetingsVoices.length > randomIndex) {
    //   final voice = greetingsVoices[randomIndex];
    //   voiceUrl = voice.url;
    //   voiceDur = voice.duration ?? 0;

    //   if (sessionId != null) {
    //     final isExist = AppCache().isSessionExist(sessionId!);
    //     if (isExist) {
    //       isNewChat = false;
    //       log.d('------旧会话');
    //     } else {
    //       log.d('------新会话');
    //       isNewChat = true;
    //       if (voiceUrl.isNotEmpty) {
    //         DownloadUtil.download(voiceUrl);
    //       }
    //       AppCache().addSessionId(sessionId!);
    //     }
    //   }
    // }
    final msg = MsgData();
    msg.id = '${DateTime.now().millisecondsSinceEpoch}';
    msg.answer = str;
    // msg.voiceUrl = voiceUrl;
    // msg.voiceDur = voiceDur;
    msg.source = MsgSource.welcome;
    list.add(msg);
  }

  void setupTease() {
    inputTags.clear();

    if (AppCache().isBig) {
      inputTags.add({
        'id': 0,
        'name': 'Tease',
        'icon': Assets.images.msgAuto.path,
        'list': [
          "What's your favorite intimate moment?",
          "Are you experienced in relationships?",
          "Have you ever been with someone your friend dated?",
          "Where was your first time?",
          "If you could choose any place to be intimate, where would it be?",
          "Do you have a favorite position?",
          "Are you open to exploring new things in the bedroom?",
          "What do you find more attractive: curves or a toned figure?",
          "What's the most romantic thing someone has said to you during intimacy?",
          "Can you make a moment unforgettable?",
          "When do you feel most in the mood for romance?",
          "Can you share something personal about yourself?",
          "Would you like to exchange some romantic photos?",
          "Can I see a photo of you?",
        ],
      });
    }

    inputTags.add({'id': 3, 'name': 'Mask', 'icon': Assets.images.msgMask.path, 'list': []});

    if (AppCache().isBig) {
      inputTags.add({'id': 2, 'name': 'Gifts', 'icon': Assets.images.msgGift.path, 'list': []});
    }

    // if (AppCache().isBig) {
    //   final count = AppCache().sendMsgCount;
    //   if (count >= AppService().showClothingCount) {
    //     inputTags.add({'id': 1, 'name': 'Undress', 'icon': Assets.images.msgClo.path, 'list': []});
    //   }
    // }
  }

  Future<bool> canSendMsg(String text) async {
    if (isRecieving) {
      FToast.toast(LocaleKeys.wait_for_response.tr);
      return false;
    }

    MsgData lastMsg = list.last;
    if (lastMsg.typewriterAnimated) {
      FToast.toast(LocaleKeys.wait_for_response.tr);
      return false;
    }

    if (text.isEmpty) {
      FToast.toast(LocaleKeys.please_input.tr);
      return false;
    }
    final roleId = role.id;
    if (roleId == null) {
      return false;
    }
    if (!AppUser().isVip.value) {
      if (role.gems == true) {
        final flag = AppUser().isBalanceEnough(ConsumeFrom.text);
        if (!flag) {
          await FToast.toast(LocaleKeys.not_enough.tr);
          // v1.3.0 - 调整为跳订阅页
          AppRouter.pushVip(VipFrom.send);
          return false;
        }
      } else {
        /// 免费角色 - 最大免费条数
        final maxCount = AppService().maxFreeChatCount;
        final sencCount = AppCache().sendMsgCount;

        if (sencCount > maxCount) {
          log.d('[AppDialog]: maxFreeChatCount $maxCount');

          AppDialog.alert(
            message: LocaleKeys.free_chat_used.tr,
            confirmText: LocaleKeys.upgrade_to_chat.tr,
            onConfirm: () {
              logEvent('t_chat_send');
              AppRouter.pushVip(VipFrom.send);
            },
          );
          return false;
        }
      }
    }
    return true;
  }

  void checkSendCount() async {
    // 发送成功后，更新发送次数
    AppCache().sendMsgCount = AppCache().sendMsgCount + 1;
    setupTease();

    // if (AppCache().isBig) {
    //   var count = AppCache().sendMsgCount;
    //   if (count == AppService().showClothingCount) {
    //     log.d('[AppDialog]: showClothingCount $count');

    //     AppDialog.alert(
    //       message: LocaleKeys.easter_egg_unlock.tr,
    //       confirmText: LocaleKeys.yes.tr,
    //       clickMaskDismiss: false,
    //       onConfirm: () {
    //         AppDialog.dismiss();
    //         AppRouter.pushUndr(role);
    //       },
    //     );
    //   } else {
    //     checkRateMsgCount();
    //   }
    // } else {
    //   checkRateMsgCount();
    // }
  }

  void checkRateMsgCount() async {
    AppCache().rateCount++;
    log.d('[AppDialog]: checkRateMsgCount ${AppCache().rateCount}');
    if (AppCache().rateCount == 8) {
      AppDialog.showRateUs(LocaleKeys.rate_us_msg.tr);
    }
  }

  Future<bool> resetConv() async {
    FLoading.showLoading();
    var result = await Api.resetSession(sessionId ?? 0);
    FLoading.dismiss();
    if (result != null) {
      session = result;
      list.clear();
      _addDefaaultTips();
      return true;
    }
    return false;
  }

  Future<bool> deleteConv() async {
    FLoading.showLoading();
    var result = await Api.deleteSession(sessionId ?? 0);

    if (result && Get.isRegistered<ChatCtr>()) {
      Get.find<ChatCtr>().dataList.removeWhere((r) => r.id == sessionId);
      Get.find<ChatCtr>().dataList.refresh();
    }

    FLoading.dismiss();
    return result;
  }

  Future sendMsg(String text) async {
    bool canSend = await canSendMsg(text);
    if (!canSend) {
      return;
    }

    // 每发送5条消息触发广告
    messageCounter++;
    // if (messageCounter % AppService().msgSendShowAdCount == 0) {
    //   MyAd().showChatAd(placement: PlacementType.chat);
    // }

    isRecieving = true;

    final charId = role.id;
    final conversationId = sessionId ?? 0;
    final uid = AppUser().user?.id;
    if (charId == null || uid == null) {
      return;
    }

    // 临时发送显示的消息
    final msg = MsgData(
      id: tmpSendId,
      question: text,
      userId: AppUser().user?.id,
      conversationId: conversationId,
      characterId: charId,
      onAnswer: true,
    );
    msg.source = MsgSource.sendText;
    list.add(msg);
    tmpSendMsg = msg;

    // // 确保流监听不重复
    // await subscription?.cancel();
    // subscription = null;

    final url = '${AppService().baseUrl}${ApiPath.sendMsg}';
    final body = {
      'character_id': charId,
      'conversation_id': conversationId,
      'message': text,
      'user_id': uid,
    };
    startListening(url, body);
  }

  Future startListening(String url, Map<String, dynamic>? body) async {
    try {
      isLock = false;

      log.d("开始监听...url:$url, body:$body");

      final deviceId = await AppCache().phoneId();
      final platform = AppService().platform;

      final header = {
        "Accept": "application/json",
        "Content-Type": "application/json",
        'device-id': deviceId,
        'platform': platform,
      };

      SSEClient.subscribeToSSE(
        maxRetries: 0,
        method: SSERequestType.POST,
        url: url,
        header: header,
        body: body,
      ).listen(
        (event) {
          // 确保流未关闭时才添加数据
          if (event.event == 'error') {
            log.e('Error receiving SSE event: ${event.data}');
            progressSSEError();
          } else {
            if (event.data!.isNotEmpty) {
              progressSSE(event.data!);
            }
          }
        },
        onError: (e) {
          log.e('onError: Error receiving SSE event: $e');
          progressSSEError();
        },
      );
    } catch (e) {
      log.e('------->Error: $e');
      progressSSEError();
    }
  }

  void progressSSEError() {
    closeSSE();
    tmpSendMsg?.onAnswer = false;

    MsgData msg = MsgData(id: DateTime.now().millisecondsSinceEpoch.toString(), answer: kErrorMsg);
    msg.source = MsgSource.error;
    list.add(msg);
    FLoading.dismiss();
  }

  void progressSSE(String data) async {
    if (data.contains(kTagNormal)) {
      isLock = false;
    } else if (data.contains(kTagPrivate)) {
      isLock = true;
    }

    // 去掉换行符
    data = data.replaceAll(RegExp(r'[\r\n]+'), '');

    if (data.contains('Insufficient gold')) {
      log.d('EOF Insufficient gold');
      list.removeLast();
      closeSSE();
      AppRouter.pushGem(ConsumeFrom.send);
      return;
    }

    if (data.contains('EOF')) {
      log.d('EOF received, clearing buffer and stopping listening');
      closeSSE();
      return;
    }

    if (data.contains('MEDIA START')) {
      isMediaStarted = true;

      /// 修改发送消息的状态
      tmpSendMsg?.onAnswer = false;

      final regex = RegExp(r'MEDIA START(.*?)MEDIA END', dotAll: true);
      final match = regex.firstMatch(data);

      if (match != null) {
        String jsonString = match.group(1)!.trim();
        log.d('Extracted JSON: $jsonString');
        var msg = MsgData.fromRawJson(jsonString);

        if (msg.conversationId == sessionId) {
          if (isLock) {
            msg.typewriterAnimated = AppUser().isVip.value;
          } else {
            msg.typewriterAnimated = true;
          }

          // 删除最后一条tmpSendMsg
          if (list.isNotEmpty && list.last.id == tmpSendId && msg.question == list.last.question) {
            list.removeLast();
          }

          final index = list.indexOf(msg);
          log.d('currentMsg index: $index');
          if (index != -1) {
            list[index] = msg;
          } else {
            list.add(msg);
          }
          _checkChatLevel(msg);
        }
      } else {
        log.e('No match found for MEDIA START');
      }

      isRecieving = false;
      await AppUser().getUserInfo();
    }
    FLoading.dismiss();
    tmpSendMsg = null;
  }

  // 消息计数器
  var messageCounter = 0;

  void closeSSE() async {
    buffer.clear();
    isRecieving = false;
    isMediaStarted = false;

    log.d("关闭监听...");
    // await subscription?.cancel();
    // SSEUtil().close();
    // subscription = null;
    SSEClient.unsubscribeFromSSE();
    log.d("监听已关闭");
  }

  void _checkChatLevel(MsgData msg) async {
    bool upgrade = msg.upgrade ?? false;
    int rewards = msg.rewards ?? 0;
    var level = msg.appUserChatLevel;
    chatLevel.value = level;
    if (upgrade) {
      log.d('[AppDialog]: appUserChatLevel $upgrade');

      // 升级了
      await _showChatLevelUp(rewards);

      if ((level?.level ?? 0) == 3) {
        if (AppDialog.rateLevel3Shoed == false) {
          AppDialog.showRateUs(LocaleKeys.rate_us_msg.tr);
          AppDialog.rateLevel3Shoed = true;
        }
      }
    } else {
      checkSendCount();
    }
  }

  Future _showChatLevelUp(int rewards) async {
    await AppDialog.showChatLevelUp(rewards);

    checkSendCount();
  }

  Future<void> loadChatLevel() async {
    if (chatLevelConfigs.isNotEmpty) {
      return;
    }
    try {
      final configs = await Api.getChatLevelConfig() ?? [];
      chatLevelConfigs = configs.isEmpty
          ? chatLevelList
          : configs.map((c) {
              return {
                'icon': c.title ?? '👋',
                'level': c.level ?? 1,
                'text': LocaleKeys.level_up_value.trParams({'level': '${c.level}'}),
                'gems': c.reward ?? 0,
              };
            }).toList();

      final roleId = role.id;
      final userId = AppUser().user?.id;
      if (roleId == null || userId == null) {
        return;
      }
      var res = await Api.fetchChatLevel(charId: roleId, userId: userId);
      chatLevel.value = res;
    } catch (e) {
      log.e('loadChatLevel is error:$e');
    }
  }

  Future<void> onTapUnlockImage(RoleImage image) async {
    final gems = image.gems ?? 0;
    if (AppUser().balance.value < gems) {
      AppRouter.pushGem(ConsumeFrom.album);
      return;
    }

    final imageId = image.id;
    final modelId = image.modelId;
    if (imageId == null || modelId == null) {
      return;
    }

    FLoading.showLoading();
    final res = await Api.unlockImageReq(imageId, modelId);
    FLoading.dismiss();
    if (res) {
      // 创建一个新的 images 列表
      final updatedImages = role.images?.map((i) {
        if (i.id == imageId) {
          return i.copyWith(unlocked: true);
        }
        return i;
      }).toList();

      // 更新 Role 对象
      role = role.copyWith(images: updatedImages);
      roleImagesChaned.value++;
      AppUser().getUserInfo();

      onTapImage(image);
    }
  }

  void onTapImage(RoleImage image) {
    final imageUrl = image.imageUrl;
    if (imageUrl == null) {
      return;
    }
    AppRouter.pushImagePreview(imageUrl);
  }

  void translateMsg(MsgData msg) async {
    MsgData lastMsg = list.last;
    if (lastMsg.typewriterAnimated) {
      FToast.toast(LocaleKeys.wait_for_response.tr);
      return;
    }

    final content = msg.answer;
    final id = msg.id;

    // 内容为空直接返回
    if (content == null || content.isEmpty) return;
    if (id == null) return;

    // 定义更新消息的方法
    Future<void> updateMessage({required bool showTranslate, String? translate}) async {
      msg.showTranslate = showTranslate;

      _transCache(isAdd: showTranslate, id: id);

      if (translate != null) {
        msg.translateAnswer = translate;

        Api.saveMsgTrans(id: id, text: translate);
      }
      list.refresh();
    }

    // 根据状态处理逻辑
    if (msg.showTranslate == true) {
      await updateMessage(showTranslate: false);
    } else if (msg.translateAnswer != null) {
      await updateMessage(showTranslate: true);
      TransTool().handleTranslationClick();
    } else {
      logEvent('c_trans');
      if (msg.translateAnswer == null) {
        // 获取翻译内容
        FLoading.showLoading();
        String? result = await Api.translateText(content);
        FLoading.dismiss();
        // 更新消息并显示翻译
        await updateMessage(showTranslate: true, translate: result);
      } else {
        await updateMessage(showTranslate: true);
      }

      TransTool().handleTranslationClick();
    }
  }

  void _transCache({required bool isAdd, required String id}) {
    final Set<String> ids = AppCache().translationMsgIds;
    if (isAdd) {
      ids.add(id); // 重复添加会自动忽略
    } else {
      ids.remove(id);
    }
    AppCache().translationMsgIds = ids;
  }

  void sendToy(ToysData toy) async {
    try {
      FLoading.showLoading();
      var balance = AppUser().balance.value;
      var price = toy.itemPrice ?? 0;
      if (balance < price) {
        AppRouter.pushGem(ConsumeFrom.gift_toy);
        return;
      }

      final convId = session.id;
      final giftId = toy.id;
      final roleId = role.id;
      if (convId == null || giftId == null || roleId == null) {
        return;
      }
      if (Get.isBottomSheetOpen == true) {
        Get.back();
      }
      var msg = await Api.sendToys(convId: convId, id: giftId, roleId: roleId);
      if (msg != null) {
        list.add(msg);
      }
      AppUser().getUserInfo();
    } catch (e) {
      FToast.toast(LocaleKeys.some_error_try_again.tr);
    } finally {
      FLoading.dismiss();
    }
  }

  void sendChothes(ClothingData clothings) async {
    try {
      var balance = AppUser().balance.value;
      var price = clothings.itemPrice ?? 0;
      if (balance < price) {
        AppRouter.pushGem(ConsumeFrom.gift_clo);
        return;
      }

      final convId = session.id;
      final id = clothings.id;
      final roleId = role.id;
      if (convId == null || id == null || roleId == null) {
        return;
      }
      Get.back();

      AppDialog.showGiftLoading();

      isRecieving = true;

      MsgData? msg = await Api.sendClothes(convId: convId, id: id, roleId: roleId);

      var imgUrl = msg?.giftImg;

      if (imgUrl != null) {
        Completer<void> completer = Completer<void>();
        final ExtendedNetworkImageProvider imageProvider = ExtendedNetworkImageProvider(
          imgUrl,
          cache: true,
        );
        imageProvider
            .resolve(const ImageConfiguration())
            .addListener(
              ImageStreamListener(
                (ImageInfo image, bool synchronousCall) {
                  if (!completer.isCompleted) {
                    completer.complete();
                  }
                },
                onError: (dynamic exception, StackTrace? stackTrace) {
                  if (!completer.isCompleted) {
                    completer.completeError(exception); // 加载失败时返回异常
                  }
                },
              ),
            );
        // 等待图片加载完成
        await completer.future;
      }
      isRecieving = false;

      if (msg != null) {
        list.add(msg);

        AppRouter.pushImagePreview(imgUrl ?? '');

        AppUser().getUserInfo();
      } else {
        FToast.toast(LocaleKeys.some_error_try_again.tr);
      }
    } catch (e) {
      FToast.toast(LocaleKeys.some_error_try_again.tr);
    } finally {
      AppDialog.hiddenGiftLoading();
    }
  }

  /// 找到最后一条服务器消息
  ///
  /// 服务器消息类型(msg.source)包括：
  /// - text('TEXT_GEN'): 文本消息
  /// - video('VIDEO'): 视频消息
  /// - audio('AUDIO'): 音频消息
  /// - photo('PHOTO'): 图片消息
  /// - gift('GIFT'): 礼物消息
  /// - clothe('CLOTHE'): 服装消息
  ///
  /// 从消息列表末尾向前查找，如果消息类型为error则删除，
  /// 如果找到服务器消息则返回并停止遍历和删除
  ///
  /// @return 找到的最后一条服务器消息，如果没有找到则返回null
  MsgData? findLastServerMsg() {
    // 从后向前遍历消息列表
    for (int i = list.length - 1; i >= 0; i--) {
      final msg = list[i];

      // 如果是错误消息，删除它
      if (msg.source == MsgSource.error) {
        list.removeAt(i);
        continue;
      }

      // 检查是否为服务器消息类型
      final source = msg.source;
      if (source == MsgSource.text ||
          source == MsgSource.video ||
          source == MsgSource.audio ||
          source == MsgSource.photo ||
          source == MsgSource.gift ||
          source == MsgSource.clothe) {
        return msg; // 找到服务器消息，返回并停止遍历
      }
    }
    return null;
  }

  /// 续写
  Future<void> continueWriting() async {
    try {
      final msg = list.last;
      bool canSend = await canSendMsg(msg.answer ?? '');
      if (!canSend) {
        return;
      }

      final charId = role.id;
      final conversationId = sessionId ?? 0;
      final uid = AppUser().user?.id;
      if (charId == null || uid == null || conversationId == 0) {
        FToast.toast(LocaleKeys.some_error_try_again.tr);
        return;
      }
      isRecieving = true;
      FLoading.showLoading();

      final url = '${AppService().baseUrl}${ApiPath.continueWrite}';
      final body = {'character_id': charId, 'conversation_id': conversationId, 'user_id': uid};
      startListening(url, body);
    } catch (e) {
      FToast.toast(LocaleKeys.some_error_try_again.tr);
    }
  }

  /// 重新发送消息
  Future<void> resendMsg(MsgData msg) async {
    try {
      MsgData? last = msg;
      if (msg.source == MsgSource.error) {
        last = findLastServerMsg();
      }
      if (last == null) {
        continueWriting();
        return;
      }

      bool canSend = await canSendMsg(last.answer ?? '');
      if (!canSend) {
        return;
      }

      final id = msg.id;
      if (id == null) {
        FToast.toast(LocaleKeys.some_error_try_again.tr);
        return;
      }

      final charId = role.id;
      final conversationId = sessionId ?? 0;
      final uid = AppUser().user?.id;
      if (charId == null || uid == null || conversationId == 0) {
        FToast.toast(LocaleKeys.some_error_try_again.tr);
        return;
      }
      FLoading.showLoading();
      isRecieving = true;

      final url = '${AppService().baseUrl}${ApiPath.resendMsg}';
      final body = {
        'character_id': charId,
        'conversation_id': conversationId,
        'user_id': uid,
        'msg_id': id,
      };
      startListening(url, body);
    } catch (e) {
      FLoading.dismiss();
      FToast.toast(LocaleKeys.some_error_try_again.tr);
    }
  }

  /// 编辑消息
  Future<void> editMsg(String content, MsgData msg) async {
    bool canSend = await canSendMsg(msg.answer ?? '');
    if (!canSend) {
      return;
    }
    FLoading.showLoading();
    isRecieving = true;
    final id = msg.id;
    if (id == null) {
      FToast.toast(LocaleKeys.some_error_try_again.tr);
      return;
    }
    var data = await Api.editMsg(id: id, text: content);
    if (data != null) {
      // 查找上一个 sendtext 消息  如果存在question一样的，将它删除
      MsgData? pre = list.firstWhereOrNull((element) => element.question == data.question);
      if (pre != null) {
        list.remove(pre);
      }
      // 替换就消息
      list.removeWhere((element) => element.id == id);
      list.add(data);
      AppUser().getUserInfo();
    }
    isRecieving = false;
    FLoading.dismiss();
  }

  /// 修改聊天场景
  Future<void> editScene(String scene) async {
    void request() async {
      final charId = role.id;
      final conversationId = sessionId ?? 0;
      if (charId == null || conversationId == 0) {
        FToast.toast(LocaleKeys.some_error_try_again.tr);
        return;
      }

      bool res = await Api.editScene(convId: conversationId, scene: scene, roleId: charId);
      if (res) {
        session.scene = scene;
        list.clear();
        _addDefaaultTips();
      }
      FLoading.dismiss();
    }

    AppDialog.alert(
      message: LocaleKeys.scenario_restart_warning.tr,
      cancelText: LocaleKeys.cancel.tr,
      confirmText: LocaleKeys.confirm.tr,
      onConfirm: () {
        AppDialog.dismiss();
        request();
      },
    );
  }

  /// 修改会话模式 聊天模型 short / long
  Future<void> editChatMode(bool isLong) async {
    final conversationId = sessionId ?? 0;
    if (conversationId == 0) {
      FToast.toast(LocaleKeys.some_error_try_again.tr);
      return;
    }

    var mode = isLong ? 'long' : 'short';
    if (session.chatModel == mode) {
      if (Get.isBottomSheetOpen == true) Get.back();
      return;
    }
    FLoading.showLoading();
    bool res = await Api.editChatMode(convId: conversationId, mode: mode);
    if (res) {
      session.chatModel = mode;
      if (Get.isBottomSheetOpen == true) Get.back();
    }
    FLoading.dismiss();
  }

  /// 切换 mask
  Future<bool> changeMask(int maskId) async {
    FLoading.showLoading();
    final conversationId = session.id;
    final res = await Api.changeMask(conversationId: conversationId, maskId: maskId);
    FLoading.dismiss();
    if (res) {
      session.profileId = maskId;
      list.clear();
      _addDefaaultTips();
      _addMaskTips();
    }
    return res;
  }

  void _addMaskTips() {
    final msg = MsgData();
    msg.source = MsgSource.maskTips;
    msg.answer = LocaleKeys.mask_applied.tr;
    list.add(msg);
  }
}
