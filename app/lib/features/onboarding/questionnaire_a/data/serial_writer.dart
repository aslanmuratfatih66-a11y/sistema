import 'package:flutter/foundation.dart';

/// Последовательная запись изменений шага: каждое изменение сохраняется сразу,
/// но строго по порядку (иначе быстрые правки подряд могли бы перезаписать друг друга).
class SerialWriter {
  Future<void> _tail = Future.value();

  Future<void> run(Future<void> Function() write) {
    return _tail = _tail.then((_) => write()).catchError((Object e, StackTrace s) {
      debugPrint('SerialWriter: $e\n$s');
    });
  }
}
