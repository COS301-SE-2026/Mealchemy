import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/core/connectivity/connectivity_service.dart';
import 'package:mealchemy/core/connectivity/network_status_provider.dart';

void main() {
  group('NetworkStatusNotifier', () {
    test('starts offline without a network interface', () async {
      final source = _FakeNetworkInterfaceSource(initialValue: false);
      final reachability = _FakeBackendReachability(true);
      final notifier = _notifier(source, reachability);
      addTearDown(notifier.dispose);

      await notifier.initialize();

      expect(notifier.state, NetworkStatus.offline);
      expect(reachability.calls, 0);
    });

    test('requires backend reachability before reporting online', () async {
      final source = _FakeNetworkInterfaceSource(initialValue: true);
      final reachability = _FakeBackendReachability(false);
      final notifier = _notifier(source, reachability);
      addTearDown(notifier.dispose);

      await notifier.initialize();

      expect(notifier.state, NetworkStatus.offline);
      expect(reachability.calls, 1);
    });

    test('reports online when the backend responds', () async {
      final source = _FakeNetworkInterfaceSource(initialValue: true);
      final notifier = _notifier(source, _FakeBackendReachability(true));
      addTearDown(notifier.dispose);

      await notifier.initialize();

      expect(notifier.state, NetworkStatus.online);
    });

    test('probes once after interface connectivity returns', () async {
      final source = _FakeNetworkInterfaceSource(initialValue: false);
      final reachability = _FakeBackendReachability(true);
      final notifier = _notifier(source, reachability);
      addTearDown(notifier.dispose);
      await notifier.initialize();

      source.emit(true);
      await Future<void>.delayed(const Duration(milliseconds: 1));

      expect(notifier.state, NetworkStatus.online);
      expect(reachability.calls, 1);
    });

    test('HTTP errors prove reachability but transport errors do not',
        () async {
      final source = _FakeNetworkInterfaceSource(initialValue: false);
      final notifier = _notifier(source, _FakeBackendReachability(false));
      addTearDown(notifier.dispose);
      await notifier.initialize();

      notifier.reportDioError(
        DioException(
          requestOptions: RequestOptions(path: '/recipes'),
          response: Response<void>(
            requestOptions: RequestOptions(path: '/recipes'),
            statusCode: 401,
          ),
          type: DioExceptionType.badResponse,
        ),
      );
      expect(notifier.state, NetworkStatus.online);

      notifier.reportDioError(
        DioException(
          requestOptions: RequestOptions(path: '/recipes'),
          type: DioExceptionType.connectionError,
        ),
      );
      expect(notifier.state, NetworkStatus.offline);
    });
  });
}

NetworkStatusNotifier _notifier(
  NetworkInterfaceSource source,
  BackendReachability reachability,
) {
  return NetworkStatusNotifier(
    interfaceSource: source,
    reachability: reachability,
    reconnectDebounce: Duration.zero,
  );
}

class _FakeNetworkInterfaceSource implements NetworkInterfaceSource {
  _FakeNetworkInterfaceSource({required this.initialValue});

  final bool initialValue;
  final StreamController<bool> _controller = StreamController<bool>.broadcast();

  @override
  Stream<bool> get changes => _controller.stream;

  void emit(bool value) => _controller.add(value);

  @override
  Future<bool> hasNetworkInterface() async => initialValue;
}

class _FakeBackendReachability implements BackendReachability {
  _FakeBackendReachability(this.reachable);

  final bool reachable;
  int calls = 0;

  @override
  Future<bool> isReachable() async {
    calls += 1;
    return reachable;
  }
}