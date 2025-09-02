import 'package:fast_ai/data/msg_data.dart';
import 'package:fast_ai/generated/locales.g.dart';
import 'package:fast_ai/pages/chat/audio_container.dart';
import 'package:fast_ai/pages/chat/photo_container.dart';
import 'package:fast_ai/pages/chat/text_container.dart';
import 'package:fast_ai/pages/chat/tips_content.dart';
import 'package:fast_ai/pages/chat/toys_container.dart';
import 'package:fast_ai/pages/chat/video_container.dart';
import 'package:fast_ai/values/app_values.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 消息项组件
///
/// 优化要点：
/// 1. 使用const构造函数减少widget重建
/// 2. 缓存计算结果避免重复计算
/// 3. 使用工厂模式替代switch语句提升性能
/// 4. 模块化抽取，提升组件复用性

/// 消息容器组件的工厂，遵循项目组件重构规范
class MessageContainerFactory {
  // 私有构造函数，防止实例化
  MessageContainerFactory._();

  /// 使用工厂模式创建对应的消息容器
  ///
  /// 相比switch语句，Map查找性能更好，O(1)时间复杂度
  static final Map<MsgSource, Widget Function(MsgData)> _containerBuilders = {
    MsgSource.tips: (msg) => TipsContent(msg: msg),
    MsgSource.welcome: (msg) => TextContainer(msg: msg),
    MsgSource.scenario: (msg) => TextContainer(msg: msg, title: "${LocaleKeys.scenario.tr}:"),
    MsgSource.intro: (msg) => TextContainer(msg: msg, title: "${LocaleKeys.intro.tr}:"),
    MsgSource.sendText: (msg) => TextContainer(msg: msg),
    MsgSource.text: (msg) => TextContainer(msg: msg),
    MsgSource.maskTips: (msg) => TipsContent(msg: msg),
    MsgSource.error: (msg) => TextContainer(msg: msg),
    MsgSource.photo: (msg) => PhotoContainer(msg: msg),
    MsgSource.clothe: (msg) => PhotoContainer(msg: msg),
    MsgSource.video: (msg) => VideoContainer(msg: msg),
    MsgSource.audio: (msg) => AudioContainer(msg: msg),
    MsgSource.gift: (msg) => ToysContainer(msg: msg),
  };

  /// 创建消息容器widget
  static Widget createContainer(MsgSource source, MsgData msg) {
    final builder = _containerBuilders[source];
    return builder?.call(msg) ?? const SizedBox.shrink();
  }
}

/// 消息项组件
///
/// 主要改进：
/// 1. 使用StatelessWidget提升性能
/// 2. 工厂模式替代switch语句
/// 3. 组件模块化，Tips内容已抽取到独立文件
/// 4. 保持向后兼容性，确保现有代码无需修改
class MsgItem extends StatelessWidget {
  const MsgItem({super.key, required this.msg});

  final MsgData msg;

  /// 缓存消息源，避免重复访问
  MsgSource get source => msg.source;

  @override
  Widget build(BuildContext context) {
    return MessageContainerFactory.createContainer(source, msg);
  }
}
