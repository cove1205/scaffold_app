import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 基于shared_preferences的存储工具类
abstract class StorageUtil {
  StorageUtil._();

  static SharedPreferences? _innerInstance;

  static SharedPreferences get _storageInstance => _innerInstance == null
      ? throw Exception('storageInstance can not be null,pls call init() first')
      : _innerInstance!;

  /// 初始化
  ///
  /// 请在使用存储方法前调用此方法，否则会报错
  static Future<void> init() async {
    _innerInstance ??= await SharedPreferences.getInstance();
  }

  /// Set Value
  ///
  /// 存储基础数据类型
  static Future<bool> setValue(String key, dynamic value) async {
    if (value == null) {
      return false;
    } else if (value is String) {
      return await _storageInstance.setString(key, value);
    } else if (value is int) {
      return await _storageInstance.setInt(key, value);
    } else if (value is bool) {
      return await _storageInstance.setBool(key, value);
    } else if (value is double) {
      return await _storageInstance.setDouble(key, value);
    } else {
      return false;
    }
  }

  /// Get value
  ///
  /// 提取基础数据类型
  static dynamic getValue(String key) {
    return _storageInstance.get(key);
  }

  /// Set Object
  static Future<bool> setObject(String key, dynamic value) async {
    if (value == null) return false;

    if (value is Map || value is List) {
      try {
        value = jsonEncode(value);
        return await _storageInstance.setString(key, value);
      } catch (e) {
        return false;
      }
    }
    return false;
  }

  /// Get Object
  static dynamic getObject(String key) {
    dynamic value = _storageInstance.get(key);
    try {
      dynamic jsonObj = jsonDecode(value);
      if (jsonObj is Map || jsonObj is List) {
        return jsonObj;
      }
    } catch (e) {
      return value;
    }
  }

  /// Returns true if persistent storage the contains the given [key].
  static bool hasKey(String key) {
    return _storageInstance.containsKey(key);
  }

  /// Remove value for [key]
  static Future<bool> removeValue(String key) async {
    return await _storageInstance.remove(key);
  }

  /// Remove all key-value data
  static Future<bool> clear() async {
    return await _storageInstance.clear();
  }

  /// Get all keys in storage
  static Set<String> getKeys() {
    return _storageInstance.getKeys();
  }

  /// 缓存目录
  static Future<String?> get cacheDirectory async {
    Directory tempDir = await getTemporaryDirectory();
    if (!await tempDir.exists()) return null;
    return tempDir.path;
  }

  /// 缓存总大小
  static Future<int> totalSize() async {
    Directory tempDir = await getTemporaryDirectory();
    if (!await tempDir.exists()) return 0;
    return await _computeSize(tempDir);
  }

  /// 缓存总大小，格式化输出
  static Future<String> totalSizeString() async =>
      _formatSize(await totalSize());

  /// 清除缓存
  static Future<bool> clean() async {
    Directory tempDir = await getTemporaryDirectory();
    if (!await tempDir.exists()) return true;
    try {
      final Stream files = tempDir.list();
      await for (FileSystemEntity file in files) {
        await file.delete(recursive: true);
      }
    } catch (e) {
      return false;
    }
    return true;
  }

  /// 计算缓存大小
  static Future<int> _computeSize(final FileSystemEntity file) async {
    int total = 0;

    /// 如果是文件，返回文件大小
    if (file is File) {
      total = await file.length();
    }

    /// 如果是目录，遍历目录计算大小
    if (file is Directory) {
      final Stream files = file.list(recursive: true);

      await for (FileSystemEntity file in files) {
        if (file is File) total += await file.length();
      }
    }

    return total;
  }

  /// 格式化缓存大小输出
  /// example:
  /// '323 B'、'1.22 MB'、'223 KB'
  static String _formatSize(int size) {
    const List<String> formatList = ['B', 'KB', 'MB', 'GB'];

    double formattedSize = size.toDouble();
    int index = 0;

    while (formattedSize > 1024) {
      index++;
      formattedSize = formattedSize / 1024;
    }

    return '${formattedSize.toStringAsFixed(index > 1 ? 2 : 0)} ${formatList[index]}';
  }
}
