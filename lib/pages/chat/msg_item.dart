import 'package:fast_ai/data/msg_data.dart';
import 'package:fast_ai/generated/locales.g.dart';
import 'package:fast_ai/pages/chat/audio_container.dart';
import 'package:fast_ai/pages/chat/photo_container.dart';
import 'package:fast_ai/pages/chat/text_container.dart';
import 'package:fast_ai/pages/chat/tips_content.dart';
import 'package:fast_ai/pages/chat/toys_container.dart';
import 'package:fast_ai/pages/chat/video_container.dart';
import 'package:fast_ai/values/values.dart';
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
  static final Map<MsgType, Widget Function(MsgData)> _containerBuilders = {
    MsgType.tips: (msg) => TipsContent(msg: msg),
    MsgType.maskTips: (msg) => TipsContent(msg: msg),
    MsgType.error: (msg) => TipsContent(msg: msg),
    MsgType.welcome: (msg) => TextContainer(msg: msg),
    MsgType.scenario: (msg) =>
        TextContainer(msg: msg, title: "${LocaleKeys.scenario.tr}:"),
    MsgType.intro: (msg) =>
        TextContainer(msg: msg, title: "${LocaleKeys.intro.tr}:"),
    MsgType.sendText: (msg) => TextContainer(msg: msg),
    MsgType.text: (msg) => TextContainer(msg: msg),
    MsgType.photo: (msg) => PhotoContainer(msg: msg),
    MsgType.clothe: (msg) => PhotoContainer(msg: msg),
    MsgType.video: (msg) => VideoContainer(msg: msg),
    MsgType.audio: (msg) => AudioContainer(msg: msg),
    MsgType.gift: (msg) => ToysContainer(msg: msg),
  };

  /// 创建消息容器widget
  static Widget createContainer(MsgType source, MsgData msg) {
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
  MsgType get source => msg.source;

  @override
  Widget build(BuildContext context) {
    return MessageContainerFactory.createContainer(source, msg);
  }
}
