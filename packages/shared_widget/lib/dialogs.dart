import 'package:flutter/material.dart';

import 'buttons.dart';

class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({super.key, this.contentText = '确认操作吗?', this.onConfirm});

  final String contentText;

  /// 确认后回调方法
  final VoidCallback? onConfirm;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      contentPadding: EdgeInsets.zero,
      insetPadding: EdgeInsets.symmetric(horizontal: 32),
      content: Container(
        width: 300,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              contentText,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF1A1A1A),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: CommonButton(
                    text: '取消',
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    backgroundColor: Color(0xFF7C65F6).withAlpha(45),
                    textColor: Color(0xFF7C65F6),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: CommonButton(
                    text: '确认',
                    onPressed: () {
                      onConfirm?.call();
                      Navigator.of(context).pop();
                    },
                    backgroundColor: Color(0xFF7C65F6),
                    textColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
