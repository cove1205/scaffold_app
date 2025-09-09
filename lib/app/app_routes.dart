import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:shared_widget/default_not_found_page.dart';
import 'package:feature_auth/feature_auth_routes.dart';
import 'package:feature_debug/feature_debug_routes.dart';

import 'root_page.dart';
import 'splash_page.dart';

/// 404页面
///
/// 当跳转的路由出错或者不存在时,跳转到该页面
final unknownRoute = GetPage(
  name: '/not_found',
  page: () => DefaultNotFoundPage(),
);

/// 全局路由表
/// 模块路由在此处注册
final appPages = <GetPage<dynamic>>[
  GetPage(
    name: AppRoutes.initialRoute,
    page: () => Container(),
    middlewares: [InitialRoutesMiddleware()],
  ),

  GetPage(
    name: AppRoutes.splash,
    page: () => const SplashPage(),
    binding: SplashBinding(),
  ),

  GetPage(
    name: AppRoutes.root,
    page: () => const RootPage(),
    binding: RootBinding(),
  ),

  ...debugPages,

  ...authPages,
];

abstract class AppRoutes {
  // ----initialRoute----
  static const String initialRoute = '/';

  // ----splash----
  static const String splash = '/splash';

  // ----root----
  static const String root = '/root';

  // ----index----
  static const String index = '/index';
}

class InitialRoutesMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (route == AppRoutes.initialRoute) {
      return const RouteSettings(name: AppRoutes.splash);
    }
    return null;
  }
}
