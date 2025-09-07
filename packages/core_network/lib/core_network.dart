import 'dart:async';

import 'package:dio/dio.dart';
import 'interceptors/extensions.dart';

export 'package:dio/dio.dart';

part 'request.dart';
part 'response.dart';
part 'exception.dart';

typedef Decoder<T> = T Function(Map<String, dynamic>);

final networkClient = NetworkClient();

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
  /// [showLoading] 是否显示加载动画
  /// [decoder] 反序列化方法回调
  /// [listDecoder] 列表反序列化方法回调
  Future<NetworkResponse> fetch<T>(
    NetworkRequest req, {
    bool showLoading = true,
    bool retry = false,
    T Function(Map<String, dynamic>)? decoder,
    T Function(Map<String, dynamic>)? listDecoder,
  }) async {
    try {
      Response response = await _dio.request(
        req.apiPath,
        data: req.data,
        queryParameters: req.queryParams,
        cancelToken: req.cancelToken,
        options: req.optiopns
          ..showLoading = showLoading
          ..disableRetry = !retry,
        onSendProgress: req.onSendProgress,
        onReceiveProgress: req.onReceiveProgress,
      );

      // 对返回的数据进行序列化
      dynamic data;
      if (decoder != null) {
        data = _handleResponse(response.data, decoder);
      } else if (listDecoder != null) {
        data = _handleListResponse(response.data, listDecoder);
      } else {
        data = response.data;
      }

      return NetworkResponse(
        response.statusCode!,
        response.statusMessage!,
        data: data,
      );
    } on DioException catch (e) {
      NetworkException exception = NetworkException.fromDioException(e);
      return NetworkResponse(
        exception.statusCode,
        exception.message,
        exception: exception,
      );
    } on Error catch (e) {
      NetworkException exception = NetworkException.fromError(e);
      return NetworkResponse(
        exception.statusCode,
        exception.message,
        exception: NetworkException.fromError(e),
      );
    }
  }

  List<T> _handleListResponse<T>(List data, Decoder<T> decoder) {
    List<Map<String, dynamic>> dataList = data.cast<Map<String, dynamic>>();
    return dataList.map((e) => decoder(e)).toList();
  }

  T _handleResponse<T>(Map data, Decoder<T> decoder) {
    Map<String, dynamic> dataMap = data.cast<String, dynamic>();
    return decoder(dataMap);
  }

  /// 上传
  // Future<NetworkResponse> upload(String path,
  //     {dynamic data,
  //     void Function(int, int)? onSendProgress,
  //     Map<String, dynamic>? extra,
  //     Map<String, dynamic>? headers}) async {
  //   NetworkRequest req = NetworkRequest(path,
  //       method: ResquestMethod.post,
  //       data: data,
  //       extra: extra,
  //       headers: headers);
  //   return fetch(req);
  // }
  Future<NetworkResponse> upload(UploadRequset req) async {
    return fetch(req);
  }

  /// 下载
  Future<NetworkResponse> download(DownloadRequest req) async {
    try {
      Response response = await _dio.download(
        req.apiPath,
        req.savePath,
        data: req.data,
        queryParameters: req.queryParams,
        onReceiveProgress: req.onReceiveProgress,
        cancelToken: req.cancelToken,
        deleteOnError: req.deleteOnError,
        options: req.optiopns,
      );
      return NetworkResponse(
        response.statusCode!,
        response.statusMessage!,
        data: response.data,
        exception: null,
      );
    } on DioException catch (e) {
      NetworkException ex = NetworkException.fromDioException(e);
      return NetworkResponse(ex.statusCode!, ex.message, exception: ex);
    } on Error catch (e) {
      NetworkException ex = NetworkException.fromError(e);
      return NetworkResponse(ex.statusCode!, ex.message, exception: ex);
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
