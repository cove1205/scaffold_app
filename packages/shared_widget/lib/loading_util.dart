import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';

abstract class LoadingUtil {
  static void show(BuildContext context) {
    context.loaderOverlay.show();
  }

  static void hide(BuildContext context) {
    if (context.loaderOverlay.visible) {
      context.loaderOverlay.hide();
    }
  }

  static void showProgress(BuildContext context, double progress) {
    context.loaderOverlay.show(progress: progress);
  }
}
