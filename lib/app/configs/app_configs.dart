import 'package:core/core_utils/loading_util.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

abstract class AppConfigs {
  /// 一定要配置[GlobalCupertinoLocalizations.delegate],
  /// 否则iphone手机长按编辑框有白屏卡着的bug出现
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  /// 设置语言为中文
  static const List<Locale> supportedLocales = [Locale('zh', 'CN')];

  static Widget Function(BuildContext, Widget?)? initBuilder = LoadingUtil.init(
    builder: (context, child) {
      // 下拉刷新设置
      EasyRefresh.defaultHeaderBuilder = () => const ClassicHeader(
        dragText: '下拉刷新',
        armedText: '释放刷新',
        processingText: '刷新中...',
        readyText: '刷新中...',
        processedText: '刷新完成',
        failedText: '刷新失败',
        noMoreText: '没有更多',
        showText: true,
        messageText: '更新时间 %T',
      );
      EasyRefresh.defaultFooterBuilder = () => const ClassicFooter(
        dragText: '上拉加载',
        armedText: '释放加载',
        processingText: '加载中...',
        processedText: '加载完成',
        failedText: '加载失败',
        noMoreText: '没有更多数据了',
        showText: true,
        messageText: '更新时间 %T',
      );

      // 限制应用字体跟随系统缩放
      return MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(1.0)),
        child: child!,
      );
    },
  );
}
