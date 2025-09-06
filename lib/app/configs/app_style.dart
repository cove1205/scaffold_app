import 'package:flutter/material.dart';

abstract class AppStyle {
  /// 颜色定义
  static const Color backgroundColor = Color.fromRGBO(250, 250, 250, 1);
  static const Color primaryColor = Color.fromRGBO(246, 181, 201, 1);
  static const Color hintColor = Color.fromRGBO(192, 192, 192, 1);
  static const Color dividerColor = Color.fromRGBO(227, 227, 227, 1);

  /// LinearGradient样式1
  static LinearGradient buttonGradient() {
    return LinearGradient(
      colors: [Color(0xffB19DF4), Color(0xffF6B5C9)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );
  }

  /// LinearGradient样式2
  static LinearGradient orderButtonGradient() {
    return LinearGradient(
      colors: [Color(0xff9AF3C7), Color(0xff58BAFF)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );
  }

  /// LinearGradient样式3
  static LinearGradient orderAureateButtonGradient() {
    return LinearGradient(
      colors: [Color(0xffD7A963), Color(0xffF5D29C)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );
  }
}
