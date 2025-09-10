import 'dart:async';

import 'interceptors/retry_interceptor.dart';
import 'package:dio/dio.dart';
import 'status_codes.dart';

export 'package:dio/dio.dart';

part 'exception.dart';
part 'request.dart';
part 'response.dart';

typedef Decoder<T> = T Function(Map<String, dynamic>);

class NetworkClient {
  NetworkClient._() : _dio = Dio();

  static Dio get dio => _instance._dio;

  factory NetworkClient() => _instance;

  static final NetworkClient _instance = NetworkClient._();

  final Dio _dio;

  /// 初始化
  /// 设置全局请求参数
  static void init({
    String baseUrl = '',
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Duration? sendTimeout,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? extra,
    Map<String, dynamic>? headers,
    List<Interceptor> interceptors = const [],
  }) {
    final dio = _instance._dio;
    dio.options = dio.options.copyWith(
      baseUrl: baseUrl,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      sendTimeout: sendTimeout,
      queryParameters: queryParameters,
      extra: extra,
      headers: headers,
    );

    dio.interceptors.addAll(interceptors);
  }

  /// 添加全局请求头
  void addHeaders(Map<String, dynamic> headers) {
    _instance._dio.options.headers.addAll(headers);
  }

  /// 移除全局请求头
  void removeHeader(String key) {
    _instance._dio.options.headers.remove(key);
  }

  /// 添加拦截器
  void addInterceptor(List<Interceptor> interceptors) {
    _instance._dio.interceptors.addAll(interceptors);
  }

  /// 移除拦截器
  void removeInterceptor(Interceptor interceptor) {
    _instance._dio.interceptors.remove(interceptor);
  }

  /// 基础请求
  /// [req] 请求体构建对象
  /// [retry] 是否重试
  Future<NetworkResponse> fetch<T>(
    NetworkRequest req, {
    bool retry = false,
  }) async {
    try {
      Response response = await _dio.request(
        req.apiPath,
        data: req.data,
        queryParameters: req.queryParams,
        cancelToken: req.cancelToken,
        options: req.optiopns..disableRetry = !retry,
        onSendProgress: req.onSendProgress,
        onReceiveProgress: req.onReceiveProgress,
      );

      return NetworkResponse.fromResponse(response);
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } on Error catch (e) {
      throw NetworkException.fromError(e);
    }
  }

  /// 上传
  Future<dynamic> upload(UploadRequset req, {bool retry = false}) async =>
      fetch(req, retry: retry);

  /// 下载
  Future<NetworkResponse> download(
    DownloadRequest req, {
    bool retry = false,
  }) async {
    try {
      Response response = await _dio.download(
        req.apiPath,
        req.savePath,
        data: req.data,
        queryParameters: req.queryParams,
        onReceiveProgress: req.onReceiveProgress,
        cancelToken: req.cancelToken,
        deleteOnError: req.deleteOnError,
        options: req.optiopns..disableRetry = !retry,
      );
      return NetworkResponse.fromResponse(response);
    } on DioException catch (e) {
      throw NetworkException.fromDioException(e);
    } on Error catch (e) {
      throw NetworkException.fromError(e);
    }
  }

  /// 重试请求
  Future<Response<T>> retry<T>(RequestOptions requestOptions) async {
    Response<T> response = await _dio.request(
      requestOptions.path,
      data: requestOptions.data is FormData
          ? (requestOptions.data as FormData).clone()
          : requestOptions.data,
      queryParameters: Map<String, dynamic>.from(
        requestOptions.queryParameters,
      ),
      cancelToken: requestOptions.cancelToken,
      options: Options(
        method: requestOptions.method,
        headers: requestOptions.headers,
        extra: Map<String, dynamic>.from(requestOptions.extra),
      ),
      onSendProgress: requestOptions.onSendProgress,
      onReceiveProgress: requestOptions.onReceiveProgress,
    );

    return response;
  }
}
