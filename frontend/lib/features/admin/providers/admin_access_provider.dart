import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/connectivity/network_status_provider.dart';
import '../../../core/providers/api_service_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../repositories/admin_repository.dart';
import '../repositories/api_admin_repository.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return ApiAdminRepository(ref.watch(dioProvider));
});

enum AdminAccess {
  checking,
  allowed,
  forbidden,
  signInRequired,
  offline,
  unavailable,
}

// Includes the credential so reauthentication triggers a fresh check,
// even when the same user signs in again.
typedef AdminAccessContext = ({
  int? userId,
  String? token,
  bool restoring,
  bool hasValidCredential,
  NetworkStatus network,
});

final adminAccessContextProvider = Provider<AdminAccessContext>((ref) {
  final session = ref.watch(
    authProvider.select(
      (state) => (
        userId: state.userId,
        token: state.token,
        restoring: state.isRestoring,
        hasValidCredential: state.isLoggedIn && state.hasValidCredential,
      ),
    ),
  );

  return (
    userId: session.userId,
    token: session.token,
    restoring: session.restoring,
    hasValidCredential: session.hasValidCredential,
    network: ref.watch(networkStatusProvider),
  );
});

final adminAccessProvider =
    FutureProvider.autoDispose<AdminAccess>((ref) async {
  final context = ref.watch(adminAccessContextProvider);

  if (context.restoring) {
    return AdminAccess.checking;
  }

  if (context.userId == null ||
      context.token == null ||
      !context.hasValidCredential) {
    return AdminAccess.signInRequired;
  }

  if (context.network == NetworkStatus.checking) {
    return AdminAccess.checking;
  }

  if (context.network == NetworkStatus.offline) {
    return AdminAccess.offline;
  }

  final repository = ref.watch(adminRepositoryProvider);

  try {
    //backend checks caller's db roles
    //successful empty queue also confirms admin access
    await repository.getFlags();
    return AdminAccess.allowed;
  } on DioException catch (error) {
    switch (error.response?.statusCode) {
      case 401:
        return AdminAccess.signInRequired;
      case 403:
        return AdminAccess.forbidden;
      case 404:
        //on endpoint, 404 means the caller's account not found
        return AdminAccess.signInRequired;
      default:
        return AdminAccess.unavailable;
    }
  } catch (_) {
    //unexpected or malformed responses never grant access
    return AdminAccess.unavailable;
  }
});

//never expose previous successful result while fresh check running
//riverpod discards results from replaced/disposed provider computations
final adminAccessStateProvider = Provider.autoDispose<AdminAccess>((ref) {
  final access = ref.watch(adminAccessProvider);

  if (access.isLoading) {
    return AdminAccess.checking;
  }

  if (access.hasError) {
    return AdminAccess.unavailable;
  }

  return access.valueOrNull ?? AdminAccess.checking;
});
