import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

/// 列表数据请求
typedef RefreshablePagingRequest<T> =
    Future<List<T>> Function(int pageNum, int pageSize);

/// item构造器
typedef RefreshablePagingItemBuilder<T> =
    Widget Function(BuildContext context, T item, int index);

/// 空数据构造器
typedef RefreshablePagingEmptyBuilder = Widget Function(BuildContext context);

/// 列表头构造器
typedef RefreshablePagingHeaderBuilder =
    Widget Function(
      BuildContext context,
      int? total,
      int pageNum,
      int pageSize,
    );

/// 刷新控制器
class RefreshablePaingController<T> {
  RefreshablePaingController({
    this.controlFinishRefresh = false,
    this.controlFinishLoad = false,
  }) : _easyRefreshController = EasyRefreshController(
         controlFinishRefresh: controlFinishRefresh,
         controlFinishLoad: controlFinishLoad,
       );

  /// 是否可以控制刷新完成
  final bool controlFinishRefresh;

  /// 是否可以控制加载更多完成
  final bool controlFinishLoad;

  /// 刷新控制器
  final EasyRefreshController _easyRefreshController;
  EasyRefreshController get easyRefreshController => _easyRefreshController;

  BaseRefreshableWidgetState<T>? _state;

  /// 当前页码
  int? get currentPageNum => _state?.currentPageNum;

  /// 每页数量
  int? get pageSize => _state?.pageSize;

  /// 总数
  int? get totalCount => _state?.totalCount;

  /// 数据列表
  List<T>? get dataList => _state?.dataList;

  void _bind(BaseRefreshableWidgetState<T> state) {
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

  /// 控制加载更多
  Future<void> callLoad({bool force = false}) async {
    easyRefreshController.callLoad(force: force);
  }
}

/// 刷新组件抽象基类
///
/// 定义通用属性和方法
abstract class BaseRefreshableWidget<T> extends StatefulWidget {
  const BaseRefreshableWidget({
    super.key,
    required this.dataRequest,
    required this.itemBuilder,
    this.pageSize = 20,
    this.currentPageNum = 1,
    this.emptyBuilder,
    this.headerBuilder,
    this.controller,
    this.refreshOnStart = false,
  });

  /// 分页请求
  final RefreshablePagingRequest<T> dataRequest;

  /// item构造器
  final RefreshablePagingItemBuilder<T> itemBuilder;

  /// 每页数量
  final int pageSize;

  /// 当前页码
  final int currentPageNum;

  /// 空数据构造器
  final RefreshablePagingEmptyBuilder? emptyBuilder;

  /// 表头构造器
  final RefreshablePagingHeaderBuilder? headerBuilder;

  /// 控制器
  final RefreshablePaingController<T>? controller;

  /// 是否在初始化时自动刷新
  final bool refreshOnStart;
}

// 抽象状态类 - 定义通用状态和方法
abstract class BaseRefreshableWidgetState<T>
    extends State<BaseRefreshableWidget<T>> {
  /// 当前页码
  int currentPageNum = 1;

  /// 每页数量
  int pageSize = 20;

  /// 总数
  int? totalCount;

  /// 数据列表
  final List<T> dataList = [];

  /// 刷新控制器
  late final EasyRefreshController _easyRefreshController;

  /// 刷新方法 - 子类可以重写
  Future<void> _handleRefresh() async {
    currentPageNum = 1;

    try {
      List<T> result = await widget.dataRequest(currentPageNum, pageSize);
      if (mounted) {
        setState(() {
          dataList.clear();
          dataList.addAll(result);
        });
      }
      _easyRefreshController.finishRefresh();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('分页组件刷新失败: $e');
      }
      _easyRefreshController.finishRefresh(IndicatorResult.fail);
    }
  }

