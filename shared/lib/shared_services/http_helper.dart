import 'package:core/core_network/core_network.dart';
import 'package:core/core_utils/log_util.dart';
import 'package:fpdart/fpdart.dart';
import 'dart:async'; // Added for Completer

final networkClient = NetworkClient();

extension FuturetryCatch on Future<dynamic> {
  Future<void> tryCatch(
    Function(NetworkException error) onError,
    Function(dynamic) onSuccess,
  ) async {
    (await TaskEither.tryCatch(() => this, (error, _) {
      LogUtil.error((error as NetworkException).message);
      return error;
    }).run()).fold((l) => onError(l), (r) => onSuccess(r));
  }

  Future<void> tryCatchClean(
    Function(NetworkException error) onError,
    Function(dynamic) onSuccess,
  ) async {
    try {
      final result = await this;
      onSuccess(result);
    } catch (e) {
      if (e is NetworkException) {
        onError(e);
      } else {
        onError(NetworkException.fromError(e as Error));
      }
    }
  }
}

extension DecodeData on Future<NetworkResponse> {
  Future<dynamic> decodeData<T>({
    Decoder<T>? decoder,
    Decoder<T>? listDecoder,
  }) async {
    final ResponseData = (await this).data;

    final data = ResponseData is Map && ResponseData['data'] != null
        ? ResponseData['data']
        : ResponseData;

    return (decoder != null && data is Map)
        ? (data)._decode<T>(decoder)
        : (listDecoder != null && data is List)
        ? (data)._decode<T>(listDecoder)
        : data;
  }
}

extension DecodeT on Map {
  T _decode<T>(Decoder<T> decoder) {
    Map<String, dynamic> dataMap = cast<String, dynamic>();
    return decoder(dataMap);
  }
}

extension DecodeListT on List {
  List<T> _decode<T>(Decoder<T> decoder) {
    List<Map<String, dynamic>> dataList = cast<Map<String, dynamic>>();
    return dataList.map((e) => decoder(e)).toList();
  }
}
