import 'package:flutter/material.dart';
import 'package:ultra_qr_scanner/ultra_qr_scanner_widget.dart';

/// 二维码扫描组件
class QRScanWidget extends StatefulWidget {
  const QRScanWidget({
    super.key,
    this.showFlashToggle = true,
    this.showStartStopButton = false,
    this.autoStart = true,
    this.autoStop = true,
    this.onBarcodeDetected,
  });

  /// 是否可控制闪光灯
  final bool showFlashToggle;

  /// 是否显示开始停止按钮
  final bool showStartStopButton;

  /// 是否开始扫描
  final bool autoStart;

  /// 扫描到二维码后是否停止扫描
  final bool autoStop;

  /// 扫描到二维码后的回调
  final dynamic Function(String code, String type)? onBarcodeDetected;

  @override
  State<QRScanWidget> createState() => _QRScanWidgetState();
}

class _QRScanWidgetState extends State<QRScanWidget> {
  @override
  Widget build(BuildContext context) {
    return UltraQrScannerWidget(
      onCodeDetected: (code, type) => handleQRCode(code, type),
      autoStart: widget.autoStart,
      autoStop: widget.autoStop,
      showStartStopButton: widget.showStartStopButton,
      showFlashToggle: widget.showFlashToggle,
      overlay: Stack(
        children: [
          // Semi-transparent background
          Container(color: Colors.black54),

          // Custom scanning frame
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green, width: 4),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                children: [
                  // Corner decorations
                  // ...buildCornerDecorations(),

                  // Center dot
                  Center(
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Custom instructions
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Icon(Icons.qr_code_scanner, color: Colors.white, size: 48),
                SizedBox(height: 16),
                Text(
                  'Scan QR Code',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Position the QR code within the frame',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void handleQRCode(String qrCode, String type) {
    widget.onBarcodeDetected?.call(qrCode, type);
    debugPrint('扫描到二维码: $qrCode, 类型: $type');
    Navigator.pop(context);
  }
}

class ScannerOverlay extends CustomPainter {
  const ScannerOverlay({required this.scanWindow, this.borderRadius = 12.0});

  final Rect scanWindow;
  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    // we need to pass the size to the custom paint widget
    final backgroundPath = Path()..addRect(Rect.largest);

    final cutoutPath = Path()
      ..addRRect(
        RRect.fromRectAndCorners(
          scanWindow,
          topLeft: Radius.circular(borderRadius),
          topRight: Radius.circular(borderRadius),
          bottomLeft: Radius.circular(borderRadius),
          bottomRight: Radius.circular(borderRadius),
        ),
      );

    final backgroundPaint = Paint()
      ..color = Colors.red.withAlpha(128)
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.dstOut;

    final backgroundWithCutout = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );

    // final borderPaint = Paint()
    //   ..color = Colors.white
    //   ..style = PaintingStyle.stroke
    //   ..strokeWidth = 4.0;

    // final borderRect = RRect.fromRectAndCorners(
    //   scanWindow,
    //   topLeft: Radius.circular(borderRadius),
    //   topRight: Radius.circular(borderRadius),
    //   bottomLeft: Radius.circular(borderRadius),
    //   bottomRight: Radius.circular(borderRadius),
    // );

    // First, draw the background,
    // with a cutout area that is a bit larger than the scan window.
    // Finally, draw the scan window itself.
    canvas.drawPath(backgroundWithCutout, backgroundPaint);
    // canvas.drawRRect(borderRect, borderPaint);
  }

  @override
  bool shouldRepaint(ScannerOverlay oldDelegate) {
    return scanWindow != oldDelegate.scanWindow ||
        borderRadius != oldDelegate.borderRadius;
  }
}

class MyCustomPainter extends CustomPainter {
  final Rect? scanWindow;

  MyCustomPainter({super.repaint, this.scanWindow});

  @override
  void paint(Canvas canvas, Size size) {
    const innerRectWidth = 300.0;
    const innerRectHeight = 300.0;

    /// outerRect铺满整个屏幕
    final outerRect = Offset.zero & size;

    var innerRect = Rect.fromCenter(
      center: size.center(Offset.zero),
      width: innerRectWidth,
      height: innerRectHeight,
    );

    final borderRadius = BorderRadius.circular(10); // 设置圆角半径
    final rrect = RRect.fromRectAndCorners(
      innerRect,
      topLeft: borderRadius.topLeft,
      topRight: borderRadius.topRight,
      bottomLeft: borderRadius.bottomLeft,
      bottomRight: borderRadius.bottomRight,
    );

    final paint = Paint()
      ..color = Colors.black.withAlpha(128)
      ..style = PaintingStyle.fill;

    canvas.drawRect(outerRect, paint);

    final clearPaint = Paint()
      ..blendMode = BlendMode.clear
      ..style = PaintingStyle.fill;

    canvas.drawRRect(rrect, clearPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
