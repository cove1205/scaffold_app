import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'dart:ui' as ui show Image, Codec, FrameInfo;
import 'dart:ui'
    show instantiateImageCodec, PictureRecorder, Picture, ImageByteFormat;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show NetworkAssetBundle, rootBundle;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path_provider/path_provider.dart' show getTemporaryDirectory;

/// 图片类型枚举
enum ImageType {
  /// 普通图片类型
  normal(['png', 'jpg', 'jpeg', 'bmp', 'webp', 'exif']),

  /// svg图片类型
  svg(['svg']),

  /// gif图片类型
  gif(['gif']),

  /// 未知图片类型
  unknown([]);

  /// 后缀列表
  final List<String> suffixList;

  const ImageType(this.suffixList);

  /// 根据后缀判断图片类型
  static ImageType fromSuffix(String suffix) {
    return values.firstWhere(
      (v) => v.suffixList.contains(suffix),
      orElse: () => ImageType.unknown,
    );
  }

  /// 根据路径判断图片类型
  static ImageType fromPath(String url) {
    if (url.isEmpty || url.split('.').isEmpty) return ImageType.unknown;
    String suffix = url.split('.').last;
    return ImageType.fromSuffix(suffix);
  }

  bool get isSvg => this == ImageType.svg;
}

typedef PlaceholderBuilder = Widget Function(BuildContext);

abstract class ImageUtil {
  static Widget _defaultPlaceholder(double? width, double? height) {
    return SizedBox(width: width, height: height);
  }

  ///  加载本地资源图片
  static Widget asset(
    String assetPath, {
    Color? color,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    AlignmentGeometry alignment = Alignment.center,
    PlaceholderBuilder? placeholderBuilder,
    String? package,
  }) {
    ImageType type = ImageType.fromPath(assetPath);
    if (type.isSvg) {
      return SvgPicture.asset(
        assetPath,
        colorFilter: color == null
            ? null
            : ColorFilter.mode(color, BlendMode.srcIn),
        width: width,
        height: height,
        fit: fit,
        alignment: alignment,
        package: package,
        placeholderBuilder: (context) =>
            placeholderBuilder?.call(context) ??
            _defaultPlaceholder(width, height),
      );
    } else {
      return Image.asset(
        assetPath,
        color: color,
        width: width,
        height: height,
        fit: fit,
        alignment: alignment,
        package: package,
        errorBuilder: (context, _, _) =>
            placeholderBuilder?.call(context) ??
            _defaultPlaceholder(width, height),
      );
    }
  }

  /// 加载本地图片文件
  static Widget file(
    File file, {
    Color? color,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    AlignmentGeometry alignment = Alignment.center,
    PlaceholderBuilder? placeholderBuilder,
  }) {
    ImageType type = ImageType.fromPath(file.path);
    if (type.isSvg) {
      return SvgPicture.file(
        file,
        colorFilter: color == null
            ? null
            : ColorFilter.mode(color, BlendMode.srcIn),
        width: width,
        height: height,
        fit: fit,
        alignment: alignment,
        placeholderBuilder: (context) =>
            placeholderBuilder?.call(context) ??
            _defaultPlaceholder(width, height),
      );
    } else {
      return Image.file(
        file,
        color: color,
        width: width,
        height: height,
        fit: fit,
        alignment: alignment,
        errorBuilder: (context, _, _) =>
            placeholderBuilder?.call(context) ??
            _defaultPlaceholder.call(width, height),
      );
    }
  }

