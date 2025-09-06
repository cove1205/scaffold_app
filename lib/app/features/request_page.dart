import 'package:core_network/core_network.dart';
import 'package:core_utils/log_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RequestBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => RequestController());
  }
}

class RequestController extends GetxController {
  RequestController();

  final resMap = <String, dynamic>{}.obs;

  /// 请求
  Future<void> request() async {
    NetworkRequest req = NetworkRequest(
      'https://jsonplaceholder.typicode.com/todos/12',
    );

    NetworkResponse res = await networkClient.fetch(req);

    if (res.exception != null) {
      LogUtil.error(
        res.exception!.message,
        stackTrace: res.exception!.stackTrace,
      );
    } else {
      resMap.value = res.data;
      LogUtil.info('请求结果: ${res.data.toString()}');
    }
  }

  @override
  void onInit() async {
    super.onInit();
    await request();
  }
}

class RequestPage extends GetView<RequestController> {
  const RequestPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(RequestController());
    return Scaffold(
      appBar: AppBar(title: Text('请求')),
      body: Column(
        children: [
          Text('请求'),
          Obx(() {
            return Text(controller.resMap.toString());
          }),
        ],
      ),
    );
  }
}
