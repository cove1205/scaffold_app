import 'package:core/core_network/core_network.dart';
import 'package:shared/shared_services/interfaces/debug_interface.dart';
import 'package:shared/shared_services/models/item.dart';

import 'package:get/get.dart';
import 'package:shared/shared_services/services/http_helper.dart';

class DebugRepository extends GetxService implements DebugInterface {
  @override
  Future<List<Item>> getItemList(int page, int pageSize) async {
    NetworkRequest req = NetworkRequest(
      'http://192.168.31.94:8000/items1',
      queryParams: {'page': page, 'page_size': pageSize},
    );

    return await NetworkClient()
        .fetch(req, retry: true)
        .decodeData(listDecoder: Item.fromJson);
  }

  @override
  Future<Item> getItemDetail(int id) async {
    NetworkRequest req = NetworkRequest('http://192.168.31.94:8000/items/$id');
    return await NetworkClient()
        .fetch(req, retry: true)
        .decodeData(decoder: Item.fromJson);
  }
}
