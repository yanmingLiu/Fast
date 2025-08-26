import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:fast_ai/component/app_dialog.dart';
import 'package:fast_ai/component/f_toast.dart';
import 'package:fast_ai/data/msg_answer_data.dart';
import 'package:fast_ai/data/role_data.dart';
import 'package:fast_ai/generated/locales.g.dart';
import 'package:fast_ai/pages/router/app_router.dart';
import 'package:fast_ai/pages/router/routers.dart';
import 'package:fast_ai/services/api.dart';
import 'package:fast_ai/services/app_log_event.dart';
import 'package:fast_ai/services/app_service.dart';
import 'package:fast_ai/services/app_user.dart';
import 'package:fast_ai/tools/audio_tool.dart';
import 'package:fast_ai/tools/downloader.dart';
import 'package:fast_ai/tools/navigation_obs.dart';
import 'package:fast_ai/values/app_values.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:vibration/vibration.dart';

class PhoneCtr extends GetxController {
  bool _hasVideoPlayer = false;
  bool _showVideo = false;

  late int sessionId;
  late Role role;
  late CharacterVideoChat? guideVideo;
  late CharacterVideoChat? phoneVideo;

  final Rx<CallState> callState = CallState.calling.obs;
  final RxInt callDuration = 0.obs;
  final RxString lastWords = ''.obs;
  final RxBool showFormattedDuration = false.obs;
  var answerText = '';
  MsgAnswerData? messageReplyRsp;

  Timer? _callTimer;
  bool _isVibrating = false;
  Timer? _durationTimer;

  final SpeechToText _speech = SpeechToText();
  bool _hasSpeech = false;

  bool get _isVip => AppUser().isVip.value;

  @override
  void onInit() {
    super.onInit();

    _getArgs();
    _initSpeech();
  }

  @override
  void onClose() {
    _releaseResources();
    super.onClose();
  }

  void _getArgs() {
    final args = Get.arguments;
    _showVideo = args['showVideo'] ?? false;
    sessionId = args['sessionId'];
    role = args['role'];
    callState.value = args['callState'];

    phoneVideo = role.characterVideoChat?.firstWhereOrNull((e) => e.tag != 'guide');
    var url = phoneVideo?.url;
    if (url != null && url.isNotEmpty && _showVideo) {
      _hasVideoPlayer = true;
    }

    log.d('_hasVideoPlayer = $_hasVideoPlayer, showVideo = $_showVideo, url = $url');

    guideVideo = role.characterVideoChat?.firstWhereOrNull((e) => e.tag == 'guide');

    _handleCallState(callState.value);
  }

  void _handleCallState(CallState state) {
    log.d('_handleCallState state: $state');
    if (state == CallState.calling) {
      Future.delayed(const Duration(milliseconds: 1000), onTapCall);
    } else if (state == CallState.incoming) {
      _startCallTimer();
    }
  }

  String formattedDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  String callStateDescription(CallState callState) {
    switch (callState) {
      case CallState.calling:
      case CallState.listening:
        return LocaleKeys.listening.tr;
      case CallState.answering:
        return LocaleKeys.wait_for_response.tr;
      case CallState.answered:
        return answerText;
      default:
        return '';
    }
  }

  void onTapCall() async {
    log.d('onTapCall');
    await _deductGems();
    if (await _checkMicrophonePermission()) {
      HapticFeedback.selectionClick();
      _startCall();
    }
  }

  void onTapAccept() {
    _stopVibration();
    if (!_isVip) {
      logEvent('acceptcall');
      AppRouter.pushVip(VipFrom.acceptcall);
      return;
    }
    onTapCall();
  }

  Future<bool> _checkMicrophonePermission() async {
    if (await _speech.hasPermission) return true;

    AppDialog.alert(
      message: LocaleKeys.microphone_permission_required.tr,
      onConfirm: () async {
        await openAppSettings();
        onTapCall();
      },
      cancelText: LocaleKeys.cancel.tr,
      confirmText: LocaleKeys.open_settings.tr,
    );
    return false;
  }

