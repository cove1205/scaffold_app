import 'package:get/get.dart';

import 'package:feature_debug/services/debug_repository.dart';
import 'package:shared/shared_interface/debug_interface.dart';

abstract class AppServices {
  AppServices._();

  /// 初始化服务
  /// 包括接口实现
  /// 以及工具类初始化
  static void initServices() {
    Get.lazyPut<DebugInterface>(() => DebugRepository());
  }
}
