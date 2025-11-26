import 'dart:async';

/// Utility functions for stream optimization
///
/// Usage examples:
/// ```dart
/// // Debounce stream
/// final debouncedStream = stream.debounce(Duration(milliseconds: 300));
///
/// // Throttle stream
/// final throttledStream = stream.throttle(Duration(seconds: 1));
///
/// // Distinct until changed
/// final distinctStream = stream.distinctUntilChanged();
/// ```
extension StreamExtensions<T> on Stream<T> {
  /// Debounce stream - emits only after a pause in events
  ///
  /// Useful for search inputs, scroll events, etc.
  /// Only emits after [duration] has passed with no new events
  Stream<T> debounce(Duration duration) {
    Timer? timer;
    late StreamController<T> controller;

    controller = StreamController<T>(
      onListen: () {
        listen(
          (data) {
            timer?.cancel();
            timer = Timer(duration, () {
              if (!controller.isClosed) {
                controller.add(data);
              }
            });
          },
          onError: controller.addError,
          onDone: () {
            timer?.cancel();
            controller.close();
          },
          cancelOnError: false,
        );
      },
      onCancel: () => timer?.cancel(),
    );

    return controller.stream;
  }

  /// Throttle stream - emits at most once per duration
  ///
  /// Useful for limiting API calls, button clicks, etc.
  /// Emits the first event, then ignores events until [duration] passes
  Stream<T> throttle(Duration duration) {
    late StreamController<T> controller;
    Timer? timer;
    bool canEmit = true;

    controller = StreamController<T>(
      onListen: () {
        listen(
          (data) {
            if (canEmit && !controller.isClosed) {
              controller.add(data);
              canEmit = false;
              timer = Timer(duration, () => canEmit = true);
            }
          },
          onError: controller.addError,
          onDone: () {
            timer?.cancel();
            controller.close();
          },
          cancelOnError: false,
        );
      },
      onCancel: () => timer?.cancel(),
    );

    return controller.stream;
  }

  /// Only emit when value changes
  ///
  /// Useful for preventing duplicate emissions
  Stream<T> distinctUntilChanged() {
    T? previous;
    bool hasPrevious = false;

    return where((current) {
      if (!hasPrevious) {
        hasPrevious = true;
        previous = current;
        return true;
      }

      if (previous != current) {
        previous = current;
        return true;
      }

      return false;
    });
  }

  /// Buffer events and emit as a list after duration or when buffer is full
  ///
  /// Useful for batch processing
  Stream<List<T>> buffer({
    Duration? duration,
    int? maxSize,
  }) {
    assert(duration != null || maxSize != null,
        'Either duration or maxSize must be provided');

    late StreamController<List<T>> controller;
    Timer? timer;
    List<T> buffer = [];

    void emitBuffer() {
      if (buffer.isNotEmpty && !controller.isClosed) {
        controller.add(List.from(buffer));
        buffer.clear();
      }
    }

    controller = StreamController<List<T>>(
      onListen: () {
        listen(
          (data) {
            buffer.add(data);

            // Emit if max size reached
            if (maxSize != null && buffer.length >= maxSize) {
              timer?.cancel();
              emitBuffer();
              if (duration != null) {
                timer = Timer(duration, emitBuffer);
              }
              return;
            }

            // Start or reset timer
            if (duration != null) {
              timer?.cancel();
              timer = Timer(duration, emitBuffer);
            }
          },
          onError: controller.addError,
          onDone: () {
            timer?.cancel();
            emitBuffer();
            controller.close();
          },
          cancelOnError: false,
        );
      },
      onCancel: () {
        timer?.cancel();
        buffer.clear();
      },
    );

    return controller.stream;
  }
}

/// Stream multiplexer - shares a single stream among multiple listeners
///
/// Usage:
/// ```dart
/// final multiplexer = StreamMultiplexer(expensiveStream);
/// final listener1 = multiplexer.stream.listen(...);
/// final listener2 = multiplexer.stream.listen(...);
/// // Both listeners receive events from the same source stream
/// ```
class StreamMultiplexer<T> {
  final Stream<T> _source;
  late StreamController<T> _controller;
  StreamSubscription<T>? _subscription;
  int _listenerCount = 0;

  StreamMultiplexer(this._source) {
    _controller = StreamController<T>.broadcast(
      onListen: _onListen,
      onCancel: _onCancel,
    );
  }

  /// The multiplexed stream
  Stream<T> get stream => _controller.stream;

  void _onListen() {
    _listenerCount++;
    if (_listenerCount == 1) {
      // First listener - start subscription
      _subscription = _source.listen(
        _controller.add,
        onError: _controller.addError,
        onDone: _controller.close,
      );
    }
  }

  void _onCancel() {
    _listenerCount--;
    if (_listenerCount == 0) {
      // No more listeners - cancel subscription
      _subscription?.cancel();
      _subscription = null;
    }
  }

  /// Dispose the multiplexer
  Future<void> dispose() async {
    await _subscription?.cancel();
    await _controller.close();
  }
}

/// Cache for stream results with expiration
///
/// Usage:
/// ```dart
/// final cache = StreamCache<List<TaskModel>>(
///   source: () => taskRepository.streamActiveTasks(),
///   duration: Duration(minutes: 5),
/// );
///
/// // First listener triggers fetch
/// final stream1 = cache.stream;
///
/// // Second listener gets cached stream
/// final stream2 = cache.stream;
/// ```
class StreamCache<T> {
  final Stream<T> Function() _source;
  final Duration _duration;

  StreamMultiplexer<T>? _multiplexer;
  DateTime? _cacheTime;

  StreamCache({
    required Stream<T> Function() source,
    Duration duration = const Duration(minutes: 5),
  })  : _source = source,
        _duration = duration;

  /// Get the cached stream or create a new one
  Stream<T> get stream {
    final now = DateTime.now();

    // Check if cache is expired or doesn't exist
    if (_multiplexer == null ||
        _cacheTime == null ||
        now.difference(_cacheTime!) > _duration) {
      // Dispose old multiplexer
      _multiplexer?.dispose();

      // Create new multiplexer
      _multiplexer = StreamMultiplexer(_source());
      _cacheTime = now;
    }

    return _multiplexer!.stream;
  }

  /// Clear the cache
  Future<void> clear() async {
    await _multiplexer?.dispose();
    _multiplexer = null;
    _cacheTime = null;
  }
}
