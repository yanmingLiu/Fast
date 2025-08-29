import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:fast_ai/tools/audio_tool.dart';
import 'package:fast_ai/tools/downloader.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

/// 音频播放状态枚举
enum AudioPlayState {
  stopped, // 停止
  downloading, // 下载中
  playing, // 播放中
  paused, // 暂停
  error, // 错误
}

/// 音频状态信息
class AudioStateInfo {
  final String msgId;
  final AudioPlayState state;
  final String? filePath;
  final int audioDuration;
  final String? errorMessage;

  AudioStateInfo({
    required this.msgId,
    required this.state,
    this.filePath,
    required this.audioDuration,
    this.errorMessage,
  });

  AudioStateInfo copyWith({
    String? msgId,
    AudioPlayState? state,
    String? filePath,
    int? audioDuration,
    String? errorMessage,
  }) {
    return AudioStateInfo(
      msgId: msgId ?? this.msgId,
      state: state ?? this.state,
      filePath: filePath ?? this.filePath,
      audioDuration: audioDuration ?? this.audioDuration,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// 全局音频管理器 - 优化版本，与AudioTool协作
///
/// 功能特性：
/// - 单例模式，全局统一管理音频播放状态
/// - 与AudioTool协作，职责分离更清晰
/// - 防止ListView回收导致音频中断
/// - 自动下载和缓存音频文件
/// - 完善的错误处理和重试机制
/// - 文件完整性验证
/// - 音频时长动态获取
class AudioManager extends GetxController {
  static AudioManager? _instance;

  /// 获取单例实例
  static AudioManager get instance {
    _instance ??= AudioManager._internal();
    return _instance!;
  }

  AudioManager._internal();

  // ==================== 状态管理 ====================

  /// 音频播放器
  AudioPlayer? _audioPlayer;

  /// 所有音频状态映射 msgId -> AudioStateInfo
  final RxMap<String, AudioStateInfo> _audioStates = <String, AudioStateInfo>{}.obs;

  /// 当前正在播放的音频信息
  final Rx<AudioStateInfo?> currentPlayingAudio = Rx<AudioStateInfo?>(null);

  /// 播放器状态订阅
  StreamSubscription<PlayerState>? _playerStateSubscription;

  /// 重试次数映射
  final Map<String, int> _retryCount = {};

  /// 最大重试次数
  static const int _maxRetryCount = 1;

  /// 下载超时时间
  static const int _downloadTimeoutSeconds = 30;

  /// 播放超时时间
  static const int _playTimeoutSeconds = 5;

  @override
  void onInit() {
    super.onInit();
    _initializeAudioManager();
    debugPrint('🎧 AudioManager: 全局音频管理器初始化完成');
  }

  /// 初始化音频管理器
  Future<void> _initializeAudioManager() async {
    try {
      // 使用AudioTool初始化全局音频配置
      await AudioTool.initAudioPlayer();

      // 初始化当前管理器的音频播放器
      await _initializeAudioPlayer();

      debugPrint('🎧 AudioManager: 音频管理器初始化成功');
    } catch (e) {
      debugPrint('⚠️ AudioManager: 音频管理器初始化失败: $e');
    }
  }

  @override
  void onClose() {
    _cleanupResources();
    super.onClose();
  }

  /// 初始化音频播放器
  Future<void> _initializeAudioPlayer() async {
    try {
      // 使用AudioTool创建配置好的播放器
      _audioPlayer = await AudioTool.createAudioPlayer('global_audio_manager');

      // 监听播放器状态变化
      _playerStateSubscription = _audioPlayer!.onPlayerStateChanged.listen(
        _handlePlayerStateChanged,
        onError: (error) {
          debugPrint('⚠️ AudioManager: 播放器状态监听错误: $error');
        },
      );

      debugPrint('🎧 AudioManager: 音频播放器初始化成功');
    } catch (e) {
      debugPrint('⚠️ AudioManager: 音频播放器初始化失败: $e');
    }
  }

  /// 处理播放器状态变化
  void _handlePlayerStateChanged(PlayerState state) {
    final currentAudio = currentPlayingAudio.value;
    if (currentAudio == null) return;

    debugPrint('🎧 AudioManager: 播放器状态变化: $state');

    switch (state) {
      case PlayerState.completed:
        debugPrint('🎧 AudioManager: 音频播放完成, msgId: ${currentAudio.msgId}');
        _updateAudioState(currentAudio.msgId, AudioPlayState.stopped);
        currentPlayingAudio.value = null;
        break;
      case PlayerState.stopped:
        debugPrint('🎧 AudioManager: 音频播放停止, msgId: ${currentAudio.msgId}');
        _updateAudioState(currentAudio.msgId, AudioPlayState.stopped);
        currentPlayingAudio.value = null;
        break;
      default:
        break;
    }
  }

  // ==================== 公共接口 ====================

  /// 开始播放音频
  Future<void> startPlay(String msgId, String? audioUrl) async {
    try {
      debugPrint('🎧 AudioManager: 开始播放音频, msgId: $msgId');

      // 验证参数
      if (audioUrl == null || audioUrl.isEmpty) {
        debugPrint('⚠️ AudioManager: 音频URL为空，无法播放');
        _updateAudioState(msgId, AudioPlayState.error, errorMessage: '音频URL为空');
        return;
      }

      // 停止其他正在播放的音频
      await _stopCurrentAudio();

      // 更新状态为下载中（不设置时长，等待实际获取）
      _updateAudioState(msgId, AudioPlayState.downloading);

      // 下载音频文件
      String? downloadedFilePath = await _downloadAudioWithRetry(msgId, audioUrl);
      if (downloadedFilePath == null) {
        _updateAudioState(msgId, AudioPlayState.error, errorMessage: '下载失败');
        return;
      }

      debugPrint('🎧 AudioManager: 音频下载成功, 路径: $downloadedFilePath');

      // 获取实际音频时长
      int currentDuration = await _getAudioDuration(downloadedFilePath);
      debugPrint('🎧 AudioManager: 获取实际音频时长: $currentDuration ms');

      // 验证文件完整性
      if (!await _validateAudioFile(downloadedFilePath, currentDuration)) {
        debugPrint('⚠️ AudioManager: 音频文件验证失败，强制重新下载');
        // 删除不完整的文件
        final file = File(downloadedFilePath);
        if (await file.exists()) {
          await file.delete();
          debugPrint('🎧 AudioManager: 已删除不完整的缓存文件');
        }

        // 等待片刻后重新下载
        await Future.delayed(Duration(milliseconds: 500));

        // 重新下载
        downloadedFilePath = await _downloadAudioWithRetry(msgId, audioUrl, forceRedownload: true);
        if (downloadedFilePath == null) {
          _updateAudioState(msgId, AudioPlayState.error, errorMessage: '重新下载失败');
          return;
        }

        currentDuration = await _getAudioDuration(downloadedFilePath);
        debugPrint('🎧 AudioManager: 重新下载后时长: $currentDuration ms');

        // 再次验证
        if (!await _validateAudioFile(downloadedFilePath, currentDuration)) {
          debugPrint('⚠️ AudioManager: 重新下载后仍然验证失败，可能是服务器文件问题');
          _updateAudioState(msgId, AudioPlayState.error, errorMessage: '文件仍然不完整');
          return;
        }
      }

      // 开始播放
      await _playAudioFile(msgId, downloadedFilePath, currentDuration);
    } catch (e) {
      debugPrint('⚠️ AudioManager: 播放音频异常: $e');
      _updateAudioState(msgId, AudioPlayState.error, errorMessage: e.toString());
    }
  }

  /// 停止播放指定音频
  Future<void> stopPlay(String msgId) async {
    try {
      debugPrint('🎧 AudioManager: 停止播放音频, msgId: $msgId');

      final currentAudio = currentPlayingAudio.value;
      if (currentAudio?.msgId == msgId) {
        await _audioPlayer?.stop();
        currentPlayingAudio.value = null;
      }

      _updateAudioState(msgId, AudioPlayState.stopped);
    } catch (e) {
      debugPrint('⚠️ AudioManager: 停止播放异常: $e');
    }
  }

  /// 停止所有音频播放
  Future<void> stopAll() async {
    try {
      debugPrint('🎧 AudioManager: 停止所有音频播放');
      await _audioPlayer?.stop();
      currentPlayingAudio.value = null;

      // 更新所有状态为停止
      for (final msgId in _audioStates.keys) {
        final audioState = _audioStates[msgId];
        if (audioState?.state == AudioPlayState.playing) {
          _updateAudioState(msgId, AudioPlayState.stopped);
        }
      }
    } catch (e) {
      debugPrint('⚠️ AudioManager: 停止所有播放异常: $e');
    }
  }

  /// 获取音频状态
  AudioStateInfo? getAudioState(String msgId) {
    return _audioStates[msgId];
  }

  // ==================== 私有方法 ====================

  /// 停止当前播放的音频
  Future<void> _stopCurrentAudio() async {
    final currentAudio = currentPlayingAudio.value;
    if (currentAudio != null) {
      debugPrint('🎧 AudioManager: 停止当前音频, msgId: ${currentAudio.msgId}');
      await _audioPlayer?.stop();
      _updateAudioState(currentAudio.msgId, AudioPlayState.stopped);
      currentPlayingAudio.value = null;
    }
  }

  /// 下载音频文件（带重试）
  Future<String?> _downloadAudioWithRetry(
    String msgId,
    String audioUrl, {
    bool forceRedownload = false,
  }) async {
    final retryKey = msgId;
    _retryCount[retryKey] = _retryCount[retryKey] ?? 0;

    while (_retryCount[retryKey]! < _maxRetryCount) {
      try {
        debugPrint('🎧 AudioManager: 开始下载音频, URL: $audioUrl');

        // 如果需要强制重新下载，先删除已存在的文件
        if (forceRedownload) {
          final fileName = Downloader.generateFileNameFromUrl(audioUrl);
          final docDir = await getApplicationDocumentsDirectory();
          final folderPath = path.join(docDir.path, 'audios_files');
          final existingFilePath = path.join(folderPath, fileName);
          final existingFile = File(existingFilePath);
          if (await existingFile.exists()) {
            await existingFile.delete();
            debugPrint('🎧 AudioManager: 已删除旧缓存文件: $existingFilePath');
          }
        }

        final filePath = await Downloader.downloadFile(audioUrl, fileType: FileType.audio).timeout(
          Duration(seconds: _downloadTimeoutSeconds),
          onTimeout: () =>
              throw TimeoutException('下载超时', Duration(seconds: _downloadTimeoutSeconds)),
        );

        if (filePath != null && await File(filePath).exists()) {
          _retryCount.remove(retryKey); // 清除重试次数
          return filePath;
        } else {
          throw Exception('下载返回空路径或文件不存在');
        }
      } catch (e) {
        _retryCount[retryKey] = _retryCount[retryKey]! + 1;
        debugPrint('⚠️ AudioManager: 下载失败 (${_retryCount[retryKey]}/$_maxRetryCount): $e');

        if (_retryCount[retryKey]! >= _maxRetryCount) {
          _retryCount.remove(retryKey);
          break;
        }

        // 等待后重试
        await Future.delayed(Duration(seconds: _retryCount[retryKey]!));
      }
    }

    return null;
  }

  /// 获取音频时长 - 使用AudioTool
  Future<int> _getAudioDuration(String filePath) async {
    try {
      final source = DeviceFileSource(filePath);
      final duration = await AudioTool.getAudioDuration(source);

      if (duration != null) {
        return duration.inMilliseconds;
      } else {
        debugPrint('⚠️ AudioManager: 无法获取音频时长');
        return 0;
      }
    } catch (e) {
      debugPrint('⚠️ AudioManager: 获取音频时长异常: $e');
      return 0;
    }
  }

  /// 验证音频文件完整性
  Future<bool> _validateAudioFile(String filePath, int duration) async {
    try {
      final file = File(filePath);

      // 检查文件是否存在
      if (!await file.exists()) {
        debugPrint('⚠️ AudioManager: 音频文件不存在: $filePath');
        return false;
      }

      // 检查文件大小（小于1KB可能是不完整的）
      final fileSize = await file.length();
      if (fileSize < 1024) {
        debugPrint('⚠️ AudioManager: 音频文件过小: ${fileSize}B');
        return false;
      }

      // 检查时长合理性（小于1秒可能有问题）
      if (duration < 1000) {
        debugPrint('⚠️ AudioManager: 音频时长过短: ${duration}ms');
        return false;
      }

      // 特别针对用户反馈的问题：如果时长在5-15秒范围内，很可能是不完整的缓存
      // 因为用户报告实际应该是1分51秒（111秒），但获取到的是8秒
      if (duration >= 5000 && duration <= 15000) {
        debugPrint('⚠️ AudioManager: 检测到可疑的短时长: ${duration}ms，可能是不完整的缓存文件');

        // 进一步检查：文件大小应该与时长成正比
        // 一般音频文件，每秒大约需要8-32KB（取决于比特率）
        final expectedMinSize = (duration / 1000) * 8 * 1024; // 最低8KB/秒
        if (fileSize < expectedMinSize) {
          debugPrint(
            '⚠️ AudioManager: 文件大小与时长不匹配，文件大小: ${fileSize}B, 预期最小: ${expectedMinSize.toInt()}B',
          );
          return false;
        }
      }

      debugPrint('🎧 AudioManager: 音频文件验证通过, 文件大小: ${fileSize}B, 时长: ${duration}ms');
      return true;
    } catch (e) {
      debugPrint('⚠️ AudioManager: 验证音频文件异常: $e');
      return false;
    }
  }

  /// 播放音频文件
  Future<void> _playAudioFile(String msgId, String filePath, int duration) async {
    try {
      debugPrint('🎧 AudioManager: 开始播放音频文件, msgId: $msgId, 路径: $filePath, duration: $duration');

      if (_audioPlayer == null) {
        throw Exception('音频播放器未初始化');
      }

      // 更新状态为正在播放
      final audioState = AudioStateInfo(
        msgId: msgId,
        state: AudioPlayState.playing,
        filePath: filePath,
        audioDuration: duration,
      );

      _audioStates[msgId] = audioState;
      currentPlayingAudio.value = audioState;

      // 触发状态更新
      _audioStates.refresh();

      // 开始播放
      await _audioPlayer!
          .play(DeviceFileSource(filePath))
          .timeout(
            Duration(seconds: _playTimeoutSeconds),
            onTimeout: () => throw TimeoutException('播放超时', Duration(seconds: _playTimeoutSeconds)),
          );
    } catch (e) {
      debugPrint('⚠️ AudioManager: 播放音频文件异常: $e');
      _updateAudioState(msgId, AudioPlayState.error, errorMessage: e.toString());
      currentPlayingAudio.value = null;
    }
  }

  /// 更新音频状态
  void _updateAudioState(
    String msgId,
    AudioPlayState state, {
    String? filePath,
    int? audioDuration,
    String? errorMessage,
  }) {
    final currentState = _audioStates[msgId];

    final newState = AudioStateInfo(
      msgId: msgId,
      state: state,
      filePath: filePath ?? currentState?.filePath,
      audioDuration: audioDuration ?? currentState?.audioDuration ?? 0,
      errorMessage: errorMessage,
    );

    _audioStates[msgId] = newState;
    debugPrint('🎧 AudioManager: 音频状态更新, msgId: $msgId, state: $state');
  }

  /// 清理资源
  void _cleanupResources() {
    try {
      _playerStateSubscription?.cancel();
      _audioPlayer?.dispose();
      _audioStates.clear();
      currentPlayingAudio.value = null;
      _retryCount.clear();
      debugPrint('🎧 AudioManager: 资源清理完成');
    } catch (e) {
      debugPrint('⚠️ AudioManager: 资源清理异常: $e');
    }
  }
}
