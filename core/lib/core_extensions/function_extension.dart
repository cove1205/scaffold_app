import 'dart:async';
import 'dart:ui';

/// 函数节流扩展
extension FunctionExt on Function {
  VoidCallback throttle() => _FunctionProxy(this).throttle;

  VoidCallback throttleWithTimeout({int? timeout}) =>
      _FunctionProxy(this, timeout: timeout).throttleWithTimeout;

  VoidCallback debounce({int? timeout}) =>
      _FunctionProxy(this, timeout: timeout).debounce;
}

class _FunctionProxy {
  const _FunctionProxy(this.target, {int? timeout}) : timeout = timeout ?? 500;

  final Function? target;

  final int timeout;

  static final Map<String, bool> _funcThrottle = {};
  static final Map<String, Timer> _funcDebounce = {};

  /// 节流
  ///
  /// 在事件触发时，立即执行事件的目标操作逻辑，
  /// 在当前事件未执行完成时，该事件再次触发时会被忽略，
  /// 直到当前事件执行完成后下一次事件触发才会被执行。
  void throttle() async {
    String key = hashCode.toString();
    bool enable = _funcThrottle[key] ?? true;
    if (enable) {
      _funcThrottle[key] = false;
      try {
        await target?.call();
      } catch (e) {
        rethrow;
      } finally {
        _funcThrottle.remove(key);
      }
    }
  }

  /// 指定时间节流
  ///
  /// 按指定时间节流是在事件触发时，立即执行事件的目标操作逻辑，但
  /// 在指定时间内再次触发事件会被忽略，直到指定时间后再次触发事件才会被执行。
  void throttleWithTimeout() {
    String key = hashCode.toString();
    bool enable = _funcThrottle[key] ?? true;
    if (enable) {
      _funcThrottle[key] = false;
      Timer(Duration(milliseconds: timeout), () {
        _funcThrottle.remove(key);
      });
      target?.call();
    }
  }

  /// 防抖
  ///
  /// 在事件触发时，不立即执行事件的目标操作逻辑，而是延迟指定时间再执行，
  /// 如果该时间内事件再次触发，则取消上一次事件的执行并重新计算延迟时间，
  /// 直到指定时间内事件没有再次触发时才执行事件的目标操作。
  void debounce() {
    String key = hashCode.toString();
    Timer? timer = _funcDebounce[key];
    timer?.cancel();
    timer = Timer(Duration(milliseconds: timeout), () {
      Timer? t = _funcDebounce.remove(key);
      t?.cancel();
      target?.call();
    });
    _funcDebounce[key] = timer;
  }
}

/// Future 最小持续时间扩展

extension FutureMinDuration<T> on Future<T> {
  /// 确保 Future 至少执行指定时间
  Future<T> withMinDuration<T>(Duration minDuration) async {
    final results = await Future.wait([
      this,
      Future<void>.delayed(minDuration),
    ]);
    return results.first as T;
  }

  /// 确保 Future 至少执行指定秒数
  Future<T> withMinSeconds<T>(int seconds) =>
      withMinDuration<T>(Duration(seconds: seconds));

  /// 确保 Future 至少执行指定毫秒数
  Future<T> withMinMilliseconds<T>(int milliseconds) =>
      withMinDuration<T>(Duration(milliseconds: milliseconds));
}
