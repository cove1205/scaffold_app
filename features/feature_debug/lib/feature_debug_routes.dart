import 'package:get/get.dart';
import 'package:shared/shared_widget/qr_scan_widget.dart';

import 'pages/debug_index_page.dart';
import 'pages/info_page.dart';
import 'pages/log_page.dart';
import 'pages/permission_page.dart';
import 'pages/refresh_list_page.dart';
import 'pages/request_page.dart';

final debugPages = <GetPage<dynamic>>[
  GetPage(
    name: '/debug',
    page: () => const DebugIndexPage(),
    transition: Transition.rightToLeft,
    children: [
      GetPage(
        title: '查看日志',
        name: '/log',
        page: () => const LogPage(),
        transition: Transition.rightToLeft,
      ),
      GetPage(
        title: '应用和设备信息',
        name: '/info',
        page: () => const InfoPage(),
        transition: Transition.rightToLeft,
      ),
      GetPage(
        title: '请求',
        name: '/request',
        page: () => const RequestPage(),
        transition: Transition.rightToLeft,
      ),
      GetPage(
        title: '权限',
        name: '/permission',
        page: () => const PermissionPage(),
        transition: Transition.rightToLeft,
      ),
      GetPage(
        title: '二维码扫描',
        name: '/qr_scan',
        page: () => const QRScanWidget(),
        transition: Transition.rightToLeft,
      ),
      GetPage(
        title: '下拉列表',
        name: '/refresh_list',
        page: () => const RefreshListPage(),
        transition: Transition.rightToLeft,
        binding: RefreshListBinding(),
      ),
    ],
  ),
];
