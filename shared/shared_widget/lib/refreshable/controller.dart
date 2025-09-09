part of '../refreshable.dart';

/// 刷新控制器
class RefreshableController<T> {
  RefreshableController({
    this.controlFinishRefresh = false,
    this.controlFinishLoad = false,
  }) : easyRefreshcontroller = EasyRefreshController(
         controlFinishRefresh: controlFinishRefresh,
         controlFinishLoad: controlFinishLoad,
       );

  /// 是否可以控制刷新完成
  final bool controlFinishRefresh;

  /// 是否可以控制加载更多完成
  final bool controlFinishLoad;

  /// 刷新控制器
  final EasyRefreshController easyRefreshcontroller;

  _RefreshableListState<T>? _state;

  void _bind(_RefreshableListState<T> state) {
    _state = state;
  }

  void dispose() {
    easyRefreshcontroller.dispose();
    _state = null;
  }

  /// 控制刷新
  Future<void> callRefresh({bool force = false}) async {
    easyRefreshcontroller.callRefresh(force: force);
  }

  /// 控制加载更多
  Future<void> callLoad({bool force = false}) async {
    easyRefreshcontroller.callLoad(force: force);
  }
}

/// 列表刷新控制器
class RefreshableListController<T> extends RefreshableController<T> {
  RefreshableListController({
    super.controlFinishRefresh,
    super.controlFinishLoad,
  });

  /// 当前页码
  int get currentPageNum => _state?._currentPageNum ?? 1;

  /// 每页数量
  int get pageSize => _state?._pageSize ?? 20;

  /// 总数
  int? get totalCount => _state?._totalCount;

  /// 数据列表
  List<T>? get dataList => _state?._dataList;
}
