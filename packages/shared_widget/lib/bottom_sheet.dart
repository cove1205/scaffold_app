import 'package:flutter/material.dart';

void showCustomBottomSheet(
  BuildContext context, {
  required Widget body,
  bool scrollControlled = false,
  Color bodyColor = Colors.white,
  EdgeInsets? bodyPadding,
  BorderRadius? borderRadius,
}) async {
  const radius = Radius.circular(16);
  borderRadius ??= const BorderRadius.only(topLeft: radius, topRight: radius);
  bodyPadding ??= const EdgeInsets.all(10);

  return showModalBottomSheet(
    context: context,
    isScrollControlled: scrollControlled,
    backgroundColor: bodyColor,
    shape: RoundedRectangleBorder(borderRadius: borderRadius),

    // 控制高度显示在安全区域
    constraints: BoxConstraints(
      maxHeight:
          MediaQuery.of(context).size.height -
          MediaQuery.of(context).viewPadding.top,
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          left: bodyPadding!.left,
          top: bodyPadding.top,
          right: bodyPadding.right,
          //控制底部显示在安全区域
          bottom:
              bodyPadding.bottom + MediaQuery.of(context).viewPadding.bottom,
        ),
        child: body,
      );
    },
  );
}
