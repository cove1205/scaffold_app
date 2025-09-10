import 'dart:async';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 数据请求
typedef RefreshableRequest<T> = FutureOr<T> Function()?;

/// item构造器
typedef RefreshableBuilder<T> = Widget Function(BuildContext context, T data);

/// 空数据构造器
typedef RefreshableEmptyBuilder = Widget Function(BuildContext context);

/// 刷新控制器
class RefreshableController<T> {
  RefreshableController()
    : _easyRefreshController = EasyRefreshController(
        controlFinishRefresh: true,
        controlFinishLoad: false,
      );

  /// 刷新控制器
  final EasyRefreshController _easyRefreshController;
  EasyRefreshController get easyRefreshController => _easyRefreshController;

  _RefreshableWidgetState<T>? _state;

  /// 数据
  T? get data => _state?.data;

  void _bind(_RefreshableWidgetState<T> state) {
    _state = state;
  }

  void dispose() {
    easyRefreshController.dispose();
    _state = null;
  }

  /// 控制刷新
  Future<void> callRefresh({bool force = false}) async {
    easyRefreshController.callRefresh(force: force);
  }
}

class RefreshableWidget<T> extends StatefulWidget {
  const RefreshableWidget({
    super.key,
    required this.onRefresh,
    required this.childBuilder,
    this.refreshOnStart = true,
    this.controller,
    this.emptyBuilder,
  });

  final RefreshableRequest<T> onRefresh;
  final RefreshableBuilder<T> childBuilder;
  final bool refreshOnStart;
  final RefreshableController<T>? controller;
  final RefreshableEmptyBuilder? emptyBuilder;

  @override
  State<RefreshableWidget> createState() => _RefreshableWidgetState();
}

class _RefreshableWidgetState<T> extends State<RefreshableWidget<T>> {
  T? data;

  @override
  void initState() {
    super.initState();
    widget.controller?._bind(this);
  }

  /// 刷新
  Future<void> _handleRefresh() async {
    try {
      T? data = await widget.onRefresh?.call();
      if (mounted) {
        setState(() {
          this.data = data;
        });
      }

      widget.controller?.easyRefreshController.finishRefresh();
    } catch (e) {
      // 记录错误日志
      if (kDebugMode) {
        debugPrint('刷新失败: $e');
      }
      widget.controller?.easyRefreshController.finishRefresh(
        IndicatorResult.fail,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return EasyRefresh.builder(
      controller: widget.controller?.easyRefreshController,
      refreshOnStart: widget.refreshOnStart,
      onRefresh: _handleRefresh,
      childBuilder: (context, physics) => data != null
          ? widget.childBuilder(context, data as T)
          : widget.emptyBuilder?.call(context) ?? Container(),
    );
  }
}
