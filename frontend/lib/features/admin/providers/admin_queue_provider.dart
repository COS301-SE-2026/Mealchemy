import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/admin_models.dart';
import 'admin_access_provider.dart';

final adminQueueStatusProvider =
    StateProvider.autoDispose<FlagStatus>((ref) => FlagStatus.pending);

class AdminQueueAccessException implements Exception {
  const AdminQueueAccessException(this.access);

  final AdminAccess access;
}

final adminQueueProvider =
    FutureProvider.autoDispose.family<List<FlaggedRecipe>, FlagStatus>(
  (ref, status) async {
    //rebuild when identity, credential or connectivity changes
    //results from an earlier session cannot replace the current result
    ref.watch(adminAccessContextProvider);

    final access = ref.watch(adminAccessStateProvider);
    if (access != AdminAccess.allowed) {
      throw AdminQueueAccessException(access);
    }

    final repository = ref.watch(adminRepositoryProvider);

    try {
      return await repository.getFlags(status: status);
    } on DioException catch (error) {
      switch (error.response?.statusCode) {
        case 401:
        case 404:
          throw const AdminQueueAccessException(
            AdminAccess.signInRequired,
          );
        case 403:
          throw const AdminQueueAccessException(
            AdminAccess.forbidden,
          );
        default:
          rethrow;
      }
    }
  },
);

String adminQueueErrorMessage(Object error) {
  if (error is DioException) {
    final data = error.response?.data;

    if (data is Map && data['message'] is String) {
      final message = (data['message'] as String).trim();
      if (message.isNotEmpty) return message;
    }

    if (error.response == null) {
      return 'Could not connect to load reports. Please try again.';
    }
  }

  return 'Could not load reports. Please try again.';
}

String flagStatusLabel(FlagStatus status) {
  return switch (status) {
    FlagStatus.pending => 'Pending',
    FlagStatus.reviewed => 'Reviewed',
    FlagStatus.removed => 'Removed',
  };
}
