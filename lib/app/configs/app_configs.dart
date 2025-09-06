import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_widget/refreshable.dart' show RefreshableList;
import 'package:shared_widget/ui_export.dart';

abstract class AppConfigs {
  static const String title = 'XXXXXXXX';

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
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFF333333),
      titleTextStyle: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: Color(0xFF333333),
      ),
      toolbarTextStyle: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: Color(0xFF333333),
      ),
      iconTheme: const IconThemeData(color: Color(0xFF333333)),
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
    scaffoldBackgroundColor: const Color(0xFFF7F7F7),
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

  static Widget Function(BuildContext, Widget?)? initBuilder =
      (context, child) {
        // 全局设置
        RefreshableList.initialRefresh();
        // 限制应用字体跟随系统缩放
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(1.0)),
          child: child!,
        );
      };

  static Widget Function(dynamic)? overlayWidgetBuilder = (_) {
    return Container(
      color: Colors.black12,
      width: double.infinity,
      child: Center(
        child: LoadingAnimationWidget.twistingDots(
          leftDotColor: const Color(0xFF1A1A3F),
          rightDotColor: const Color(0xFFEA3799),
          size: 40,
        ),
      ),
    );
  };
}
