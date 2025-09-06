import 'dart:math';
import 'dart:ui';

abstract class CommonUtil {
  /// 生成随机颜色
  static Color randomColor({int alpha = 255}) {
    Random random = Random();
    return Color.fromARGB(
      alpha,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  }

  // 生成随机字符串
  static String generateRandomString(int length) {
    final random = Random();
    const availableChars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    final randomString = List.generate(
      length,
      (index) => availableChars[random.nextInt(availableChars.length)],
    ).join();

    return randomString;
  }
}
