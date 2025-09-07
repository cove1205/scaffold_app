import 'package:dio/dio.dart';

const _kShowLoadingKey = 'show_loading';
const _kDisableRetryKey = 'disable_retry';

/// 请求选项扩展
extension RequestOptionsX on RequestOptions {
  static const _kAttemptKey = 'attempt_retry';

  static const _kAttemptLeftKey = 'attempt_left';

  int get attemptLeft => (extra[_kAttemptLeftKey] as int?) ?? -1;

  set attemptLeft(int value) => extra[_kAttemptLeftKey] = value;

  bool get disableRetry => (extra[_kDisableRetryKey] as bool?) ?? false;

  set disableRetry(bool value) => extra[_kDisableRetryKey] = value;

  int get attempt => (extra[_kAttemptKey] as int?) ?? 0;

  set attempt(int value) => extra[_kAttemptKey] = value;

  bool get showLoading => (extra[_kShowLoadingKey] as bool?) ?? true;

  set showLoading(bool value) => extra[_kShowLoadingKey] = value;
}

/// 选项扩展
extension OptionsX on Options {
  bool get disableRetry => (extra?[_kDisableRetryKey] as bool?) ?? false;

  set disableRetry(bool value) {
    extra = Map.of(extra ??= <String, dynamic>{});
    extra![_kDisableRetryKey] = value;
  }

  bool get showLoading => (extra?[_kShowLoadingKey] as bool?) ?? true;

  set showLoading(bool value) {
    extra = Map.of(extra ??= <String, dynamic>{});
    extra![_kShowLoadingKey] = value;
  }
}
