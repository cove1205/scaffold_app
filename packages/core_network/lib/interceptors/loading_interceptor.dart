import 'package:dio/dio.dart';
import 'extensions.dart';

/// loading拦截器 - 避免重试时闪烁
class LoadingInterceptor extends Interceptor {
  /// 显示loading的回调
  final void Function()? onShowLoading;

  /// 隐藏loading的回调
  final void Function()? onHideLoading;

  LoadingInterceptor({this.onShowLoading, this.onHideLoading});

  /// 存储正在重试的请求，避免重复显示loading
  final Set<String> _retryingRequests = {};

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // 检查是否需要显示loading
    if (options.showLoading) {
      if (options.disableRetry) {
        onShowLoading?.call();
        return handler.next(options);
      }

      final requestKey = _getRequestKey(options);
      // 只有在不是重试请求时才显示loading
      if (!_retryingRequests.contains(requestKey)) {
        onShowLoading?.call();
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // 请求成功，隐藏loading
    if (response.requestOptions.showLoading) {
      if (!response.requestOptions.disableRetry) {
        final requestKey = _getRequestKey(response.requestOptions);
        _retryingRequests.remove(requestKey);
      }
      onHideLoading?.call();
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.requestOptions.showLoading) {
      if (err.requestOptions.disableRetry) {
        // _retryingRequests.remove(requestKey);
        onHideLoading?.call();
        return handler.next(err);
      }

      final requestKey = _getRequestKey(err.requestOptions);

      /// 剩余尝试次数
      int attemptLeft = err.requestOptions.attemptLeft;
      if (attemptLeft == -1) {
        // 首次请求失败，此处必定会重试，所以保留loading
      } else if (attemptLeft == 0) {
        // 最后一次尝试失败，隐藏loading
        _retryingRequests.remove(requestKey);
        attemptLeft = -1;
        onHideLoading?.call();
      } else {
        // 中间尝试失败，保留loading
        _retryingRequests.add(requestKey);
      }
    }
    handler.next(err);
  }

  /// 生成请求的唯一标识
  String _getRequestKey(RequestOptions options) {
    return '${options.method}_${options.path}_${options.data.hashCode}';
  }
}
