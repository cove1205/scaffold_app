import 'package:core/core_extensions/function_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared/shared_interface/debug_interface.dart';
import 'package:shared/shared_models/item.dart';
import 'package:shared/shared_widget/refreshable_paging_widget.dart';

class RefreshListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => RefreshListController(Get.find<DebugInterface>()));
  }
}

class RefreshListController extends GetxController {
  RefreshListController(this._repo);

  final DebugInterface _repo;

  Future<List<Item>> getItemList(int pageNum, int pageSize) async {
    List<Item> res = await _repo
        .getItemList(pageNum, pageSize)
        .withMinSeconds(1);
    return res;
  }
}

class RefreshListPage extends GetView<RefreshListController> {
  const RefreshListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('下拉列表')),
      body: RefreshablePagingList(
        refreshOnStart: true,
        dataRequest: controller.getItemList,
        itemBuilder: (context, item, index) {
          return Container(
            margin: EdgeInsets.all(10),
            color: Colors.blue.withAlpha(125),
            child: ListTile(
              title: Text(item.name),
              subtitle: Text(item.id.toString()),
            ),
          );
        },
      ),
    );
  }
}
