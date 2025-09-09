import 'package:feature_debug/pages/debug_index_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_widget/dialogs.dart';
import 'package:shared_widget/bottom_nav_widget.dart';

class RootBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => RootController());
  }
}

class RootController extends GetxController {
  RootController();
}

class RootPage extends GetView<RootController> {
  const RootPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(RootController());
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          await showDialog(
            context: context,
            builder: (context) {
              return ConfirmDialog(
                contentText: '确定要退出吗?',
                onConfirm: () {
                  /// 关闭应用
                  SystemNavigator.pop();
                },
              );
            },
          );
        }
      },
      child: BottomNavPage(
        menuList: [
          BottomNavItem(
            icon: Icon(Icons.access_alarm),
            page: Center(child: Text('首页')),
            name: '首页',
            selectedIcon: Icon(Icons.access_alarm, color: Colors.blue),
          ),
          BottomNavItem(
            icon: Icon(Icons.accessibility_rounded),
            page: Center(child: Text('消息')),
            name: '消息',
            selectedIcon: Icon(Icons.accessibility_rounded, color: Colors.blue),
          ),
          BottomNavItem(
            icon: Icon(Icons.access_time_filled_outlined),
            page: Center(child: Text('我的')),
            name: '我的',
            selectedIcon: Icon(
              Icons.access_time_filled_outlined,
              color: Colors.blue,
            ),
          ),
          BottomNavItem(
            icon: Icon(Icons.access_time_filled_outlined),
            page: DebugIndexPage(),
            name: 'Debug',
            selectedIcon: Icon(
              Icons.access_time_filled_outlined,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}
