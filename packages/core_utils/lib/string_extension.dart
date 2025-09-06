import 'dart:convert';
import 'package:crypto/crypto.dart';

/// String扩展
extension StringExtension on String {
  /// 转换成double类型
  double? toDouble() => double.tryParse(this);

  /// 转换成int类型
  int? toInt() => int.tryParse(this);

  /// 转换成MD5
  String toMD5() => md5.convert(utf8.encode(this)).toString();

  /// 转换成HASH
  String toSH1() => sha1.convert(utf8.encode(this)).toString();

  /// 单词首字母大写
  String get capitalize => '${this[0].toUpperCase()}${substring(1)}';

  /// 句子每个单词首字母大写
  String get capitalizedLetters {
    try {
      String temp = '';
      split(' ').forEach((s) {
        temp += '${s[0].toUpperCase()}${s.substring(1)} ';
      });
      return temp;
    } catch (e) {
      return '${this[0].toUpperCase()}${substring(1)}';
    }
  }

  /// 为空字符串增加默认值
  String whenEmpty(String defaultValue) {
    return isNotEmpty ? this : defaultValue;
  }

  /// 转换成金额格式
  String toMoneyFormat() {
    if (isEmpty) return '0';
    if (contains('.')) {
      List<String> arr = split('.');
      String intPart = arr[0];
      String floatPart = arr[1];
      if (floatPart.length == 1) {
        floatPart += '0';
      }
      return '${intPart.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+$)'), (Match match) => '${match[1]},')}.$floatPart';
    } else {
      return replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+$)'), (Match match) => '${match[1]},');
    }
  }
}

/// 字符串正则验证扩展
extension StringRegexExtension on String {
  /// Regex of simple mobile.
  static const String regexMobileSimple = '^[1]\\d{10}\$';

  /// Regex of exact mobile.
  ///  <p>china mobile: 134(0-8), 135, 136, 137, 138, 139, 147, 150, 151, 152, 157, 158, 159, 165, 172, 178, 182, 183, 184, 187, 188, 195, 198</p>
  ///  <p>china unicom: 130, 131, 132, 145, 155, 156, 166, 167, 171, 175, 176, 185, 186</p>
  ///  <p>china telecom: 133, 153, 162, 173, 177, 180, 181, 189, 199, 191</p>
  ///  <p>global star: 1349</p>
  ///  <p>virtual operator: 170</p>
  static const String regexMobileExact =
      '^((13[0-9])|(14[57])|(15[0-35-9])|(16[2567])|(17[01235-8])|(18[0-9])|(19[1589]))\\d{8}\$';

  /// Regex of telephone number.
  static const String regexTel = '^0\\d{2,3}[- ]?\\d{7,8}';

  /// Regex of id card number which length is 15.
  static const String regexIdCard15 =
      '^[1-9]\\d{7}((0\\d)|(1[0-2]))(([0|1|2]\\d)|3[0-1])\\d{3}\$';

  /// Regex of id card number which length is 18.
  static const String regexIdCard18 =
      '^[1-9]\\d{5}[1-9]\\d{3}((0\\d)|(1[0-2]))(([0|1|2]\\d)|3[0-1])\\d{3}([0-9Xx])\$';

  /// Regex of email.
  static const String regexEmail =
      '^\\w+([-+.]\\w+)*@\\w+([-.]\\w+)*\\.\\w+([-.]\\w+)*\$';

  /// Regex of url.
  static const String regexUrl = '[a-zA-Z]+://[^\\s]*';

  /// Regex of Chinese character.
  static const String regexZh = '[\\u4e00-\\u9fa5]';

  /// Regex of date which pattern is 'yyyy-MM-dd'.
  static const String regexDate =
      '^(?:(?!0000)[0-9]{4}-(?:(?:0[1-9]|1[0-2])-(?:0[1-9]|1[0-9]|2[0-8])|(?:0[13-9]|1[0-2])-(?:29|30)|(?:0[13578]|1[02])-31)|(?:[0-9]{2}(?:0[48]|[2468][048]|[13579][26])|(?:0[48]|[2468][048]|[13579][26])00)-02-29)\$';

  /// Regex of ip address.
  static const String regexIp =
      '((2[0-4]\\d|25[0-5]|[01]?\\d\\d?)\\.){3}(2[0-4]\\d|25[0-5]|[01]?\\d\\d?)';

  /// must contain letters and numbers, 6 ~ 18.
  /// 必须包含字母和数字, 6~18.
  static const String regexUsername =
      '^(?![0-9]+\$)(?![a-zA-Z]+\$)[0-9A-Za-z]{6,18}\$';

  /// must contain letters and numbers, can contain special characters 6 ~ 18.
  /// 必须包含字母和数字,可包含特殊字符 6~18.
  static const String regexUsername2 =
      '^(?![0-9]+\$)(?![a-zA-Z]+\$)[0-9A-Za-z\\W]{6,18}\$';

  /// must contain letters and numbers and special characters, 6 ~ 18.
  /// 必须包含字母和数字和殊字符, 6~18.
  static const String regexUsername3 =
      '^(?![0-9]+\$)(?![a-zA-Z]+\$)(?![0-9a-zA-Z]+\$)(?![0-9\\W]+\$)(?![a-zA-Z\\W]+\$)[0-9A-Za-z\\W]{6,18}\$';

  /// Regex of QQ number.
  static const String regexQQ = '[1-9][0-9]{4,}';

  /// Regex of postal code in China.
  static const String regexChinaPostalCode = '[1-9]\\d{5}(?!\\d)';

  /// Regex of Passport.
  static const String regexPassport =
      r'(^[EeKkGgDdSsPpHh]\d{8}$)|(^(([Ee][a-fA-F])|([DdSsPp][Ee])|([Kk][Jj])|([Mm][Aa])|(1[45]))\d{7}$)';

  ///Return whether input matches regex of simple mobile.
  bool isMobileSimple() => matches(regexMobileSimple);

  ///Return whether input matches regex of exact mobile.
  bool isMobileExact() => matches(regexMobileExact);

  /// Return whether input matches regex of telephone number.
  bool isTel() => matches(regexTel);

  /// Return whether input matches regex of id card number.
  bool isIDCard() {
    if (length == 15) {
      return isIDCard15();
    }
    if (length == 18) {
      return isIDCard18();
    }
    return false;
  }

  /// Return whether input matches regex of id card number which length is 15.
  bool isIDCard15() {
    return matches(regexIdCard15);
  }

  /// Return whether input matches regex of id card number which length is 18.
  bool isIDCard18() {
    return matches(regexIdCard18);
  }

  /// Return whether input matches regex of email.
  bool isEmail() {
    return matches(regexEmail);
  }

  /// Return whether input matches regex of url.
  bool isURL() {
    return matches(regexUrl);
  }

  /// Return whether input matches regex of Chinese character.
  bool isZh() {
    return '〇' == this || matches(regexZh);
  }

  /// Return whether input matches regex of date which pattern is 'yyyy-MM-dd'.
  bool isDate() {
    return matches(regexDate);
  }

  /// Return whether input matches regex of ip address.
  bool isIP() {
    return matches(regexIp);
  }

  /// Return whether input matches regex of username.
  bool isUserName() {
    return matches(regexUsername);
  }

  /// Return whether input matches regex of QQ.
  bool isQQ() {
    return matches(regexQQ);
  }

  ///Return whether input matches regex of Passport.
  bool isPassport() {
    return matches(regexPassport);
  }

  bool matches(String regex) {
    if (isEmpty) return false;
    return RegExp(regex).hasMatch(this);
  }
}
