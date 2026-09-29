import 'package:dio/dio.dart';

import '../models/admin_models.dart';
import 'admin_repository.dart';

class ApiAdminRepository implements AdminRepository {
  ApiAdminRepository(this._dio);

  //supply the shared dioProvider client when wiring repo
  final Dio _dio;

  @override
  Future<List<FlaggedRecipe>> getFlags({
    FlagStatus status = FlagStatus.pending,
  }) async {
    final response = await _dio.get<dynamic>(
      '/admin/flags',
      queryParameters: {'status': status.apiValue},
    );

    final data = response.data as List;

    return data
        .map(
          (item) => FlaggedRecipe.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }

  @override
  Future<FlaggedRecipeDetail> getFlagDetail(int flaggedId) async {
    final response = await _dio.get<dynamic>(
      '/admin/flags/$flaggedId',
    );

    return FlaggedRecipeDetail.fromJson(_object(response));
  }

  @override
  Future<FlaggedRecipe> dismissFlag(int flaggedId) async {
    final response = await _dio.put<dynamic>(
      '/admin/flags/$flaggedId/dismiss',
    );

    return FlaggedRecipe.fromJson(_object(response));
  }

  @override
  Future<FlaggedRecipe> removeFromCommunity(int flaggedId) async {
    final response = await _dio.delete<dynamic>(
      '/admin/flags/$flaggedId/recipe',
    );

    return FlaggedRecipe.fromJson(_object(response));
  }

  @override
  Future<AdminUserSummary> findUserByEmail(String email) async {
    final trimmedEmail = email.trim();

    if (trimmedEmail.isEmpty) {
      throw ArgumentError.value(email, 'email', 'Email must not be blank.');
    }

    final response = await _dio.get<dynamic>(
      '/admin/users',
      queryParameters: {'email': trimmedEmail},
    );

    return AdminUserSummary.fromJson(_object(response));
  }

  @override
  Future<AdminUserSummary> promoteUser(int userId) async {
    final response = await _dio.put<dynamic>(
      '/admin/users/$userId/promote',
    );

    return AdminUserSummary.fromJson(_object(response));
  }

  Map<String, dynamic> _object(Response<dynamic> response) {
    return Map<String, dynamic>.from(response.data as Map);
  }
}
