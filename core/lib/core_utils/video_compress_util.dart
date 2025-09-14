import 'dart:async';

import 'package:v_video_compressor/v_video_compressor.dart';

/// 视频压缩进度回调事件
class VideoCompressEvent extends VVideoProgressEvent {
  const VideoCompressEvent({
    required super.progress,
    super.videoPath,
    super.currentIndex,
    super.total,
    super.compressionId,
  });
}

/// 视频压缩配置
class VideoCompressConfig extends VVideoCompressionConfig {
  VideoCompressConfig({
    required super.quality,
    VideoCompressAdvancedConfig? advanced,
    super.outputPath,
    super.deleteOriginal,
    super.saveToGallery,
    super.includeAudio,
    super.includeMetadata,
    super.optimizeForStreaming,
    super.useHardwareAcceleration,
    super.useFastStart,
    super.useTwoPassEncoding,
    super.useVariableBitrate,
    super.copyMetadata,
  }) : super(advanced: advanced);

  factory VideoCompressConfig.high() =>
      VideoCompressConfig(quality: VVideoCompressQuality.high);
  factory VideoCompressConfig.medium() =>
      VideoCompressConfig(quality: VVideoCompressQuality.medium);
  factory VideoCompressConfig.low() =>
      VideoCompressConfig(quality: VVideoCompressQuality.low);
  factory VideoCompressConfig.veryLow() =>
      VideoCompressConfig(quality: VVideoCompressQuality.veryLow);
  factory VideoCompressConfig.ultraLow() =>
      VideoCompressConfig(quality: VVideoCompressQuality.ultraLow);
}

/// 视频压缩进阶配置
class VideoCompressAdvancedConfig extends VVideoAdvancedConfig {
  // final advancedConfig = VVideoAdvancedConfig(
  //   // Resolution & Quality
  //   customWidth: 1280,
  //   customHeight: 720,
  //   videoBitrate: 2000000, // 2 Mbps
  //   frameRate: 30.0, // 30 FPS
  //   // Codec & Encoding
  //   videoCodec: VVideoCodec.h265, // Better compression
  //   audioCodec: VAudioCodec.aac,
  //   encodingSpeed: VEncodingSpeed.medium,
  //   crf: 25, // Quality factor (lower = better)
  //   twoPassEncoding: true, // Better quality
  //   hardwareAcceleration: true, // Use GPU
  //   // Audio Settings
  //   audioBitrate: 128000, // 128 kbps
  //   audioSampleRate: 44100, // 44.1 kHz
  //   audioChannels: 2, // Stereo
  //   // Video Effects
  //   brightness: 0.1, // Slight brightness boost
  //   contrast: 0.05, // Slight contrast increase
  //   saturation: 0.1, // Slight saturation increase
  //   // Editing
  //   trimStartMs: 2000, // Skip first 2 seconds
  //   trimEndMs: 60000, // End at 1 minute
  //   rotation: 90, // Rotate 90 degrees
  // );

  factory VideoCompressAdvancedConfig.maxCompression({
    int? targetBitrate,
    bool keepAudio = false,
  }) =>
      VVideoAdvancedConfig.maximumCompression(
            targetBitrate: targetBitrate,
            keepAudio: keepAudio,
          )
          as VideoCompressAdvancedConfig;

  factory VideoCompressAdvancedConfig.socialMediaOptimized() =>
      VVideoAdvancedConfig.socialMediaOptimized()
          as VideoCompressAdvancedConfig;

  factory VideoCompressAdvancedConfig.mobileOptimized() =>
      VVideoAdvancedConfig.mobileOptimized() as VideoCompressAdvancedConfig;
}

/// 视频压缩结果
class VideoCompressionResult extends VVideoCompressionResult {
  VideoCompressionResult({
    required super.originalVideo,
    required super.compressedFilePath,
    required super.originalSizeBytes,
    required super.compressedSizeBytes,
    required super.compressionRatio,
    required super.timeTaken,
    required super.quality,
    required super.originalResolution,
    required super.compressedResolution,
    required super.spaceSaved,
  });

  factory VideoCompressionResult._fromResult(VVideoCompressionResult result) =>
      VideoCompressionResult(
        originalVideo: result.originalVideo,
        compressedFilePath: result.compressedFilePath,
        originalSizeBytes: result.originalSizeBytes,
        compressedSizeBytes: result.compressedSizeBytes,
        compressionRatio: result.compressionRatio,
        timeTaken: result.timeTaken,
        quality: result.quality,
        originalResolution: result.originalResolution,
        compressedResolution: result.compressedResolution,
        spaceSaved: result.spaceSaved,
      );
}

/// 视频压缩工具类
/// 使用v_video_compressor库进行视频压缩
class VideoCompressUtil {
  VideoCompressUtil._();

  static StreamController<VideoCompressEvent>? _videoCompressEventController;

  /// 压缩视频
  static Future<VideoCompressionResult?> compressVideo(
    String videoPath,
    VideoCompressConfig config, {
    String? id,
    void Function(double progress)? onProgress,
  }) async {
    final VVideoCompressor _compressor = VVideoCompressor();
    final compressionResult = await _compressor.compressVideo(
      videoPath,
      config,
      id: id,
      onProgress: onProgress,
    );

    if (compressionResult == null) {
      return null;
    }

    return VideoCompressionResult._fromResult(compressionResult);
  }

  /// Simple progress callback
  static void listenToProgress(
    onProgress, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) => VVideoCompressor.listenToProgress(
    onProgress,
    onError: onError,
    onDone: onDone,
    cancelOnError: cancelOnError,
  );

  /// Batch progress callback
  static void listenToBatchProgress(
    void Function(double progress, int currentIndex, int total) onBatchProgress,
  ) => VVideoCompressor.listenToBatchProgress(onBatchProgress);

  /// Full event callback
  static void listen(void Function(VideoCompressEvent event) onEvent) =>
      VideoCompressUtil.compressProgressListener(onEvent);

  /// 添加全局视频压缩进度监听
  ///
  /// [onData] 视频压缩进度回调
  static StreamSubscription<VideoCompressEvent> compressProgressListener(
    void Function(VideoCompressEvent event) onData,
  ) {
    if (_videoCompressEventController == null) {
      _videoCompressEventController = StreamController.broadcast();

      VVideoCompressor.progressStream.listen((VVideoProgressEvent event) {
        _videoCompressEventController!.sink.add(
          VideoCompressEvent(
            progress: event.progress,
            videoPath: event.videoPath,
            currentIndex: event.currentIndex,
            total: event.total,
            compressionId: event.compressionId,
          ),
        );
      });
    }

    // 创建一个用于监听视频压缩进度的订阅器
    return _videoCompressEventController!.stream.listen(onData);
  }
}
