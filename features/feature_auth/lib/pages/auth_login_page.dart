import 'package:flutter/material.dart';
import 'package:get/get.dart';
class AuthLoginBinding extends Bindings {
    @override
    void dependencies() {
        Get.lazyPut(() => AuthLoginController());
    }
}
class AuthLoginController extends GetxController {
    AuthLoginController();
}
class AuthLoginPage extends GetView<AuthLoginController> {
    const AuthLoginPage({super.key});
    
    @override
    Widget build(BuildContext context) {
         return Scaffold();
    }
}