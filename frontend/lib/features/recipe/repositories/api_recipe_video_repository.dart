import 'dart:async';

import 'package:dio/dio.dart';

import '../models/recipe_video_upload_response.dart';
import '../models/selected_recipe_video.dart';
import 'recipe_video_repository.dart';

// Requests a signed URL, then streams the video directly to GCS.
class ApiRecipeVideoRepository implements RecipeVideoRepository {
  ApiRecipeVideoRepository(
    this._backendDio, {
    Dio? uploadDio,
    DateTime Function()? now,
  })  : _uploadDio = uploadDio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 15),
                sendTimeout: const Duration(minutes: 5),
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
  Future<String> uploadRecipeVideo({
    required int recipeId,
    required SelectedRecipeVideo video,
  }) async {
    for (var attempt = 0; attempt < _maximumUploadAttempts; attempt++) {
      final upload = await _requestUploadSlot(recipeId, video);

      if (!_hasEnoughTimeRemaining(upload)) {
        if (attempt + 1 < _maximumUploadAttempts) continue;
        throw TimeoutException('The recipe video upload URL expired.');
      }

      try {
        await _uploadVideo(upload, video);
        return upload.videoUrl;
      } on DioException catch (error) {
        final canRetry = attempt + 1 < _maximumUploadAttempts;
        if (!canRetry || !_isExpiredUpload(error)) rethrow;
      }
    }

    throw TimeoutException('The recipe video upload URL expired.');
  }

  Future<RecipeVideoUploadResponse> _requestUploadSlot(
    int recipeId,
    SelectedRecipeVideo video,
  ) async {
    final response = await _backendDio.post(
      '/recipes/$recipeId/video-upload-url',
      data: {
        'contentType': video.contentType,
        'fileSizeBytes': video.fileSizeBytes,
      },
    );
    return RecipeVideoUploadResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<void> _uploadVideo(
    RecipeVideoUploadResponse upload,
    SelectedRecipeVideo video,
  ) async {
    final headers = <String, dynamic>{
      ...upload.requiredHeaders,
      Headers.contentTypeHeader: video.contentType,
      Headers.contentLengthHeader: video.fileSizeBytes.toString(),
    };

    await _uploadDio.put(
      upload.uploadUrl,
      data: video.file.openRead(),
      options: Options(
        headers: headers,
        contentType: video.contentType,
        responseType: ResponseType.plain,
      ),
    );
  }

  bool _hasEnoughTimeRemaining(RecipeVideoUploadResponse upload) {
    final minimumExpiry = _now().toUtc().add(_expirySafetyWindow);
    return upload.expiresAt.toUtc().isAfter(minimumExpiry);
  }

  bool _isExpiredUpload(DioException error) {
    if (error.response?.statusCode != 403) return false;
    final responseBody = error.response?.data?.toString().toLowerCase() ?? '';
    return responseBody.contains('expired');
  }
}
