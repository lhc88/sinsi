/// 제네릭 오브젝트 풀 — GC 최소화
class ObjectPool<T> {
  final T Function() _create;
  final void Function(T) _reset;
  final List<T> _available = [];
  final List<T> _active = [];

  ObjectPool({
    required T Function() create,
    required void Function(T) reset,
    int initialSize = 50,
  })  : _create = create,
        _reset = reset {
    for (int i = 0; i < initialSize; i++) {
      _available.add(_create());
    }
  }

  T acquire() {
    final T obj;
    if (_available.isNotEmpty) {
      obj = _available.removeLast();
    } else {
      obj = _create();
    }
    _active.add(obj);
    return obj;
  }

  void release(T obj) {
    _active.remove(obj);
    _reset(obj);
    _available.add(obj);
  }

  void releaseAll() {
    for (final obj in _active) {
      _reset(obj);
      _available.add(obj);
    }
    _active.clear();
  }

  List<T> get active => _active;
  int get activeCount => _active.length;
  int get availableCount => _available.length;
}
