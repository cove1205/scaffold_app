import 'dart:io';
import 'dart:convert';

import 'package:get/get.dart';
import 'package:core/core_extensions/function_extension.dart';
import 'package:core/core_network/core_network.dart';
import 'package:core/core_utils/loading_util.dart';
import 'package:core/core_utils/storage_util.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared_interface/debug_interface.dart';
import 'package:shared/shared_models/item.dart';
import 'package:shared/shared_services/http_helper.dart';
import 'package:shared/shared_widget/buttons.dart';

class RequestBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => RequestController());
  }
}

class RequestController extends GetxController {
  RequestController();
  final _repo = Get.find<DebugInterface>();
  final item = Rxn<Item>();

  /// 下载进度
  final downloadProgress = 0.0.obs;

  /// 下载结果
  final downloadRes = false.obs;
  String path = '';

  @override
  void onInit() async {
    super.onInit();
  }

  /// 下载文件
  Future<void> downloadFile() async {
    downloadProgress.value = 0;
    downloadRes.value = false;

    String fileName = 'IMG_3597.jpeg';
    path = '${await StorageUtil.cacheDirectory}/$fileName';
    DownloadRequest req = DownloadRequest(
      'http://192.168.31.94:8000/download_file',
      savePath: path,
      queryParams: {'file_name': 'IMG_3597.jpeg'},
      onReceiveProgress: (received, total) {
        downloadProgress.value = received / total;
      },
    );

    await networkClient
        .download(req, retry: true)
        .tryCatch(
          (l) => LoadingUtil.showError('下载失败: ${l.message}'),
          (r) => downloadRes.value = true,
        );
  }

  /// 请求
  Future<void> request() async {
    await _repo
        .getItemDetail(222)
        .withLoading()
        .tryCatchClean(
          (l) => LoadingUtil.showError('请求失败: ${l.message}'),
          (r) => item.value = r,
        );
  }

  /// 上传文件
  Future<void> uploadFile() async {
    UploadRequset req = UploadRequset(
      'http://192.168.31.94:8000/upload_file',
      filePaths: [path],
      onSendProgress: (received, total) {
        LoadingUtil.showProgress(received / total);
        debugPrint('上传进度: $received / $total');
      },
    );

    await networkClient
      ..upload(req, retry: true).tryCatch(
        (l) => LoadingUtil.showError('上传失败: ${l.message}'),
        (r) => LoadingUtil.showSuccess('上传成功'),
      );
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
                  const JsonEncoder.withIndent(
                    '  ',
                  ).convert(controller.item.value?.name),
                );
              }),
              SizedBox(height: 20),
              CommonButton(text: 'get请求', onPressed: controller.request),
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
