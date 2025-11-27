import 'package:flutter/material.dart';

/// 页面状态保持包装器
class FKeepAlive extends StatefulWidget {
  final bool keepAlive;
  final Widget child;

  const FKeepAlive({super.key, required this.child, this.keepAlive = true});

  @override
  State<StatefulWidget> createState() => _FKeepAliveState();
}

class _FKeepAliveState extends State<FKeepAlive>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }

  @override
  bool get wantKeepAlive => widget.keepAlive;

  @override
  void didUpdateWidget(covariant FKeepAlive oldWidget) {
    // 状态发生变化时调用
    if (oldWidget.keepAlive != widget.keepAlive) {
      // 更新 KeepAlive 状态
      updateKeepAlive();
    }

    super.didUpdateWidget(oldWidget);
  }
}
