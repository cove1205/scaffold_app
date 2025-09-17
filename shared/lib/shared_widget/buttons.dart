import 'package:core/core_extensions/function_extension.dart';
import 'package:flutter/material.dart';

/// 通用按钮
class CommonButton extends StatelessWidget {
  /// 按钮文本内容
  final String text;

  /// 按钮图标组件
  final Widget? icon;

  /// 按钮点击回调事件
  final VoidCallback? onPressed;

  /// 文本颜色
  final Color textColor;

  /// 按钮背景色
  final Color backgroundColor;

  /// 图标颜色
  final Color? iconColor;

  /// 边框颜色
  final Color? borderColor;

  /// 图标对齐方式
  final IconAlignment? iconAlignment;

  /// 文本样式
  final TextStyle? textStyle;

  /// 内边距
  final EdgeInsetsGeometry? padding;

  /// 最大宽度
  final double? maxWidth;

  /// 圆角
  final BorderRadius? borderRadius;

  const CommonButton({
    super.key,
    required this.text,
    this.icon,
    this.onPressed,
    this.iconAlignment,
    this.backgroundColor = Colors.blue,
    this.borderColor,
    this.textColor = Colors.white,
    this.iconColor,
    this.textStyle,
    this.padding,
    this.maxWidth,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      icon: icon,
      label: Text(
        text,
        style:
            textStyle ??
            TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
      ),
      // onPressed: onPressed?.throttle(),
      onPressed: onPressed?.throttle(),
      iconAlignment: iconAlignment ?? IconAlignment.start,
      style: ButtonStyle().copyWith(
        padding: WidgetStateProperty.all(
          padding ?? EdgeInsets.symmetric(horizontal: 16),
        ),
        iconColor: iconColor != null
            ? WidgetStateProperty.all(iconColor)
            : null,
        maximumSize: WidgetStateProperty.all(
          Size(maxWidth ?? double.infinity, 48),
        ),
        side: borderColor == null
            ? null
            : WidgetStatePropertyAll(BorderSide(color: borderColor!)),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(24),
          ),
        ),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.pressed)
              ? backgroundColor.withAlpha(128)
              : backgroundColor;
        }),
      ),
    );
  }
}
