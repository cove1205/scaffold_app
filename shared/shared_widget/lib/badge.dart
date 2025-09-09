import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';

class BadgeWidget extends StatelessWidget {
  const BadgeWidget(
      {super.key, required this.badgeCount, this.child, this.showBadge = true});

  /// 是否显示角标
  final bool showBadge;

  /// 显示的角标数量
  final int badgeCount;

  /// 角标依附的子组件
  final Widget? child;

  /// 判断badgeCount是否大于等于三位数
  bool get _isThreeDigit => badgeCount >= 100;

  @override
  Widget build(BuildContext context) {
    return badges.Badge(
      showBadge: showBadge ? badgeCount > 0 : false,
      position: badges.BadgePosition.topEnd(top: -5, end: -5),
      badgeStyle: badges.BadgeStyle(
          shape: _isThreeDigit
              ? badges.BadgeShape.square
              : badges.BadgeShape.circle,
          borderRadius:
              _isThreeDigit ? BorderRadius.circular(8) : BorderRadius.zero),
      badgeContent: Container(
        padding: EdgeInsets.zero,
        width: !_isThreeDigit ? 15 : null,
        height: !_isThreeDigit ? 15 : null,
        child: Center(
            child: Text(_isThreeDigit ? '99+' : badgeCount.toString(),
                maxLines: 1,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white))),
      ),
      badgeAnimation: const badges.BadgeAnimation.fade(),
      child: child,
    );
  }
}
