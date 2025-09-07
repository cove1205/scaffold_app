import 'package:core_network/core_network.dart';
import 'package:core_utils/loading_util.dart';
import 'package:core_utils/log_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';

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
      'https://jsonplaceholder.typicode.com1/todos/12',
    );

    NetworkResponse res = await networkClient.fetch(req, retry: false);

    if (res.exception != null) {
      LoadingUtil.showError(res.exception!.message);
    } else {
      resMap.value = res.data;
      LogUtil.info('请求结果: ${res.data}');
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('请求结果'),
          Obx(() {
            // 使用JsonEncoder格式化Map输出，使其更美观可读

            return Text(
              const JsonEncoder.withIndent('  ').convert(controller.resMap),
            );
          }),
        ],
      ),
    );
  }
}
