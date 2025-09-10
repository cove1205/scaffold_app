import 'package:get/get.dart';

import 'package:feature_debug/services/debug_repository.dart';
import 'package:shared/shared_services/interfaces/debug_interface.dart';

abstract class AppServices {
  AppServices._();
  static void initServices() {
    Get.lazyPut<DebugInterface>(() => DebugRepository());
  }
}
