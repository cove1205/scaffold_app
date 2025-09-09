part of '../refreshable.dart';

/// 请求
typedef RefreshRequest = FutureOr<dynamic> Function()?;

class RefreshableWidget extends StatelessWidget {
  const RefreshableWidget(
      {super.key,
      required this.onRefresh,
      required this.child,
      this.refreshOnStart = true,
      this.controller});

  final RefreshRequest onRefresh;
  final Widget child;
  final bool refreshOnStart;
  final RefreshableController? controller;

  /// 刷新
  Future<void> _handleRefresh() async {
    try {
      await onRefresh?.call();

      controller?.easyRefreshcontroller.finishRefresh();
    } catch (e) {
      // 记录错误日志
      if (kDebugMode) {
        debugPrint('刷新失败: $e');
      }
      controller?.easyRefreshcontroller.finishRefresh(IndicatorResult.fail);
    }
  }

  @override
  Widget build(BuildContext context) {
    return EasyRefresh.builder(
      controller: controller?.easyRefreshcontroller ??
          EasyRefreshController(
              controlFinishRefresh: true, controlFinishLoad: false),
      refreshOnStart: refreshOnStart,
      onRefresh: _handleRefresh,
      childBuilder: (context, physics) =>
          SingleChildScrollView(physics: physics, child: child),
    );
  }
}
