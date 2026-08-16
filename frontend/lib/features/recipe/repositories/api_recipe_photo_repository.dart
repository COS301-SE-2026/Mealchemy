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
  }) : _uploadDio = uploadDio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 15),
                sendTimeout: const Duration(minutes: 2),
                receiveTimeout: const Duration(seconds: 30),
              ),
            );

  final Dio _backendDio;
  final Dio _uploadDio;

  @override
  Future<String> uploadRecipePhoto({
    required int recipeId,
    required SelectedRecipePhoto photo,
  }) async {
    final response = await _backendDio.post(
      '/recipes/$recipeId/photo-upload-url',
      data: {
        'contentType': photo.contentType,
        'fileSizeBytes': photo.fileSizeBytes,
      },
    );
    final upload = RecipePhotoUploadResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
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
    return upload.photoUrl;
  }
}
