import 'dart:async';

import 'package:core/core_network/core_network.dart';
import 'package:core/core_network/interceptors/retry_interceptor.dart';
import 'package:core/core_utils/connectivity_util.dart';
import 'package:core/core_utils/info_util.dart';
import 'package:core/core_utils/lifecycle_util.dart';
import 'package:core/core_utils/log_util.dart';
import 'package:core/core_utils/storage_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared/shared_app_style.dart';
import 'package:shared/shared_widget/scaffold_app.dart';

import 'configs/app_constant.dart';
import 'configs/app_interceptors.dart';
import 'configs/app_configs.dart';
import 'configs/app_routes.dart';
import 'configs/app_services.dart';

class App extends ScaffoldApp {
  @override
  FutureOr<Widget> buildApp() async {
    return ScreenUtilInit(
      designSize: AppStyle.designSize,
      minTextAdapt: true,
      splitScreenMode: true,
      child: GetMaterialApp(
        title: AppConstant.appName,
        debugShowCheckedModeBanner: false,
        initialRoute: AppRoutes.initialRoute,
        unknownRoute: unknownRoute,
        getPages: appPages,
        theme: AppStyle.themeData,
        localizationsDelegates: AppConfigs.localizationsDelegates,
        supportedLocales: AppConfigs.supportedLocales,
        navigatorObservers: [LogUtil.navigatorObserver],
        builder: AppConfigs.initBuilder,
      ),
    );
  }

  @override
  Future<void> beforeRun(widgetsBinding) async {
    LogUtil.info('>>>>>Init Services Start<<<<<');

    try {
      /// init Services
      AppServices.initServices();

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
          RetryInterceptor(dio: NetworkClient.dio, logPrint: LogUtil.warning),
          ResInterceptor(),
          LogUtil.talkerDioLogger,
        ],
      );

      LifecycleUtil.addLifeCycleListener((lifecycle) {
        LogUtil.info(
          '>>>>>>>>>>>>当前生命周期发生改变: ${lifecycle.description} <<<<<<<<<<<<',
        );
      });

      ConnectivityUtil.listenConnectivityChanged((status) {
        LogUtil.info('>>>>>>>>>>>>当前网络状态发生变化: ${status.nameZh}<<<<<<<<<<<<');
      });

      LogUtil.info('>>>Init Services Finished<<<');
    } on Error catch (e) {
      LogUtil.error('>>>Init Services Error: ${e.toString()}<<<');
    }
  }

  @override
  Future<void> afterRun() async {
    ///设置Android头部的导航栏透明
    SystemChrome.setSystemUIOverlayStyle(AppStyle.systemUiOverlayStyle);

    return super.afterRun();
  }

  @override
  void errorHandle(Object error, {StackTrace? stack}) async {
    LogUtil.error('全局异常捕捉: ${error.toString()}', stackTrace: stack);
  }
}
