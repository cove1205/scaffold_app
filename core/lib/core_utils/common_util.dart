import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

abstract class CommonUtil {
  /// 生成随机颜色
  /// [opacity] 透明度 0.0 - 1.0
  static Color randomColor({double opacity = 1.0}) {
    Random random = Random();
    return Color.fromARGB(
      (opacity * 255).toInt(),
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  }

  /// 生成随机字符串
  /// [length] 字符串长度
  /// [containsNumbers] 是否包含数字
  /// [containsSpecialChars] 是否包含特殊字符
  static String generateRandomString(
    int length, {
    bool containsNumbers = true,
    bool containsSpecialChars = false,
  }) {
    final random = Random();
    final String letterChars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz';
    final String numberChars = containsNumbers ? '1234567890' : '';
    final String specialChars = containsSpecialChars
        ? '!@#\$%^&*()_+-=[]{}|;:,.<>?~'
        : '';

    final allChars = '$letterChars$numberChars$specialChars';
    final randomString = List.generate(
      length,
      (index) => allChars[random.nextInt(allChars.length)],
    ).join();

    return randomString;
  }
}
