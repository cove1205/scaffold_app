import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

abstract class AppStyle {
  /// 颜色定义
  static const Color backgroundColor = Color.fromRGBO(250, 250, 250, 1);
  static const Color primaryColor = Color.fromRGBO(246, 181, 201, 1);
  static const Color hintColor = Color.fromRGBO(192, 192, 192, 1);
  static const Color dividerColor = Color.fromRGBO(227, 227, 227, 1);

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
