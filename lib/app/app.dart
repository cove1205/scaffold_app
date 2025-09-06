import 'dart:async';

import 'package:core_utils/lifecycle_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:core_network/core_network.dart';
import 'package:core_utils/connectivity_util.dart';
import 'package:core_utils/info_util.dart';
import 'package:core_utils/log_util.dart';
import 'package:core_utils/storage_util.dart';
import 'package:shared_widget/scaffold_app.dart';
import 'package:shared_widget/ui_export.dart'
    show GlobalLoaderOverlay, ScreenUtilInit;

import 'configs/interceptors.dart';
import 'configs/app_configs.dart';
import 'app_routes.dart';

class App extends ScaffoldApp {
  @override
  FutureOr<Widget> buildApp() async {
    return ScreenUtilInit(
      designSize: AppConfigs.designSize,
      minTextAdapt: true,
      splitScreenMode: true,
      child: GlobalLoaderOverlay(
        overlayWidgetBuilder: AppConfigs.overlayWidgetBuilder,
        child: GetMaterialApp(
          title: AppConfigs.title,
          debugShowCheckedModeBanner: false,
          initialRoute: AppRoutes.initialRoute,
          unknownRoute: unknownRoute,
          getPages: appPages,
          theme: AppConfigs.themeData,
          localizationsDelegates: AppConfigs.localizationsDelegates,
          supportedLocales: AppConfigs.supportedLocales,
          navigatorObservers: [LogUtil.navigatorObserver],
          builder: AppConfigs.initBuilder,
        ),
      ),
    );
  }

  @override
  Future<void> beforeRun(widgetsBinding) async {
    LogUtil.info('>>>>>Init Services Start<<<<<');

    try {
      /// init Utils
      await StorageUtil.init();
      await InfoUtil.init();

      NetworkClient.init(
        // baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        interceptors: [
          // TokenRefreshInterceptor(),
          LoadingInterceptor(),
          LogUtil.talkerDioLogger,
          ResInterceptor(),
        ],
      );

      LifecycleUtil.addLifeCycleListener((lifecycle) {
        LogUtil.info(
          '>>>>>>>>>>>>当前生命周期发生改变: ${lifecycle.description} <<<<<<<<<<<<',
        );
      });

      ConnectivityStatus status = await ConnectivityUtil.checkConnectivity();
      LogUtil.info('当前网络状态: ${status.nameZh}');
      LogUtil.info('>>>Init Services Finished<<<');
    } on Error catch (e) {
      LogUtil.error('>>>Init Services Error: ${e.toString()}<<<');
    }
  }

  @override
  Future<void> afterRun() async {
    ///设置Android头部的导航栏透明
    SystemChrome.setSystemUIOverlayStyle(AppConfigs.systemUiOverlayStyle);

    return super.afterRun();
  }

  @override
  void errorHandle(Object error, {StackTrace? stack}) async {
    LogUtil.error('全局异常捕捉: ${error.toString()}', stackTrace: stack);
  }
}
