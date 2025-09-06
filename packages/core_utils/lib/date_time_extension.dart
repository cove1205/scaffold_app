/// DataTime格式化扩展
extension FormatExtension on DateTime {
  /// 年
  String get yearEx => '$year';

  /// 月
  String get monthEx => '$month'.padLeft(2, '0');

  /// 日
  String get dayEx => '$day'.padLeft(2, '0');

  /// 时
  String get hourEx => '$hour'.padLeft(2, '0');

  /// 分
  String get minuteEx => '$minute'.padLeft(2, '0');

  /// 秒
  String get secondEx => '$second'.padLeft(2, '0');

  /// 年-月
  String toYM() => '$yearEx-$monthEx';

  /// 月-日
  String toMD() => '$monthEx-$dayEx';

  /// 年-月-日
  String toYMD() => '$yearEx-$monthEx-$dayEx';

  /// 时:分:秒
  String toHMS() => '$hourEx:$minuteEx:$secondEx';

  /// 时:分
  String toHM() => '$hourEx:$minuteEx';

  /// 年-月-日 时:分:秒
  String toYMDHMS() => '${toYMD()} ${toHMS()}';

  /// 当前起始
  DateTime get startOfDay => DateTime(year, month, day, 0, 0, 0, 0, 0);

  /// 当天结束
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999, 999);
}

/// DataTime中文格式化扩展
extension FormatExtensionCN on DateTime {
  /// 年-月/中文
  String toYMCN() => '$yearEx年$monthEx月';

  /// 年-月-日/中文
  String toYMDCN() => '$yearEx年$monthEx月$dayEx日';

  /// 月-日/中文
  String toMDCN() => '$monthEx月$dayEx日';

  /// 周几
  String get weekDayCN {
    switch (weekday) {
      case 1:
        return '周一';
      case 2:
        return '周二';
      case 3:
        return '周三';
      case 4:
        return '周四';
      case 5:
        return '周五';
      case 6:
        return '周六';
      case 7:
        return '周日';
      default:
        return '';
    }
  }
}

/// DataTime扩展
extension DateTimeExtension on DateTime {
  /// 是否是整点
  bool get isOnTheHour =>
      minute == 0 && second == 0 && millisecond == 0 && microsecond == 0;

  /// 距离当前时间的时间差
  String timePassed({bool year = false, bool month = false}) {
    final diff = DateTime.now().difference(this);

    if (diff.inDays > 365 && year) {
      return '${diff.inDays ~/ 365}年前';
    } else if (diff.inDays > 30 && month) {
      return '${diff.inDays ~/ 30}个月前';
    } else if (diff.inDays > 0) {
      return '${diff.inDays}天前';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}小时前';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}分钟前';
    } else if (diff.inSeconds > 0) {
      return '${diff.inSeconds}秒前';
    } else {
      return '刚刚';
    }
  }
}
