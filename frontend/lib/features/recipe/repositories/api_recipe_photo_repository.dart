import 'dart:async';

import 'package:dio/dio.dart';

import '../models/recipe_photo_upload_response.dart';
import '../models/selected_recipe_photo.dart';
import 'recipe_photo_repository.dart';

//requests a signed URL, then uploads the photo directly to GCS
class ApiRecipePhotoRepository implements RecipePhotoRepository {
  ApiRecipePhotoRepository(
    this._backendDio, {
    Dio? uploadDio,
    DateTime Function()? now,
  })  : _uploadDio = uploadDio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 15),
                sendTimeout: const Duration(minutes: 2),
                receiveTimeout: const Duration(seconds: 30),
              ),
            ),
        _now = now ?? DateTime.now;

  final Dio _backendDio;
  final Dio _uploadDio;
  final DateTime Function() _now;

  static const _expirySafetyWindow = Duration(seconds: 30);
  static const _maximumUploadAttempts = 2;

  @override
  Future<String> uploadRecipePhoto({
    required int recipeId,
    required SelectedRecipePhoto photo,
  }) async {
    for (var attempt = 0; attempt < _maximumUploadAttempts; attempt++) {
      final upload = await _requestUploadSlot(recipeId, photo);

      if (!_hasEnoughTimeRemaining(upload)) {
        if (attempt + 1 < _maximumUploadAttempts) continue;
        throw TimeoutException('The recipe photo upload URL expired.');
      }

      try {
        await _uploadPhoto(upload, photo);
        return upload.photoUrl;
      } on DioException catch (error) {
        final canRetry = attempt + 1 < _maximumUploadAttempts;
        if (!canRetry || !_isExpiredUpload(error)) rethrow;
      }
    }

    throw TimeoutException('The recipe photo upload URL expired.');
  }

  Future<RecipePhotoUploadResponse> _requestUploadSlot(
    int recipeId,
    SelectedRecipePhoto photo,
  ) async {
    final response = await _backendDio.post(
      '/recipes/$recipeId/photo-upload-url',
      data: {
        'contentType': photo.contentType,
        'fileSizeBytes': photo.fileSizeBytes,
      },
    );
    return RecipePhotoUploadResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<void> _uploadPhoto(
    RecipePhotoUploadResponse upload,
    SelectedRecipePhoto photo,
  ) async {
    final headers = <String, dynamic>{
      ...upload.requiredHeaders,
      Headers.contentTypeHeader: photo.contentType,
      Headers.contentLengthHeader: photo.fileSizeBytes.toString(),
    };

    await _uploadDio.put(
      upload.uploadUrl,
      data: Stream<List<int>>.value(photo.bytes),
      options: Options(
        headers: headers,
        contentType: photo.contentType,
        responseType: ResponseType.plain,
      ),
    );
  }

  bool _hasEnoughTimeRemaining(RecipePhotoUploadResponse upload) {
    final minimumExpiry = _now().toUtc().add(_expirySafetyWindow);
    return upload.expiresAt.toUtc().isAfter(minimumExpiry);
  }

  bool _isExpiredUpload(DioException error) {
    if (error.response?.statusCode != 403) return false;
    final responseBody = error.response?.data?.toString().toLowerCase() ?? '';
    return responseBody.contains('expired');
  }
}
