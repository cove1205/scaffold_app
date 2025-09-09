import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

abstract class ScaffoldApp {
  /// rerturn the app widget
  FutureOr<Widget> buildApp();

  /// anything to be done before runApp
  Future<void> beforeRun(WidgetsBinding widgetsBinding) async {}

  /// anything to be done after runApp
  Future<void> afterRun() async {}

  void errorHandle(Object error, {StackTrace? stack}) {}

  @nonVirtual
  void run() async {
    WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
    await beforeRun(widgetsBinding);
    FlutterError.onError = (details) {
      errorHandle(details, stack: details.stack);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      errorHandle(error, stack: stack);
      return true;
    };
    runApp(await buildApp());
    await afterRun();
  }
}
