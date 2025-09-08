import 'dart:io';

import 'package:core_network/core_network.dart';
import 'package:core_utils/loading_util.dart';
import 'package:core_utils/log_util.dart';
import 'package:core_utils/storage_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';

import 'package:shared_widget/buttons.dart';

class RequestBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => RequestController());
  }
}

class RequestController extends GetxController {
  RequestController();

  final resMap = <String, dynamic>{}.obs;

  /// 下载进度
  final downloadProgress = 0.0.obs;

  /// 下载结果
  final downloadRes = false.obs;
  String path = '';

  @override
  void onInit() async {
    super.onInit();
    path = '${await StorageUtil.cacheDirectory}/1234.jpeg';
  }

  /// 下载文件
  Future<void> downloadFile() async {
    downloadProgress.value = 0;
    downloadRes.value = false;
    DownloadRequest req = DownloadRequest(
      'http://192.168.31.94:8000/download_pdf',
      savePath: path,
      onReceiveProgress: (received, total) {
        downloadProgress.value = received / total;
      },
    );
    NetworkResponse res = await networkClient.download(req, retry: true);
    if (res.exception != null) {
      LoadingUtil.showError(res.exception!.message);
    } else {
      downloadRes.value = true;
      LoadingUtil.showSuccess('下载成功');
    }
  }

  /// 请求
  Future<void> request() async {
    NetworkRequest req = NetworkRequest(
      // 'https://jsonplaceholder.typicode.com1/todos/12',
      'http://192.168.31.94:8000/items/222',
      queryParams: {'q': '222dsdasdadsa'},
    );

    NetworkResponse res = await networkClient.fetch(req, retry: true);

    if (res.exception != null) {
      LoadingUtil.showError(res.exception!.message);
    } else {
      resMap.value = res.data;
      LogUtil.info('请求结果: ${res.data}');
    }
  }

  /// 上传文件
  Future<void> uploadFile() async {
    UploadRequset req = UploadRequset(
      'http://192.168.31.94:8000/upload_file',
      filePaths: [path],
      onSendProgress: (received, total) {
        // LoadingUtil.showProgress(received / total);
        debugPrint('上传进度: $received / $total');
      },
    );

    NetworkResponse res = await networkClient.upload(req, retry: true);
    if (res.exception != null) {
      LoadingUtil.showError(res.exception!.message);
    } else {
      LoadingUtil.showSuccess('上传成功');
    }
  }
}

class RequestPage extends GetView<RequestController> {
  const RequestPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(RequestController());
    return Scaffold(
      appBar: AppBar(title: Text('请求')),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16),
          color: Colors.white,
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('get请求结果'),
              Obx(() {
                return Text(
                  const JsonEncoder.withIndent('  ').convert(controller.resMap),
                );
              }),
              SizedBox(height: 20),
              CommonButton(
                text: 'get请求',
                onPressed: () async {
                  await controller.request();
                },
              ),
              SizedBox(height: 40),

              Obx(() {
                return Text(
                  '下载进度: ${controller.downloadProgress.value * 100}%',
                );
              }),
              CommonButton(
                text: '下载文件',
                onPressed: () async {
                  await controller.downloadFile();
                },
              ),

              Obx(() {
                return controller.downloadRes.value
                    ? Image.file(File(controller.path))
                    : Container();
              }),

              SizedBox(height: 40),

              CommonButton(
                text: '上传文件',
                onPressed: () async {
                  await controller.uploadFile();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
