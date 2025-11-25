import 'package:fast_ai/component/f_loading.dart';
import 'package:fast_ai/data/msg_data.dart';
import 'package:fast_ai/gen/assets.gen.dart';
import 'package:fast_ai/generated/locales.g.dart';
import 'package:fast_ai/pages/chat/text_container.dart';
import 'package:fast_ai/pages/router/n_t_n.dart';
import 'package:fast_ai/services/audio_manager.dart';
import 'package:fast_ai/services/f_log_event.dart';
import 'package:fast_ai/services/m_y.dart';
import 'package:fast_ai/values/values.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

enum PlayState { downloading, playing, paused, stopped, error }

/// 音频容器组件
///
/// 功能特性：
/// - 支持音频播放、暂停、停止
/// - 使用全局AudioManager管理状态，解决ListView回收问题
/// - 自动下载和缓存音频文件
/// - 播放状态可视化动画
/// - VIP权限控制
/// - 错误处理和重试机制
/// - 性能优化和内存管理
class AudioContainer extends StatefulWidget {
  const AudioContainer({super.key, required this.msg});

  final MsgData msg;

  @override
  State<AudioContainer> createState() => _AudioContainerState();
}

class _AudioContainerState extends State<AudioContainer>
    with SingleTickerProviderStateMixin {
  /// 动画控制器
  AnimationController? _controller;

  /// 全局音频管理器
  late final AudioManager _audioManager;

  /// 消息ID，用作唯一标识
  late final String _msgId;

  @override
  void initState() {
    super.initState();
    _msgId = widget.msg.id.toString();
    _audioManager = AudioManager.instance;
    _initializeAnimationController();
    _checkRestoredPlayState();
  }

  /// 检查是否需要恢复播放状态
  void _checkRestoredPlayState() {
    try {
      debugPrint('🎧 AudioContainer: 检查恢复播放状态, msgId: $_msgId');

      // 检查全局管理器中的状态
      final audioState = _audioManager.getAudioState(_msgId);
      if (audioState?.state == AudioPlayState.playing) {
        debugPrint('🎧 AudioContainer: 恢复播放动画, msgId: $_msgId');
        _startPlayAnimation();
      }
    } catch (e) {
      debugPrint('⚠️ AudioContainer: 检查恢复状态异常: $e');
    }
  }

  /// 初始化动画控制器
  void _initializeAnimationController() {
    try {
      _controller = AnimationController(vsync: this);
      debugPrint('🎧 AudioContainer: 动画控制器初始化成功, msgId: $_msgId');
    } catch (e) {
      debugPrint('⚠️ AudioContainer: 动画控制器初始化失败: $e');
    }
  }

  @override
  void dispose() {
    debugPrint('🎧 AudioContainer: 组件销毁开始, msgId: $_msgId');
    _audioManager.stopAll();
    _cleanupResources();
    super.dispose();
  }

  /// 清理资源
  void _cleanupResources() {
    try {
      _controller?.dispose();
      debugPrint('🎧 AudioContainer: 资源清理完成, msgId: $_msgId');
    } catch (e) {
      debugPrint('⚠️ AudioContainer: 资源清理异常: $e');
    }
  }

  /// 构建音频UI组件 - 优化版本
  Widget _buildAudioUI() {
    return RepaintBoundary(
      child: ColorFiltered(
        colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
        child: Lottie.asset(
          Assets.lottie.audio,
          controller: _controller,
          fit: BoxFit.fill,
          onLoaded: (composition) {
            // 只设置动画持续时间，不控制播放
            _controller?.duration = composition.duration;
            debugPrint(
                '🎧 AudioContainer: Lottie动画加载完成, 动画时长: ${composition.duration}');
          },
          errorBuilder: (context, error, stackTrace) {
            debugPrint('⚠️ AudioContainer: Lottie加载失败: $error');
            return const Icon(Icons.audiotrack, color: Colors.white, size: 24);
          },
        ),
      ),
    );
  }

  /// 开始音频播放 - 使用全局管理器
  Future<void> _startAudioPlay() async {
    try {
      logEvent('c_news_voice');

      debugPrint('🎧 AudioContainer: 开始播放音频, msgId: $_msgId');
      await _audioManager.startPlay(_msgId, widget.msg.audioUrl);
    } catch (e) {
      debugPrint('⚠️ AudioContainer: 播放音频异常: $e');
    }
  }

  /// 停止音频播放 - 使用全局管理器
  Future<void> _stopAudioPlay() async {
    try {
      debugPrint('🎧 AudioContainer: 停止音频播放, msgId: $_msgId');
      await _audioManager.stopPlay(_msgId);
    } catch (e) {
      debugPrint('⚠️ AudioContainer: 停止音频播放异常: $e');
    }
  }

  /// 开始播放动画 - 根据音频状态循环播放
  void _startPlayAnimation() {
    if (!mounted) return;

    try {
      debugPrint('🎧 AudioContainer: 开始循环播放动画, msgId: $_msgId');
      // 直接循环播放动画，不设置固定时长
      _controller?.repeat();
    } catch (e) {
      debugPrint('⚠️ AudioContainer: 开始播放动画异常: $e');
    }
  }

  /// 停止播放动画 - 优化版本
  void _stopPlayAnimation() {
    try {
      if (mounted) {
        _controller?.stop();
        debugPrint('🎧 AudioContainer: 动画已停止, msgId: $_msgId');
      }
    } catch (e) {
      debugPrint('⚠️ AudioContainer: 停止动画异常: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Column(
        spacing: 8,
        children: [
          TextContainer(msg: widget.msg),
          Row(children: [_buildAudioWidget()]),
        ],
      ),
    );
  }

  /// 构建音频组件 - 优化版本
  Widget _buildAudioWidget() {
    final isRead = widget.msg.isRead;
    final isShowTrial = !MY().isVip.value;

    return GestureDetector(
      onTap: () => _handleAudioTap(isRead),
      child: Stack(
        alignment: Alignment.topLeft,
        children: [
          _buildAudioContainer(isShowTrial, isRead),
          _buildStatusTag()
        ],
      ),
    );
  }

  /// 构建音频容器
  Widget _buildAudioContainer(bool isShowTrial, bool isRead) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 200,
            height: 62,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0x80000000),
              borderRadius: BorderRadius.circular(16),
            ),
            child: _buildAudioUI(),
          ),
        ],
      ),
    );
  }

  /// 处理音频点击事件 - 使用全局管理器
  void _handleAudioTap(bool isRead) {
    try {
      final currentAudioState = _audioManager.getAudioState(_msgId);
      final currentState = currentAudioState?.state ?? AudioPlayState.stopped;

      debugPrint(
          '🎧 AudioContainer: 音频点击, msgId: $_msgId, 当前状态: $currentState');

      // VIP权限检查
      if (!MY().isVip.value) {
        debugPrint('🔒 AudioContainer: 非VIP用户，跳转到VIP页面');
        logEvent('c_news_lockaudio');
        NTN.pushVip(ProFrom.lockaudio);
        return;
      }

      // 根据当前状态决定操作
      switch (currentState) {
        case AudioPlayState.stopped:
        case AudioPlayState.paused:
        case AudioPlayState.error:
          _startAudioPlay();
          break;
        case AudioPlayState.playing:
        case AudioPlayState.downloading:
          _stopAudioPlay();
          break;
      }
    } catch (e) {
      debugPrint('⚠️ AudioContainer: 处理点击事件异常: $e');
    }
  }

  /// 构建状态标签 - 优化版本
  Widget _buildStatusTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF3F8DFD),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStatusIcon(),
          const SizedBox(width: 8),
          Text(LocaleKeys.moans_for_you.tr,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              )),
        ],
      ),
    );
  }

  /// 构建状态图标 - 使用全局管理器状态
  Widget _buildStatusIcon() {
    return Obx(() {
      final audioState = _audioManager.getAudioState(_msgId);
      final currentState = audioState?.state ?? AudioPlayState.stopped;

      // 同时监听全局播放状态变化，用于动画同步
      _audioManager.currentPlayingAudio.value;

      // 如果是当前正在播放的音频，开始动画
      if (currentState == AudioPlayState.playing &&
          _audioManager.currentPlayingAudio.value?.msgId == _msgId) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            debugPrint('🎧 AudioContainer: 触发播放动画, msgId: $_msgId');
            _startPlayAnimation();
          }
        });
      } else if (currentState != AudioPlayState.playing) {
        // 如果不是播放状态，停止动画
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _stopPlayAnimation();
          }
        });
      }

      switch (currentState) {
        case AudioPlayState.downloading:
          return _buildLoadingIcon();
        case AudioPlayState.playing:
          return _buildPlayingIcon();
        case AudioPlayState.error:
          return _buildErrorIcon();
        default:
          return _buildPausedIcon();
      }
    });
  }

  /// 构建加载图标
  Widget _buildLoadingIcon() {
    return SizedBox(width: 20, height: 20, child: FLoading.loadingWidget());
  }

  /// 构建播放图标
  Widget _buildPlayingIcon() {
    return Assets.images.voiceing.image(width: 20);
  }

  /// 构建暂停图标
  Widget _buildPausedIcon() {
    return Assets.images.audioPause.image(width: 20);
  }

  /// 构建错误图标
  Widget _buildErrorIcon() {
    return Icon(
      Icons.error_outline,
      color: Colors.red,
      size: 20,
      semanticLabel: 'try again',
    );
  }
}
