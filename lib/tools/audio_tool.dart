import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

//终止操作，播放下一个，上一个会被迫终止
typedef StopAction = void Function();

class AudioTool {
  static final AudioTool _instance = AudioTool._internal();

  AudioTool._internal();

  factory AudioTool() {
    return _instance;
  }

  AudioContext? audioContextDefault;

  var players = <String, AudioPlayer>{};

  StopAction? _stopAction;

  final _subscriptions = <StreamSubscription>[];

  void initAudioPlayer() {
    _setupSpeaker();
  }

  String audioTimer(int value) {
    int hours = value ~/ 3600;
    int minutes = (value % 3600) ~/ 60;
    int seconds = value % 60;

    // 使用 StringBuffer 构建字符串
    final str = StringBuffer();

    if (hours > 0) {
      str.write('${hours}h');
    }

    // 格式化分钟和秒，确保两位数显示
    str.write('${minutes.toString().padLeft(2, '0')}’');
    str.write('${seconds.toString().padLeft(2, '0')}’’');

    return str.toString();
  }

  //初始化设置播放器属性
  void _setupSpeaker() async {
    audioContextDefault = await _getAudioContext();
    await AudioPlayer.global.setAudioContext(audioContextDefault!);
  }

  //获取播放器属性
  Future<AudioContext> _getAudioContext() async {
    bool isSpeakerphoneOn = true;

    return AudioContext(
      android: AudioContextAndroid(
        usageType: AndroidUsageType.media,
        audioMode: AndroidAudioMode.normal,
        isSpeakerphoneOn: isSpeakerphoneOn,
      ),
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.playback,
        options: const {AVAudioSessionOptions.mixWithOthers},
      ),
    );
  }

  Future<bool> play(
    String id,
    Source source, {
    required StopAction stopAction,
    double? volume,
    double? balance,
    AudioContext? ctx,
    Duration? position,
    PlayerMode? mode,
  }) async {
    _setupSpeaker();
    //回掉之前的停止操作
    _stopAction?.call();

    //构建新的播放器
    if (players[id] == null) {
      players[id] = AudioPlayer(playerId: id);
    }
    //移除之前的播放器
    players.forEach((key, value) async {
      if (key != id) {
        await value.dispose();
      }
    });
    _cancelSubscription();
    players.removeWhere((key, value) => key != id);
    //使用默认的context
    var audioContext = ctx ?? audioContextDefault;

    _stopAction = stopAction;
    var audioPlayer = players[id];
    _addSubscription(
      audioPlayer!.onPlayerStateChanged.listen((event) {
        debugPrint('onPlayerStateChanged: $event');
        if (event == PlayerState.stopped || event == PlayerState.completed) {
          _stopAction?.call();
          _stopAction = null;
        }
      }),
    );

    try {
      await audioPlayer.play(
        source,
        volume: volume,
        balance: balance,
        ctx: audioContext,
        position: position,
        mode: mode,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  bool isPlaying(String playerId) {
    return players[playerId]?.state == PlayerState.playing;
  }

  Future<Duration?> getCurrentPosition(String playerId) async {
    if (players[playerId]?.state == PlayerState.playing) {
      return players[playerId]!.getCurrentPosition();
    }
    return null;
  }

  void stop(String id) {
    players[id]?.stop();
  }

  void stopAll() {
    for (var player in players.values) {
      player.stop();
    }
  }

  void _addSubscription(StreamSubscription streamSubscription) {
    _subscriptions.add(streamSubscription);
  }

  void _cancelSubscription() {
    if (_subscriptions.isNotEmpty) {
      for (var value in _subscriptions) {
        value.cancel();
      }
      _subscriptions.clear();
    }
  }

  void release() {
    players.forEach((key, value) {
      value.dispose();
    });
    players.clear();
    _stopAction = null;
    _cancelSubscription();
  }
}
