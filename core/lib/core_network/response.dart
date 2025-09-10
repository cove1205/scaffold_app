part of 'core_network.dart';

/// 请求返回对象
class NetworkResponse {
  /// 返回的状态码
  final int code;

  /// 返回状态信息
  final String msg;

  /// 返回的数据
  dynamic data;

  /// 请求是否成功
  bool get success => code == status200OK;

  NetworkResponse(this.code, this.msg, {this.data});

  factory NetworkResponse.fromResponse(Response response) {
    return NetworkResponse(
      response.statusCode ?? status200OK,
      response.statusMessage ?? 'OK',
      data: response.data,
    );
  }

  @override
  String toString() {
    return 'NetworkResponse:\nstatus: $code,\nmsg: $msg,\ndata: ${data.toString()}';
  }
}
