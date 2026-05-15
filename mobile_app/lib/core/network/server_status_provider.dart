import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ServerStatus { unknown, online, down }

final serverStatusProvider =
    NotifierProvider<ServerStatusController, ServerStatus>(
        ServerStatusController.new);

class ServerStatusController extends Notifier<ServerStatus> {
  Timer? _retryTimer;

  @override
  ServerStatus build() => ServerStatus.unknown;

  /// Called by the Dio interceptor on every successful response.
  void markOnline() {
    _retryTimer?.cancel();
    if (state != ServerStatus.online) {
      state = ServerStatus.online;
    }
  }

  /// Called by the Dio interceptor when a connection-level error occurs.
  void markDown(Dio dio) {
    if (state == ServerStatus.down) return; // already marked, timer running
    state = ServerStatus.down;
    _scheduleRetry(dio);
  }

  void _scheduleRetry(Dio dio) {
    _retryTimer?.cancel();
    _retryTimer = Timer.periodic(const Duration(seconds: 15), (_) async {
      try {
        await dio.get<dynamic>('healthz',
            options: Options(sendTimeout: const Duration(seconds: 5),
                             receiveTimeout: const Duration(seconds: 5)));
        markOnline();
        _retryTimer?.cancel();
      } catch (_) {
        // still down — keep retrying
      }
    });
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
  }
}
