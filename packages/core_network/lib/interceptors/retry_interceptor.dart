import 'dart:async';

import 'package:dio/dio.dart';
import 'http_status_codes.dart';
import 'extensions.dart';

/// 默认重试评估器
class DefaultRetryEvaluator {
  DefaultRetryEvaluator(this._retryableStatuses);

  final Set<int> _retryableStatuses;
  int currentAttempt = 0;

  /// Returns true only if the response hasn't been cancelled
  ///   or got a bad status code.
  // ignore: avoid-unused-parameters
  FutureOr<bool> evaluate(DioException error, int attempt) {
    bool shouldRetry;
    if (error.type == DioExceptionType.badResponse) {
      final statusCode = error.response?.statusCode;
      if (statusCode != null) {
        shouldRetry = isRetryable(statusCode);
      } else {
        shouldRetry = true;
      }
    } else {
      shouldRetry =
          error.type != DioExceptionType.cancel &&
          error.error is! FormatException;
    }
    currentAttempt = attempt;
    return shouldRetry;
  }

  bool isRetryable(int statusCode) => _retryableStatuses.contains(statusCode);
}

/// 重试评估器
typedef RetryEvaluator =
    FutureOr<bool> Function(DioException error, int attempt);

/// 重试拦截器
class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    required this.dio,
    this.logPrint,
    this.retries = 3,
    this.retryDelays = const [
      Duration(seconds: 1),
      Duration(seconds: 3),
      Duration(seconds: 5),
    ],
    RetryEvaluator? retryEvaluator,
    this.ignoreRetryEvaluatorExceptions = false,
    this.retryableExtraStatuses = const {},
  }) : _retryEvaluator =
           retryEvaluator ??
           DefaultRetryEvaluator({
             ...defaultRetryableStatuses,
             ...retryableExtraStatuses,
           }).evaluate {
    if (retryEvaluator != null && retryableExtraStatuses.isNotEmpty) {
      throw ArgumentError(
        '[retryableExtraStatuses] works only if [retryEvaluator] is null.'
            ' Set either [retryableExtraStatuses] or [retryEvaluator].'
            ' Not both.',
        'retryableExtraStatuses',
      );
    }
    if (retries < 0) {
      throw ArgumentError('[retries] cannot be less than 0', 'retries');
    }
  }

  /// The original dio
  final Dio dio;

  /// For logging purpose
  final void Function(String message)? logPrint;

  /// The number of retry in case of an error
  final int retries;

  /// Ignore exception if [_retryEvaluator] throws it (not recommend)
  final bool ignoreRetryEvaluatorExceptions;

  /// The delays between attempts.
  /// Empty [retryDelays] means no delay.
  ///
  /// If [retries] count more than [retryDelays] count,
  ///   the last element value of [retryDelays] will be used.
  final List<Duration> retryDelays;

  /// Evaluating if a retry is necessary.regarding the error.
  ///
  /// It can be a good candidate for additional operations too, like
  ///   updating authentication token in case of a unauthorized error
  ///   (be careful with concurrency though).
  ///
  /// Defaults to [DefaultRetryEvaluator.evaluate]
  ///   with [defaultRetryableStatuses].
  final RetryEvaluator _retryEvaluator;

  /// Specifies an extra retryable statuses,
  ///   which will be taken into account with [defaultRetryableStatuses]
  /// IMPORTANT: THIS SETTING WORKS ONLY IF [_retryEvaluator] is null
  final Set<int> retryableExtraStatuses;

  /// Redirects to [DefaultRetryEvaluator.evaluate]
  ///   with [defaultRetryableStatuses]
  static final FutureOr<bool> Function(DioException error, int attempt)
  defaultRetryEvaluator = DefaultRetryEvaluator(
    defaultRetryableStatuses,
  ).evaluate;

  Future<bool> _shouldRetry(DioException error, int attempt) async {
    try {
      return await _retryEvaluator(error, attempt);
    } catch (e) {
      logPrint?.call('There was an exception in _retryEvaluator: $e');
      if (!ignoreRetryEvaluatorExceptions) {
        rethrow;
      }
    }
    return true;
  }

  @override
  Future<dynamic> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // 原有的重试逻辑
    return _handleRetry(err, handler);
  }

  Future<dynamic> _handleRetry(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    var requestOptions = err.requestOptions;

    /// 检查是否需要重试
    final attempt = requestOptions.attempt + 1;

    final shouldRetry =
        !(requestOptions.cancelToken?.isCancelled ?? false) &&
        !requestOptions.disableRetry &&
        attempt <= retries &&
        await _shouldRetry(err, attempt);

    if (!shouldRetry) {
      logPrint?.call('请求不重试');
      super.onError(err, handler);
    }

    ///// 下面是重试逻辑 /////
    final delay = _getDelay(attempt);

    logPrint?.call(
      '[${requestOptions.path}] 请求发生错误!\n'
      '(重试中,尝试次数: $attempt/$retries,等待 ${delay.inMilliseconds} ms)\n '
      'error: ${err.error ?? err}',
    );

    requestOptions.attempt = attempt;
    requestOptions.attemptLeft = retries - attempt;
    if (delay != Duration.zero) {
      await Future<void>.delayed(delay);
    }

    requestOptions = _recreateOptions(requestOptions);

    try {
      await dio
          .fetch<void>(requestOptions)
          .then((value) => handler.resolve(value));
    } on DioException catch (e) {
      handler.reject(e);
    }
  }

  Duration _getDelay(int attempt) {
    if (retryDelays.isEmpty) return Duration.zero;
    return attempt - 1 < retryDelays.length
        ? retryDelays[attempt - 1]
        : retryDelays.last;
  }

  RequestOptions _recreateOptions(RequestOptions options) {
    late dynamic data;
    if (options.data is FormData) {
      data = (options.data as FormData).clone();
    } else {
      data = options.data;
    }

    return options.copyWith(
      data: data,
      queryParameters: options.queryParameters,
      headers: options.headers,
      extra: options.extra,
    );
  }
}
