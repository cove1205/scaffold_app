import 'package:core_utils/permission_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PermissionController extends GetxController {
  PermissionController();

  final permissionStatusMap = {
    PermissionType.camera: PermissionStatusType.denied,
    PermissionType.location: PermissionStatusType.denied,
    PermissionType.microphone: PermissionStatusType.denied,
    PermissionType.storage: PermissionStatusType.denied,
    PermissionType.notification: PermissionStatusType.denied,
    PermissionType.requestInstallPackages: PermissionStatusType.denied,
  }.obs;

  /// 获取权限状态
  Future<void> getPermissionStatus() async {
    Map<PermissionType, PermissionStatusType> permissionStatus =
        await PermissionUtil.requestPermissionList(
          permissionStatusMap.keys.toList(),
        );
    permissionStatusMap.updateAll((key, value) => permissionStatus[key]!);
  }

  @override
  void onInit() async {
    super.onInit();
    await getPermissionStatus();
  }
}

class PermissionPage extends GetView<PermissionController> {
  const PermissionPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(PermissionController());
    return Scaffold(
      appBar: AppBar(title: Text('权限')),
      body: Obx(() {
        return ListView.builder(
          itemCount: controller.permissionStatusMap.length,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                tileColor: Colors.white,
                title: Text(
                  controller.permissionStatusMap.keys
                      .elementAt(index)
                      .description,
                ),
                trailing: Obx(
                  () => Switch(
                    activeThumbColor: Colors.green,
                    value: controller.permissionStatusMap.values
                        .elementAt(index)
                        .isGranted,
                    onChanged: (value) async {
                      if (controller.permissionStatusMap.values
                          .elementAt(index)
                          .isGranted) {
                        return;
                      }

                      await controller.permissionStatusMap.keys
                          .elementAt(index)
                          .request();
                      controller.permissionStatusMap.update(
                        controller.permissionStatusMap.keys.elementAt(index),
                        (value) => value,
                      );
                    },
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