  void _startCall() {
    log.d('_startCall');
    _callTimer?.cancel();
    _startDurationTimer();
    _startListening();
  }

  void onTapHangup() {
    log.d('onTapHangup');
    _stopVibration();
    Get.back();
  }

  void onTapMic(bool isOn) {
    if (callState.value == CallState.answering) return;

    HapticFeedback.selectionClick();
    if (isOn) {
      _startListening();
    } else {
      callState.value = CallState.micOff;
      _stopListening();
      log.d('lastWords: ${lastWords.value}');
    }
  }

  void _releaseResources() {
    log.d('_releaseResources');
    _speech
        .stop()
        .then((_) {
          _speech
              .cancel()
              .then((_) {
                log.d('Speech recognition stopped and cancelled');
                _callTimer?.cancel();
                _callTimer = null;
                _durationTimer?.cancel();
                _durationTimer = null;
                AudioTool().stopAll();
                Vibration.cancel();
                log.d('All resources released');
              })
              .catchError((error) {
                log.d('Error cancelling speech: $error');
              });
        })
        .catchError((error) {
          log.d('Error stopping speech: $error');
          FToast.toast(error.toString());
        });
  }

  void _startCallTimer() {
    log.d('_startCallTimer');
    _isVibrating = true;
    _callTimer = Timer(const Duration(seconds: 15), _onCallTimeout);

    _startVibration();
  }

  void _stopVibration() {
    _isVibrating = false;
  }

  Future<void> _startVibration() async {
    for (int i = 0; i < 20; i++) {
      // 20 * 500ms = 10s
      if (!_isVibrating) break;
      Vibration.vibrate(duration: 500);
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  void _onCallTimeout() {
    log.d('_onCallTimeout, callState: ${callState.value}, currentRoute: ${NavigationObs().curRoute?.settings.name}');
    _stopVibration();
    // Check if we're still on the phone route and in incoming state
    if (callState.value == CallState.incoming) {
      // Additional check to ensure we're on the correct page
      final currentRouteName = NavigationObs().curRoute?.settings.name;
      log.d('_onCallTimeout - current route: $currentRouteName, expected: ${Routers.phone}');
      
      if (currentRouteName == Routers.phone || currentRouteName == null) {
        // Even if we can't determine the route, if we're in incoming state for 15+ seconds,
        // we should probably hang up
        log.d('_onCallTimeout - calling onTapHangup()');
        onTapHangup();
      }
    }
  }

  void _startDurationTimer() {
    log.d('_startDurationTimer');
    showFormattedDuration.value = true;
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      callDuration.value++;
      // Check if a minute has passed
      if (callDuration.value % 60 == 0) {
        _deductGems();
      }
    });
  }

  Future<void> _deductGems() async {
    if (AppUser().isBalanceEnough(ConsumeFrom.call)) {
      AppUser().consume(ConsumeFrom.call);
    } else {
      SmartDialog.showToast(LocaleKeys.not_enough_coins.tr);
      Future.delayed(const Duration(milliseconds: 1000));
      onTapHangup();
    }
  }

  Future<void> _initSpeech() async {
    try {
      _hasSpeech = await _speech.initialize(
        onStatus: (status) => log.d('onStatus: $status'),
        onError: (error) {
          log.e('onError: $error');
          FToast.toast(error.toString());
        },
      );
    } catch (e) {
      _hasSpeech = false;
      log.d('initialize error: $e');
      SmartDialog.showToast(LocaleKeys.speech_recognition_not_supported.tr);
    }
  }

  void _startListening() async {
    log.d('startListening() -> _hasSpeech: $_hasSpeech');

    if (isClosed) {
      log.e('is closed');
      return;
    }

    if (!_hasSpeech) {
      log.d('Speech recognition not supported on this device.');
      SmartDialog.showToast(LocaleKeys.speech_recognition_not_supported.tr);
      onTapHangup();
      return;
    }

    callState.value = CallState.listening;
    answerText = '';
    lastWords.value = '';
    _listen();
  }

