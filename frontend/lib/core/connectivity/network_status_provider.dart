import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'connectivity_service.dart';

enum NetworkStatus { checking, online, offline }

final networkInterfaceSourceProvider = Provider<NetworkInterfaceSource>((ref) {
  return PluginNetworkInterfaceSource();
});

final backendReachabilityProvider = Provider<BackendReachability>((ref) {
  return DioBackendReachability();
});

final networkStatusProvider =
    StateNotifierProvider<NetworkStatusNotifier, NetworkStatus>((ref) {
  return NetworkStatusNotifier(
    interfaceSource: ref.watch(networkInterfaceSourceProvider),
    reachability: ref.watch(backendReachabilityProvider),
  );
});

final offlineReadOnlyProvider = Provider<bool>((ref) {
  return ref.watch(networkStatusProvider) == NetworkStatus.offline;
});

class NetworkStatusNotifier extends StateNotifier<NetworkStatus> {
  NetworkStatusNotifier({
    required NetworkInterfaceSource interfaceSource,
    required BackendReachability reachability,
    Duration reconnectDebounce = const Duration(milliseconds: 750),
  })  : _interfaceSource = interfaceSource,
        _reachability = reachability,
        _reconnectDebounce = reconnectDebounce,
        super(NetworkStatus.checking);

  final NetworkInterfaceSource _interfaceSource;
  final BackendReachability _reachability;
  final Duration _reconnectDebounce;

  StreamSubscription<bool>? _interfaceSubscription;
  Timer? _reconnectTimer;
  Future<void>? _initialization;
  bool _disposed = false;

  Future<void> initialize() {
    return _initialization ??= _initialize();
  }

  Future<void> _initialize() async {
    try {
      _interfaceSubscription = _interfaceSource.changes.listen(
        _handleInterfaceChange,
      );

      final hasInterface = await _interfaceSource.hasNetworkInterface();
      if (_disposed) return;

      if (!hasInterface) {
        state = NetworkStatus.offline;
        return;
      }

      await _probeBackend();
    } catch (_) {
      if (_disposed) return;
      // A platform-channel failure is equivalent to unknown reachability and mustn't crash startup.
      // Real API traffic can still mark online.
      state = NetworkStatus.offline;
    }
  }

  void markBackendReachable() {
    if (_disposed) return;
    _reconnectTimer?.cancel();
    state = NetworkStatus.online;
  }

  void reportDioError(DioException error) {
    if (_disposed) return;

    if (error.response != null) {
      // 401, 403, and 5xx responses prove the backend is reachable.
      markBackendReachable();
      return;
    }

    if (_isTransportFailure(error.type)) {
      state = NetworkStatus.offline;
    }
  }

  void _handleInterfaceChange(bool hasInterface) {
    _reconnectTimer?.cancel();

    if (!hasInterface) {
      state = NetworkStatus.offline;
      return;
    }

    state = NetworkStatus.checking;
    _reconnectTimer = Timer(_reconnectDebounce, () {
      unawaited(_probeBackend());
    });
  }

  Future<void> _probeBackend() async {
    final reachable = await _reachability.isReachable();
    if (_disposed) return;
    state = reachable ? NetworkStatus.online : NetworkStatus.offline;
  }

  bool _isTransportFailure(DioExceptionType type) {
    return switch (type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.connectionError ||
      DioExceptionType.badCertificate ||
      DioExceptionType.unknown =>
        true,
      DioExceptionType.badResponse || DioExceptionType.cancel => false,
    };
  }

  @override
  void dispose() {
    _disposed = true;
    _reconnectTimer?.cancel();
    unawaited(_interfaceSubscription?.cancel());
    super.dispose();
  }
}

class NetworkStatusInterceptor extends Interceptor {
  NetworkStatusInterceptor(this._notifier);

  final NetworkStatusNotifier _notifier;

  @override
  void onResponse(
      Response<dynamic> response, ResponseInterceptorHandler handler) {
    _notifier.markBackendReachable();
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _notifier.reportDioError(err);
    handler.next(err);
  }
}