  /// 加载网络图片
  static Widget network(
    String imageUrl, {
    Color? color,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    AlignmentGeometry alignment = Alignment.center,
    PlaceholderBuilder? placeholderBuilder,
  }) {
    if (imageUrl.isEmpty) {
      return Builder(
        builder: (context) {
          return placeholderBuilder?.call(context) ??
              _defaultPlaceholder(width, height);
        },
      );
    }
    ImageType type = ImageType.fromPath(imageUrl);
    if (type.isSvg) {
      return SvgPicture.network(
        imageUrl,
        colorFilter: color == null
            ? null
            : ColorFilter.mode(color, BlendMode.srcIn),
        width: width,
        height: height,
        fit: fit,
        alignment: alignment,
        placeholderBuilder: (context) =>
            placeholderBuilder?.call(context) ??
            _defaultPlaceholder(width, height),
      );
    } else {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        height: height,
        width: width,
        fit: fit,
        // placeholder: (context, url) {
        //   return placeholderBuilder?.call(context) ??
        //       _defaultPlaceholder(width, height);
        // },
        errorWidget: (context, url, error) {
          return placeholderBuilder?.call(context) ??
              _defaultPlaceholder(width, height);
        },
      );
    }
  }

  static ImageProvider assetsProvider(
    String asssetPath, {
    Size? size,
    double scale = 1.0,
  }) {
    ImageType type = ImageType.fromPath(asssetPath);

    if (type.isSvg) {
      return SvgProvider(
        asssetPath,
        color: Colors.red,
        scale: scale,
        source: SvgSource.asset,
        size: size,
      );
    } else {
      return AssetImage(asssetPath);
    }
  }

  static ImageProvider networkProvider(
    String imageUrl, {
    Size? size,
    double scale = 1.0,
  }) {
    ImageType type = ImageType.fromPath(imageUrl);

    if (type == ImageType.unknown) {
      return CachedNetworkImageProvider(
        imageUrl,
        scale: scale,
        maxWidth: size?.width.toInt(),
        maxHeight: size?.height.toInt(),
      );
    }

    if (type.isSvg) {
      return SvgProvider(
        imageUrl,
        scale: scale,
        source: SvgSource.network,
        size: size,
      );
    } else {
      return CachedNetworkImageProvider(
        imageUrl,
        scale: scale,
        maxWidth: size?.width.toInt(),
        maxHeight: size?.height.toInt(),
      );
    }
  }
}

/// Get svg string.
typedef SvgStringGetter = Future<String?> Function(SvgImageKey key);

/// An [Enum] of the possible image path sources.
enum SvgSource { file, asset, network }

/// Rasterizes given svg picture for displaying in [Image] widget:
///
/// ```dart
/// Image(
///   width: 32,
///   height: 32,
///   image: Svg('assets/my_icon.svg'),
/// )
/// ```
class SvgProvider extends ImageProvider<SvgImageKey> {
  /// Path to svg file or asset
  final String path;

  /// Size in logical pixels to render.
  /// Useful for [DecorationImage].
  /// If not specified, will use size from [Image].
  /// If [Image] not specifies size too, will use default size 100x100.
  final Size? size;

  /// Color to tint the SVG
  final Color? color;

  /// Source of svg image
  final SvgSource source;

  /// Image scale.
  final double? scale;

  /// Get svg string.
  /// Override the default get method.
  /// When returning null, use the default method.
  final SvgStringGetter? svgGetter;

  /// Width and height can also be specified from [Image] constructor.
  /// Default size is 100x100 logical pixels.
  /// Different size can be specified in [Image] parameters
  const SvgProvider(
    this.path, {
    this.size,
    this.scale,
    this.color,
    this.source = SvgSource.asset,
    this.svgGetter,
  });

  @override
  Future<SvgImageKey> obtainKey(ImageConfiguration configuration) {
    final Color color = this.color ?? Colors.transparent;
    final double scale = this.scale ?? configuration.devicePixelRatio ?? 1.0;
    final double logicWidth = size?.width ?? configuration.size?.width ?? 100;
    final double logicHeight = size?.height ?? configuration.size?.width ?? 100;

    return SynchronousFuture<SvgImageKey>(
      SvgImageKey(
        path: path,
        scale: scale,
        color: color,
        source: source,
        pixelWidth: (logicWidth * scale).round(),
        pixelHeight: (logicHeight * scale).round(),
        svgGetter: svgGetter,
      ),
    );
  }

