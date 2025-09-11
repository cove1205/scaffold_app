import 'package:core/core_extensions/function_extension.dart';
import 'package:get/get.dart';

import 'package:core/core_network/core_network.dart';
import 'package:shared/shared_interface/debug_interface.dart';
import 'package:shared/shared_models/item.dart';
import 'package:shared/shared_services/http_helper.dart';

class DebugRepository extends GetxService implements DebugInterface {
  @override
  Future<List<Item>> getItemList(int page, int pageSize) async {
    NetworkRequest req = NetworkRequest(
      '/items',
      queryParams: {'page': page, 'page_size': pageSize},
    );

    return await NetworkClient()
        .fetch(req, retry: true)
        .decodeData(listDecoder: Item.fromJson)
        .withMinSeconds(2);
  }

  @override
  Future<Item> getItemDetail(int id) async {
    NetworkRequest req = NetworkRequest(
      '/items/$id',
      // 'https://jsonplaceholder.typicode.com/todos/1',
    );
    return await NetworkClient()
        .fetch(req, retry: true)
        .decodeData(decoder: Item.fromJson)
        .withMinSeconds(2);
  }
}
