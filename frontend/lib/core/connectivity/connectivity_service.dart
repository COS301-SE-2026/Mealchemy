import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

import 'backend_config.dart';

abstract class NetworkInterfaceSource {
  Future<bool> hasNetworkInterface();

  Stream<bool> get changes;
}

class PluginNetworkInterfaceSource implements NetworkInterfaceSource {
  PluginNetworkInterfaceSource({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  @override
  Future<bool> hasNetworkInterface() async {
    return _hasInterface(await _connectivity.checkConnectivity());
  }

  @override
  Stream<bool> get changes =>
      _connectivity.onConnectivityChanged.map(_hasInterface).distinct();

  bool _hasInterface(List<ConnectivityResult> results) {
    return results.any((result) => result != ConnectivityResult.none);
  }
}

abstract class BackendReachability {
  Future<bool> isReachable();
}

class DioBackendReachability implements BackendReachability {
  DioBackendReachability({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: backendBaseUrl,
                connectTimeout: const Duration(seconds: 5),
                receiveTimeout: const Duration(seconds: 5),
                validateStatus: (_) => true,
              ),
            );

  final Dio _dio;

  @override
  Future<bool> isReachable() async {
    try {
      // Any HTTP response proves reachability.
      // Health or server errors remain online states, feature repositories decide whether to use cache fallback.
      await _dio.get<void>('/actuator/health');
      return true;
    } on DioException {
      return false;
    }
  }
}
