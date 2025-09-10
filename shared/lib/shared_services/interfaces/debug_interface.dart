import '../models/item.dart';

abstract interface class DebugInterface {
  /// 获取列表数据
  Future<List<Item>> getItemList(int page, int pageSize);

  /// 获取详情数据
  Future<Item> getItemDetail(int id);
}