  @override
  ImageStreamCompleter loadBuffer(SvgImageKey key, decode) {
    return OneFrameImageStreamCompleter(_loadAsync(key));
  }

  // @override
  // ImageStreamCompleter load(SvgImageKey key, decode) {
  //   return OneFrameImageStreamCompleter(_loadAsync(key));
  // }

  static Future<String> _getSvgString(SvgImageKey key) async {
    if (key.svgGetter != null) {
      final rawSvg = await key.svgGetter!.call(key);
      if (rawSvg != null) {
        return rawSvg;
      }
    }
    switch (key.source) {
      case SvgSource.network:
        final data = await NetworkAssetBundle(
          Uri.parse(key.path),
        ).load(key.path);
        final bytes = data.buffer.asUint8List();
        return utf8.decode(bytes);
      // return await http.read(Uri.parse(key.path));
      case SvgSource.asset:
        return await rootBundle.loadString(key.path);
      case SvgSource.file:
        return await File(key.path).readAsString();
    }
  }

  static Future<ImageInfo> _loadAsync(SvgImageKey key) async {
    final String rawSvg = await _getSvgString(key);
    final pictureInfo = await vg.loadPicture(
      SvgStringLoader(rawSvg),
      null,
      clipViewbox: true,
    );
    final ui.Image image = await pictureInfo.picture.toImage(
      pictureInfo.size.width.round(),
      pictureInfo.size.height.round(),
    );

    return ImageInfo(image: image, scale: 1.0);
  }

  // Note: == and hashCode not overrided as changes in properties
  // (width, height and scale) are not observable from the here.
  // [SvgImageKey] instances will be compared instead.
  @override
  String toString() => '$runtimeType(${describeIdentity(path)})';

  // Running on web with Colors.transparent may throws the exception `Expected a value of type 'SkDeletable', but got one of type 'Null'`.
  static Color getFilterColor(Color? color) {
    if (kIsWeb && color == Colors.transparent) {
      return const Color(0x01ffffff);
    } else {
      return color ?? Colors.transparent;
    }
  }

  /// 给图片添加多行水印（左下角位置）
  static Future<Uint8List> addWatermark({
    required Uint8List imageBytes,
    required List<String> watermarkLines,
    Color watermarkColor = Colors.white,
    int watermarkOpacity = 204, // 提高默认透明度
    double watermarkFontSize = 18, // 调整默认字体大小
    Color backgroundColor = Colors.black,
    int backgroundOpacity = 178, // 调整背景透明度
    EdgeInsets padding = const EdgeInsets.all(18), // 增加内边距
  }) async {
    // 解码图片
    final ui.Codec codec = await instantiateImageCodec(imageBytes);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    final ui.Image image = frameInfo.image;
    final double imageWidth = image.width.toDouble();
    final double imageHeight = image.height.toDouble();

    // 创建画布
    final PictureRecorder recorder = PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    canvas.drawImage(image, Offset.zero, Paint());

    // 设置水印文字样式（使用系统默认字体，支持中文）
    final textStyle = TextStyle(
      color: watermarkColor.withAlpha(watermarkOpacity),
      fontSize: watermarkFontSize,
      fontFamily: 'System', // 使用系统默认字体（自动适配中文）
    );

    // 构建文本段落
    final String watermarkText = watermarkLines.join('\n');
    final textSpan = TextSpan(text: watermarkText, style: textStyle);

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(maxWidth: imageWidth * 0.6); // 限制宽度为图片宽度的60%

    // **计算左下角位置**
    final double x = padding.left; // 左侧内边距
    final double y = imageHeight - textPainter.height - padding.bottom; // 底部内边距
    final Offset watermarkPosition = Offset(x, y);

    // 计算背景区域（包裹文本）
    final double backgroundWidth = textPainter.width + padding.horizontal;
    final double backgroundHeight = textPainter.height + padding.vertical;
    final Rect backgroundRect = Rect.fromLTWH(
      watermarkPosition.dx - padding.left, // 背景左侧与文本左侧对齐
      watermarkPosition.dy - padding.top, // 背景顶部与文本顶部对齐
      backgroundWidth,
      backgroundHeight,
    );

    // 绘制半透明背景
    final Paint backgroundPaint = Paint()
      ..color = backgroundColor.withAlpha(backgroundOpacity)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 2); // 轻微模糊效果
    canvas.drawRRect(
      RRect.fromRectAndRadius(backgroundRect, Radius.circular(8)), // 圆角背景
      backgroundPaint,
    );

