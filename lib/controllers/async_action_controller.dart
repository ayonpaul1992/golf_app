import 'dart:async';
import 'package:flutter/foundation.dart';

/// Owns the lifecycle of one form action. Repeated submissions share the active
/// operation, and completion never notifies a disposed screen.
class AsyncActionController<T> extends ChangeNotifier {
  Future<T>? _active;
  bool _disposed = false;
  Object? error;
  bool get isLoading => _active != null;

  Future<T> run(Future<T> Function() action) {
    if (_disposed) {
      return Future.error(StateError('Action controller disposed'));
    }
    if (_active != null) return _active!;
    final completion = Completer<T>();
    _active = completion.future;
    error = null;
    notifyListeners();
    Future<T>.sync(action).then((result) {
      _active = null;
      if (!_disposed) notifyListeners();
      completion.complete(result);
    }, onError: (Object failure, StackTrace stack) {
      error = failure;
      _active = null;
      if (!_disposed) notifyListeners();
      completion.completeError(failure, stack);
    });
    return completion.future;
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
