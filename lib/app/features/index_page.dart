import 'package:core_utils/log_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_widget/qr_scan_widget.dart';

import 'info_page.dart';
import 'permission_page.dart';
import 'request_page.dart';

List<Map<String, dynamic>> indexPagesList = [
  {'name': '查看日志', 'route': '/configs', 'page': LogUtil.debugScreen},
  {'name': '应用和设备信息', 'route': '/info', 'page': InfoPage()},
  {'name': '请求', 'route': '/request', 'page': RequestPage()},
  {'name': '权限', 'route': '/permission', 'page': PermissionPage()},
  {'name': '二维码扫描', 'route': '/qr_scan', 'page': QRScanWidget()},
];

class IndexPage extends StatelessWidget {
  const IndexPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('首页')),
      body: ListView.builder(
        itemCount: indexPagesList.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            color: Colors.white,
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: Text(indexPagesList[index]['name']!),
              trailing: Icon(Icons.arrow_forward_ios_sharp),
              onTap: () {
                Get.toNamed('/index${indexPagesList[index]['route']!}');
              },
            ),
          );
        },
      ),
    );
  }
}