  /// 加载更多方法 - 子类可以重写
  Future<void> _handleLoadMore() async {
    try {
      List<T> result = await widget.dataRequest(currentPageNum + 1, pageSize);
      List<T> newDataList = result;
      if (newDataList.isEmpty) {
        _easyRefreshController.finishLoad(IndicatorResult.noMore);
      } else {
        if (mounted) {
          setState(() {
            dataList.addAll(newDataList);
            currentPageNum++;
          });
        }
        _easyRefreshController.finishLoad(
          newDataList.length < pageSize
              ? IndicatorResult.noMore
              : IndicatorResult.success,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('加载更多失败: $e');
      }
      _easyRefreshController.finishLoad(IndicatorResult.fail);
    }
  }

  /// 空数据构造器 - 子类可以重写
  Widget _buildEmptyWidget(BuildContext context) {
    return Container(
      color: Colors.transparent,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '暂无数据',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建列表内容 - 抽象方法，子类必须实现
  Widget buildListContent(BuildContext context);

  @override
  void initState() {
    super.initState();
    pageSize = widget.pageSize;
    currentPageNum = widget.currentPageNum;
    widget.controller?._bind(this);
    _easyRefreshController =
        widget.controller?.easyRefreshController ??
        EasyRefreshController(
          controlFinishRefresh: true,
          controlFinishLoad: true,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.headerBuilder?.call(
              context,
              totalCount,
              currentPageNum,
              pageSize,
            ) ??
            Container(),
        Expanded(
          child: EasyRefresh.builder(
            controller: _easyRefreshController,
            refreshOnStart: widget.refreshOnStart,
            onRefresh: _easyRefreshController.controlFinishRefresh
                ? _handleRefresh
                : null,
            onLoad: _easyRefreshController.controlFinishLoad
                ? _handleLoadMore
                : null,
            childBuilder: (context, physics) => CustomScrollView(
              physics: physics,
              slivers: [
                dataList.isEmpty
                    ? SliverFillRemaining(
                        child:
                            widget.emptyBuilder?.call(context) ??
                            _buildEmptyWidget(context),
                      )
                    : buildListContent(context),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// 列表组件
class RefreshablePagingList<T> extends BaseRefreshableWidget<T> {
  const RefreshablePagingList({
    super.key,
    required super.dataRequest,
    required super.itemBuilder,
    super.pageSize,
    super.currentPageNum,
    super.emptyBuilder,
    super.headerBuilder,
    super.controller,
    super.refreshOnStart,
    this.itemSpacing = 0,
    this.padding = EdgeInsets.zero,
  });

  /// 列表项间距
  final double itemSpacing;

  /// 列表内边距
  final EdgeInsets padding;

  @override
  BaseRefreshableWidgetState<T> createState() =>
      _RefreshablePagingListState<T>();
}

class _RefreshablePagingListState<T> extends BaseRefreshableWidgetState<T> {
  @override
  Widget buildListContent(BuildContext context) {
    return SliverPadding(
      padding: (widget as RefreshablePagingList<T>).padding,
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: index < dataList.length - 1
                  ? (widget as RefreshablePagingList<T>).itemSpacing
                  : 0,
            ),
            child: widget.itemBuilder(context, dataList[index], index),
          );
        }, childCount: dataList.length),
      ),
    );
  }
}

// 网格组件
class RefreshablePagingGrid<T> extends BaseRefreshableWidget<T> {
  const RefreshablePagingGrid({
    super.key,
    required super.dataRequest,
    required super.itemBuilder,
    super.pageSize,
    super.currentPageNum,
    super.emptyBuilder,
    super.headerBuilder,
    super.controller,
    super.refreshOnStart,
    this.crossAxisCount = 2,
    this.mainAxisSpacing = 8.0,
    this.crossAxisSpacing = 8.0,
    this.childAspectRatio = 1.0,
    this.padding = const EdgeInsets.all(16.0),
    this.isWaterfall = false,
  });

  /// 交叉轴数量
  final int crossAxisCount;

  /// 主轴间距
  final double mainAxisSpacing;

  /// 交叉轴间距
  final double crossAxisSpacing;

  /// 子项宽高比
  final double childAspectRatio;

  /// 内边距
  final EdgeInsets padding;

  /// 是否使用瀑布流布局
  final bool isWaterfall;

  @override
  BaseRefreshableWidgetState<T> createState() => _RefreshableGridState<T>();
}

class _RefreshableGridState<T> extends BaseRefreshableWidgetState<T> {
  @override
  Widget buildListContent(BuildContext context) {
    final gridWidget = widget as RefreshablePagingGrid<T>;

    if (gridWidget.isWaterfall) {
      return SliverPadding(
        padding: gridWidget.padding,
        sliver: SliverToBoxAdapter(
          child: WaterfallFlow.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: gridWidget.crossAxisCount,
            crossAxisSpacing: gridWidget.crossAxisSpacing,
            mainAxisSpacing: gridWidget.mainAxisSpacing,
            children: dataList
                .map(
                  (item) =>
                      widget.itemBuilder(context, item, dataList.indexOf(item)),
                )
                .toList(),
          ),
        ),
      );
    } else {
      return SliverPadding(
        padding: gridWidget.padding,
        sliver: SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: gridWidget.crossAxisCount,
            mainAxisSpacing: gridWidget.mainAxisSpacing,
            crossAxisSpacing: gridWidget.crossAxisSpacing,
            childAspectRatio: gridWidget.childAspectRatio,
          ),
          delegate: SliverChildBuilderDelegate((context, index) {
            return widget.itemBuilder(context, dataList[index], index);
          }, childCount: dataList.length),
        ),
      );
    }
  }
}
