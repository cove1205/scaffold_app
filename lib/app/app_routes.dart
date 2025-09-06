import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';

import 'features/index_page.dart';
import 'features/splash_page.dart';

/// 404页面
///
/// 当跳转的路由出错或者不存在时,跳转到该页面
final unknownRoute = GetPage(name: '/notfound', page: () => Container());

/// 全局路由表
/// 模块路由在此处注册
final appPages = <GetPage<dynamic>>[
  GetPage(
    name: '/splash',
    page: () => const SplashPage(),
    binding: SplashBinding(),
  ),

  GetPage(
    name: '/index',
    page: () => const IndexPage(),
    transition: Transition.rightToLeft,
    children: indexPagesList
        .map(
          (e) => GetPage(
            name: e['route'],
            page: () => e['page'],
            transition: Transition.rightToLeft,
          ),
        )
        .toList(),
  ),
];

abstract class AppRoutes {
  // ----root----
  static const String initialRoute = '/splash';
}
