import 'package:core_network/core_network.dart';
import 'package:core_network/interceptors/http_status_codes.dart';
import 'package:core_utils/log_util.dart';
import 'package:core_utils/storage_util.dart';

/// 请求结果拦截器
class ResInterceptor extends Interceptor {
  ResInterceptor();

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    Response res = Response(
      requestOptions: response.requestOptions,
      statusMessage: response.statusMessage,
      statusCode: response.statusCode,
      data: response.data['data'] ?? response.data,
    );

    if (res.statusCode == 200) {
      handler.next(res);
    } else {
      DioException error = DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
      );
      handler.reject(error, true);
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // String? errMsg;

    // switch (err.type) {
    //   case DioExceptionType.cancel:
    //     break;
    //   case DioExceptionType.connectionTimeout:
    //     errMsg = "链接超时，请检查网络！";
    //     break;
    //   case DioExceptionType.connectionError:
    //     errMsg = '链接错误，请重试！';
    //     break;
    //   case DioExceptionType.receiveTimeout:
    //     errMsg = '响应超时，请稍等片刻重试！';
    //     break;
    //   case DioExceptionType.sendTimeout:
    //     errMsg = '发送超时，请重试！';
    //     break;
    //   case DioExceptionType.badResponse:
    //     errMsg = '发生未知错误，请联系管理员';
    //     break;
    //   case DioExceptionType.badCertificate:
    //     errMsg = '发生未知错误，请联系管理员';
    //     break;
    //   case DioExceptionType.unknown:
    //     errMsg = '未知错误，请检查网络连接';
    //     break;
    // }

    // String logMsg =
    //     "URL--->${err.requestOptions.uri} -- $errMsg ${err.message} ";

    // if (errMsg != null) {
    //   LogUtil.error(logMsg);
    //   // ToastManager.show(errMsg);
    // }
    super.onError(err, handler);
  }
}

/// token拦截器
/// 负责处理accessToken的装载和刷新
class TokenRefreshInterceptor extends Interceptor {
  // 防止重复刷新token的标志
  bool _isRefreshing = false;

  // 存储等待刷新token完成的请求队列
  final List<Function> _pendingRequests = [];

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    /// 在请求头中添加 accessToken
    String? token = StorageUtil.getValue('accessToken');
    options.headers["accessToken"] = token;
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    // 检查响应中的code是否为401（token失效）
    if (response.data != null &&
        response.data is Map &&
        response.data["code"] == status401Unauthorized) {
      void retryFunction() async {
        LogUtil.info('重新发送原请求: ${response.requestOptions.path}');
        try {
          final retryResponse = await networkClient.retry(
            response.requestOptions,
          );
          LogUtil.info('重试请求成功，状态码: ${retryResponse.statusCode}');
          handler.resolve(retryResponse);
        } catch (e) {
          // 重试失败不应触发登出，直接向上抛出错误
          LogUtil.error('重试原请求失败: $e');
          handler.reject(
            DioException(requestOptions: response.requestOptions, error: e),
          );
        }
      }

      // 如果正在刷新token，将当前请求加入队列
      if (_isRefreshing) {
        _pendingRequests.add(retryFunction);
        return;
      }

      // 开始刷新token
      _isRefreshing = true;
      _pendingRequests.add(retryFunction);

      try {
        final refreshToken = await StorageUtil.getValue('refreshToken');
        if (refreshToken == null || refreshToken.isEmpty) {
          // 没有refreshToken，跳转到登录页
          _handleLoginRequired();
          handler.reject(
            DioException(
              requestOptions: response.requestOptions,
              response: response,
              type: DioExceptionType.badResponse,
            ),
          );
          return;
        }

        // 调用刷新token接口（带重试机制）
        LogUtil.info('开始刷新token...');
        final tokenData = await _refreshTokenWithRetry(refreshToken);
        LogUtil.info('刷新token结果: $tokenData');

        if (tokenData.isNotEmpty && tokenData['accessToken'] != null) {
          LogUtil.info('获取到新token，保存和重试请求...');
          // 保存新的token
          await StorageUtil.setValue('accessToken', tokenData['accessToken']);
          if (tokenData['refreshToken'] != null) {
            await StorageUtil.setValue(
              'refreshToken',
              tokenData['refreshToken'],
            );
          }
        } else {
          // 刷新token失败，跳转到登录页
          _handleLoginRequired();
          handler.reject(
            DioException(
              requestOptions: response.requestOptions,
              response: response,
              type: DioExceptionType.badResponse,
            ),
          );
        }
      } catch (e) {
        // 刷新token出错，跳转到登录页
        _handleLoginRequired();
        handler.reject(
          DioException(requestOptions: response.requestOptions, error: e),
        );
      } finally {
        _isRefreshing = false;
      }

      // 处理等待队列中的请求
      LogUtil.info('处理等待队列中的请求，队列长度: ${_pendingRequests.length}');
      final List<Function> requestsToProcess = List.from(_pendingRequests);
      _pendingRequests.clear();
      // 逐个处理等待队列中的请求
      for (int i = 0; i < requestsToProcess.length; i++) {
        try {
          LogUtil.info('处理等待队列中的第${i + 1}个请求');
          await requestsToProcess[i]();
          LogUtil.info('等待队列中的第${i + 1}个请求处理完成');
        } catch (e) {
          LogUtil.error('处理等待队列中的第${i + 1}个请求时发生错误: $e');
        }
      }
      LogUtil.info('所有等待队列中的请求处理完成');
    } else {
      // 非401响应，直接通过
      handler.next(response);
    }
  }

  /// 刷新token方法
  Future<Map<String, dynamic>> _refreshTokenWithRetry(
    String refreshToken,
  ) async {
    return {};
  }

  /// 处理需要重新登录的情况
  void _handleLoginRequired() async {
    // 清除所有token
    await StorageUtil.removeValue('accessToken');
    await StorageUtil.removeValue('refreshToken');

    // 显示提示信息
    // ToastManager.show("登录已过期，请重新登录");

    // 跳转到登录页
    // logoutAndClearData();
  }
}
