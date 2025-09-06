import 'package:dio/dio.dart';
// import 'package:fpdart/fpdart.dart';

export 'package:dio/dio.dart';

part 'request.dart';
part 'response.dart';
part 'exception.dart';

// typedef NetworkRes = Either<NetworkException, NetworkResponse>;

typedef Decoder<T> = T Function(Map<String, dynamic>);

final networkClient = NetworkClient();

class NetworkClient {
  NetworkClient._() : _dio = Dio();

  factory NetworkClient() => _instance;

  static final NetworkClient _instance = NetworkClient._();

  final Dio _dio;

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
    dio.options
      ..baseUrl = baseUrl
      ..connectTimeout = connectTimeout ?? dio.options.connectTimeout
      ..receiveTimeout = receiveTimeout ?? dio.options.receiveTimeout
      ..sendTimeout = sendTimeout ?? dio.options.sendTimeout
      ..queryParameters = queryParameters ?? dio.options.queryParameters
      ..extra = extra ?? dio.options.extra
      ..headers = headers ?? dio.options.headers;

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
  /// [decoder] 反序列化方法
  /// [listDecoder] 列表反序列化方法
  Future<NetworkResponse> fetch<T>(
    NetworkRequest req, {
    T Function(Map<String, dynamic>)? decoder,
    T Function(Map<String, dynamic>)? listDecoder,
  }) async {
    try {
      Response response = await _dio.request(
        req.apiPath,
        data: req.data,
        queryParameters: req.queryParams,
        cancelToken: req.cancelToken,
        options: req.optiopns,
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
  Future<Response<T>> retry<T>(
    RequestOptions requestOptions, {
    bool silence = false,
  }) async {
    Response<T> response = await _dio.request(
      requestOptions.path,
      data: _buildDataForRetry(requestOptions),
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

  // 根据 extra 重建上传 FormData，或回退到直接克隆
  dynamic _buildDataForRetry(RequestOptions source) {
    final data = source.data;
    final extra = source.extra;
    if (data is FormData) {
      final isMultipart = extra['multipart_upload'] == true;
      if (isMultipart) {
        final dynamic paths = extra['filePaths'];
        final String fieldName = (extra['fileFieldName'] ?? 'file').toString();
        final Map<String, dynamic> fields = Map<String, dynamic>.from(
          extra['fields'] ?? {},
        );
        if (paths is List && paths.isNotEmpty) {
          final form = FormData();
          // 先写入字段
          fields.forEach(
            (key, value) => form.fields.add(MapEntry(key, value.toString())),
          );
          // 补齐原始FormData中未包含在extra.fields的字段
          for (final entry in data.fields) {
            if (!fields.containsKey(entry.key)) {
              form.fields.add(entry);
            }
          }
          // 写入文件（多文件按相同字段名重复添加）
          for (final p in paths) {
            if (p is String && p.isNotEmpty) {
              form.files.add(
                MapEntry(fieldName, MultipartFile.fromFileSync(p)),
              );
            }
          }
          return form;
        }
      }
      // 回退：克隆 FormData 的 fields 与 files（注意可能仍旧复用 MultipartFile，但在普通情况已足够）
      final newFormData = FormData();
      newFormData.fields.addAll(data.fields);
      for (final entry in data.files) {
        newFormData.files.add(MapEntry(entry.key, entry.value));
      }
      return newFormData;
    }
    return data;
  }
}
