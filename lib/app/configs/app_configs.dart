import 'package:core/core_utils/loading_util.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

abstract class AppConfigs {
  /// 设计稿尺寸
  static const Size designSize = Size(375, 812);

  /// 状态栏和导航栏
  static const SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    // 状态栏透明
    statusBarIconBrightness: Brightness.dark,
    // 状态栏图标为浅色
    statusBarBrightness: Brightness.dark,
    // iOS状态栏为深色背景
    systemNavigationBarColor: Colors.transparent,
    // 底部导航栏透明
    systemNavigationBarIconBrightness: Brightness.dark,
    // 底部导航栏图标为浅色
    systemNavigationBarDividerColor: Colors.transparent,
  );

  /// 主题配置
  static ThemeData themeData = ThemeData(
    // ignore: deprecated_member_use
    useMaterial3: false,
    primarySwatch: Colors.blue,
    colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3E9BFE)),
    brightness: Brightness.light,
    primaryColor: Color(0xff8A63FD),
    scaffoldBackgroundColor: Colors.white,
    inputDecorationTheme: const InputDecorationTheme(
      // suffixIconColor: Colors.grey,
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF3E9BFE), width: 1.5),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.blue,
      shape: CircleBorder(),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: Color(0xFF3E9BFE),
      unselectedItemColor: Color(0xFF333333),
    ),
    appBarTheme: const AppBarTheme().copyWith(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Color(0xff12121E),
      foregroundColor: Colors.white,
      titleTextStyle: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      toolbarTextStyle: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: Colors.white,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        padding: WidgetStateProperty.all(EdgeInsets.zero),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        shadowColor: WidgetStateProperty.all(Colors.transparent),
        textStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 17, fontWeight: FontWeight.w400),
        ),
      ),
    ),
    tabBarTheme: const TabBarThemeData(
      labelColor: Color(0xFF3E9BFE),
      unselectedLabelColor: Color(0xFF333333),
      labelPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
      unselectedLabelStyle: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      indicatorSize: TabBarIndicatorSize.tab,
      indicatorColor: Color(0xFF3E9BFE),
    ),
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
  );

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
