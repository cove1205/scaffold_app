part of '../refreshable.dart';

/// 请求
typedef DataRequest<T> = Future<List<T>> Function(int pageNum, int pageSize);

/// item构造器
typedef RefreshableListItemBuilder<T> =
    Widget Function(BuildContext context, T item, int index);

/// 空数据构造器
typedef EmptyItemBuilder = Widget Function(BuildContext context);

/// 列表头构造器
typedef HeaderBuilder =
    Widget Function(
      BuildContext context,
      int? total,
      int pageNum,
      int pageSize,
    );

/// 刷新列表
class RefreshableList<T> extends StatefulWidget {
  const RefreshableList({
    super.key,
    required this.dataRequest,
    required this.itemBuilder,
    this.pageSize = 20,
    this.currentPageNum = 1,
    this.emptyBuilder,
    this.headerBulder,
    this.controller,
    this.refreshOnStart = false,
    this.isGrid = false,
    this.crossAxisCount = 1,
    this.mainAxisSpacing = 0,
    this.crossAxisSpacing = 0,
  });

  /// 分页请求
  final DataRequest<T> dataRequest;

  /// item构造器
  final RefreshableListItemBuilder<T> itemBuilder;

  /// 每页数量
  final int pageSize;

  /// 当前页码
  final int currentPageNum;

  /// 空数据构造器
  /// 如果不传则使用默认的
  final EmptyItemBuilder? emptyBuilder;

  /// 表头构造器
  ///
  /// 用于自定义列表的header
  final HeaderBuilder? headerBulder;

  /// 控制器
  final RefreshableListController<T>? controller;

  /// 是否在初始化时自动刷新
  final bool refreshOnStart;

  /// 布局样式是否是网格
  final bool isGrid;

  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;

  factory RefreshableList.grid({
    required DataRequest<T> dataRequest,
    required RefreshableListItemBuilder<T> itemBuilder,
    int pageSize = 20,
    int currentPageNum = 1,
    EmptyItemBuilder? emptyBuilder,
    HeaderBuilder? headerBulder,
    RefreshableListController<T>? controller,
    bool refreshOnStart = false,
    int crossAxisCount = 1,
    double mainAxisSpacing = 0,
    double crossAxisSpacing = 0,
  }) {
    return RefreshableList(
      dataRequest: dataRequest,
      itemBuilder: itemBuilder,
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: mainAxisSpacing,
      crossAxisSpacing: crossAxisSpacing,
      isGrid: true,
    );
  }

  static void initialRefresh() {
    EasyRefresh.defaultHeaderBuilder = () => const ClassicHeader(
      dragText: '下拉刷新',
      armedText: '释放刷新',
      processingText: '刷新中...',
      readyText: '刷新中...',
      processedText: '刷新完成',
      failedText: '刷新失败',
      noMoreText: '没有更多',
      showText: true,
      messageText: '更新时间 %T',
    );
    EasyRefresh.defaultFooterBuilder = () => const ClassicFooter(
      dragText: '上拉加载',
      armedText: '释放加载',
      processingText: '加载中...',
      processedText: '加载完成',
      failedText: '加载失败',
      noMoreText: '没有更多数据了',
      showText: true,
      messageText: '更新时间 %T',
    );
  }

  @override
  State<RefreshableList<T>> createState() => _RefreshableListState<T>();
}

class _RefreshableListState<T> extends State<RefreshableList<T>> {
  /// 当前页码
  int _currentPageNum = 1;

  /// 每页数量
  int _pageSize = 20;

  /// 总数
  int? _totalCount;

  /// 数据列表
  final List<T> _dataList = [];

  /// 刷新控制器
  late final EasyRefreshController _easyRefreshcontroller;

  /// 刷新
  Future<void> _handleRefresh() async {
    _currentPageNum = 1;

    try {
      List<T> result = await widget.dataRequest(_currentPageNum, _pageSize);
      if (mounted) {
        setState(() {
          // _totalCount = result.total;
          _dataList.clear();
          _dataList.addAll(result);
        });
      }
      _easyRefreshcontroller.finishRefresh();
    } catch (e) {
      // 记录错误日志
      if (kDebugMode) {
        debugPrint('刷新失败: $e');
      }
      _easyRefreshcontroller.finishRefresh(IndicatorResult.fail);
    }
  }

  /// 加载更多
  Future<void> _handleLoadMore() async {
    try {
      List<T> result = await widget.dataRequest(_currentPageNum + 1, _pageSize);
      List<T> newDataList = result;
      if (newDataList.isEmpty) {
        _easyRefreshcontroller.finishLoad(IndicatorResult.noMore);
      } else {
        if (mounted) {
          setState(() {
            // _totalCount = result.total;
            _dataList.addAll(newDataList);
            _currentPageNum++;
          });
        }
        _easyRefreshcontroller.finishLoad(
          newDataList.length < _pageSize
              ? IndicatorResult.noMore
              : IndicatorResult.success,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('加载更多失败: $e');
      }

      _easyRefreshcontroller.finishLoad(IndicatorResult.fail);
    }
  }

  @override
  void initState() {
    super.initState();
    _pageSize = widget.pageSize;
    _currentPageNum = widget.currentPageNum;
    widget.controller?._bind(this);
    _easyRefreshcontroller =
        widget.controller?.easyRefreshcontroller ??
        EasyRefreshController(
          controlFinishRefresh: true,
          controlFinishLoad: false,
        );
  }

  Widget _emptyBuilder(BuildContext context) {
    return Container(
      color: Colors.transparent,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ImageUtil.asset('assets/icons/list_empty.svg',
          //     width: 80, height: 80, package: 'dnn_core'),
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.headerBulder?.call(
              context,
              _totalCount,
              _currentPageNum,
              _pageSize,
            ) ??
            Container(),
        Expanded(
          child: EasyRefresh.builder(
            controller: _easyRefreshcontroller,
            refreshOnStart: widget.refreshOnStart,
            onRefresh: _easyRefreshcontroller.controlFinishRefresh
                ? _handleRefresh
                : null,
            onLoad: _easyRefreshcontroller.controlFinishLoad
                ? _handleLoadMore
                : null,
            childBuilder: (context, physics) => CustomScrollView(
              physics: physics,
              slivers: [
                _dataList.isEmpty
                    ? SliverFillRemaining(
                        child:
                            widget.emptyBuilder?.call(context) ??
                            _emptyBuilder(context),
                      )
                    : widget.isGrid
                    ? SliverToBoxAdapter(
                        child: WaterfallFlow.count(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          crossAxisCount: widget.crossAxisCount,
                          crossAxisSpacing: widget.crossAxisSpacing,
                          mainAxisSpacing: widget.mainAxisSpacing,
                          padding: EdgeInsets.all(16),
                          children: _dataList
                              .map(
                                (e) => widget.itemBuilder(
                                  context,
                                  e,
                                  _dataList.indexOf(e),
                                ),
                              )
                              .toList(),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          return widget.itemBuilder(
                            context,
                            _dataList[index],
                            index,
                          );
                        }, childCount: _dataList.length),
                      ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