    // 绘制文本（左下角对齐，居中显示）
    textPainter.paint(
      canvas,
      Offset(
        watermarkPosition.dx, // X坐标：左侧内边距
        watermarkPosition.dy, // Y坐标：底部内边距 + 文本高度
      ),
    );

    // 完成绘制
    final Picture picture = recorder.endRecording();
    final ui.Image watermarkedImage = await picture.toImage(
      image.width,
      image.height,
    );

    // 转换为字节数据
    final ByteData? byteData = await watermarkedImage.toByteData(
      format: ImageByteFormat.png,
    );
    image.dispose();
    watermarkedImage.dispose();

    return byteData!.buffer.asUint8List();
  }

  /// 保存带水印的图片到文件
  static Future<File> saveWatermarkedImage({
    required Uint8List imageBytes,
    required List<String> watermarkLines,
    Color watermarkColor = Colors.white,
    int watermarkOpacity = 204,
    double watermarkFontSize = 16,
    Color backgroundColor = Colors.black,
    int backgroundOpacity = 122,
    EdgeInsets padding = const EdgeInsets.all(12),
  }) async {
    final Uint8List watermarkedBytes = await addWatermark(
      imageBytes: imageBytes,
      watermarkLines: watermarkLines,
      watermarkColor: watermarkColor,
      watermarkOpacity: watermarkOpacity,
      watermarkFontSize: watermarkFontSize,
      backgroundColor: backgroundColor,
      backgroundOpacity: backgroundOpacity,
      padding: padding,
    );

    Directory tempD = await getTemporaryDirectory();

    String? tempDir = tempD.path;
    final File file = File(
      '$tempDir/watermarked_${DateTime.now().millisecondsSinceEpoch}.png',
    );
    await file.writeAsBytes(watermarkedBytes);
    return file;
  }
}

@immutable
class SvgImageKey {
  const SvgImageKey({
    required this.path,
    required this.pixelWidth,
    required this.pixelHeight,
    required this.scale,
    required this.source,
    this.color,
    this.svgGetter,
  });

  /// Path to svg asset.
  final String path;

  /// Width in physical pixels.
  /// Used when raterizing.
  final int pixelWidth;

  /// Height in physical pixels.
  /// Used when raterizing.
  final int pixelHeight;

  /// Color to tint the SVG
  final Color? color;

  /// Image source.
  final SvgSource source;

  /// Used to calculate logical size from physical, i.e.
  /// logicalWidth = [pixelWidth] / [scale],
  /// logicalHeight = [pixelHeight] / [scale].
  /// Should be equal to [MediaQueryData.devicePixelRatio].
  final double scale;

  /// Svg string getter.
  final SvgStringGetter? svgGetter;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }

    return other is SvgImageKey &&
        other.path == path &&
        other.pixelWidth == pixelWidth &&
        other.pixelHeight == pixelHeight &&
        other.scale == scale &&
        other.source == source &&
        other.svgGetter == svgGetter;
  }

  @override
  int get hashCode =>
      Object.hash(path, pixelWidth, pixelHeight, scale, source, svgGetter);

  @override
  String toString() =>
      '${objectRuntimeType(this, 'SvgImageKey')}'
      '(path: "$path", pixelWidth: $pixelWidth, pixelHeight: $pixelHeight, scale: $scale, source: $source)';
}