  void _stopListening() {
    log.d('_stopListening');
    _speech.stop();
  }

  Future<void> _listen() async {
    log.d('_listen');
    _speech.listen(
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      onResult: _onSpeechResult,
    );
  }

  void _onSpeechResult(SpeechRecognitionResult result) async {
    log.d('_onSpeechResult: ${result.recognizedWords} callState: ${callState.value}');

    if (result.finalResult && result.recognizedWords.trim().isNotEmpty) {
      lastWords.value = result.recognizedWords;
      if (callState.value == CallState.listening || callState.value == CallState.micOff) {
        _requestAnswer();
      }
    }
  }

  Future<void> _requestAnswer() async {
    callState.value = CallState.answering;

    _stopListening();
    log.d('_requestAnswer CallState: ${callState.value}');

    try {
      final msg = await _sendMessage();
      if (msg != null) {
        messageReplyRsp = msg;
        _playResponseAudio(msg);
      } else {
        SmartDialog.showToast(LocaleKeys.some_error_try_again.tr);
        _restartRecording();
      }
    } catch (e) {
      log.d('Error requesting answer: $e');
      SmartDialog.showToast(LocaleKeys.some_error_try_again.tr);
    }
  }

  Future<MsgAnswerData?> _sendMessage() async {
    log.d('_sendMessage: ${lastWords.value}');
    final roleId = role.id;
    var userId = AppUser().user?.id;
    var nickname = AppUser().user?.nickname;
    if (roleId == null || userId == null || nickname == null) {
      SmartDialog.showToast(LocaleKeys.some_error_try_again.tr);
      return null;
    }

    return await Api.sendVoiceChatMsg(
      userId: userId,
      nickName: nickname,
      message: lastWords.value,
      roleId: roleId,
    );
  }

  void _restartRecording() {
    log.d('_restartRecording');
    _startListening();
  }

  void _playResponseAudio(MsgAnswerData msg) async {
    log.d('_playResponseAudio');
    final url = msg.answer?.voiceUrl;
    if (url == null || url.isEmpty) {
      _playAudioFallback();
      return;
    }
    await Future.delayed(const Duration(seconds: 1));
    final file = await _downloadFileWithRetry(url, 5);
    if (file != null && file.path.isNotEmpty) {
      _playAudioFile(file.path, msg);
    } else {
      _playAudioFallback();
      log.d('Failed to download file after 5 attempts');
    }
  }

  void _playAudioFallback() {
    log.d('_playAudioFallback');
    answerText = messageReplyRsp?.answer?.content ?? '';
    Future.delayed(const Duration(seconds: 1), _restartRecording);
  }

  Future<File?> _downloadFileWithRetry(String url, int retries) async {
    File? file;
    for (int attempt = 1; attempt <= retries; attempt++) {
      try {
        file = await _downloadFile(url);
        log.d('_downloadFileWithRetry: ${file?.path}');
        if (file != null && file.path.isNotEmpty) {
          return file;
        }
      } catch (e) {
        log.d('_downloadFileWithRetry error: $e');
        SmartDialog.showToast(LocaleKeys.some_error_try_again.tr);
      }
    }
    return null;
  }

  Future<File?> _downloadFile(String url) async {
    final path = await Downloader.downloadFile(
      url,
      fileType: FileType.audio,
      fileExtension: '.mp3',
    );
    if (path == null || path.isEmpty) {
      return null;
    }
    return File(path);
  }

  void _playAudioFile(String path, MsgAnswerData msg) async {
    log.d('_playAudioFile: $path');

    final id = messageReplyRsp?.msgId;
    if (id != null) {
      answerText = messageReplyRsp?.answer?.content ?? '';

      callState.value = CallState.answered;

      await AudioTool().play(id, DeviceFileSource(path), stopAction: _stopPlayAnimation);
    }
  }

  void _stopPlayAnimation() {
    Future.delayed(const Duration(milliseconds: 1000), () {
      log.d('_stopPlayAnimation  callState: ${callState.value}');
      _startListening();
    });
  }
}
