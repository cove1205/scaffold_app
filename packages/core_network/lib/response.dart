part of 'core_network.dart';

/// 请求返回对象
class NetworkResponse {
  /// 返回的状态码
  final int? code;

  /// 返回状态信息
  final String msg;

  /// 返回的数据
  dynamic data;

  /// 返回的异常
  final NetworkException? exception;

  /// 请求是否成功
  bool get success => code == 200;

  NetworkResponse(this.code, this.msg, {this.data, this.exception});

  @override
  String toString() {
    return 'NetworkResponse:\nstatus: $code,\nmsg: $msg,\ndata: ${data.toString()},\nexception: ${exception.toString()}';
  }
}
