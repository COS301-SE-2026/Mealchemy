import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/recipe/models/selected_recipe_photo.dart';
import 'package:mealchemy/features/recipe/repositories/api_recipe_photo_repository.dart';

//records backend and GCS requests without making network calls
class _RecordingAdapter implements HttpClientAdapter {
  _RecordingAdapter(this.responseFactory);

  final ResponseBody Function(RequestOptions options) responseFactory;
  RequestOptions? request;
  Uint8List body = Uint8List(0);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    request = options;
    final bytes = <int>[];
    if (requestStream != null) {
      await for (final chunk in requestStream) {
        bytes.addAll(chunk);
      }
    }
    body = Uint8List.fromList(bytes);
    return responseFactory(options);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  test('requests a slot and uploads bytes without the backend JWT', () async {
    final backendAdapter = _RecordingAdapter(
      (_) => ResponseBody.fromString(
        jsonEncode({
          'uploadUrl': 'https://storage.googleapis.com/signed-upload',
          'photoUrl': 'https://storage.googleapis.com/photo.jpg',
          'requiredHeaders': {
            'Content-Type': 'image/jpeg',
            'Content-Length': '3',
          },
          'expiresAt': '2026-08-16T12:00:00Z',
        }),
        200,
        headers: {
          Headers.contentTypeHeader: ['application/json'],
        },
      ),
    );
    final backendDio = Dio(BaseOptions(baseUrl: 'https://backend.test'));
    backendDio.httpClientAdapter = backendAdapter;
    backendDio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.headers['Authorization'] = 'Bearer test-token';
          handler.next(options);
        },
      ),
    );

    final uploadAdapter = _RecordingAdapter(
      (_) => ResponseBody.fromString('', 200),
    );
    final uploadDio = Dio()..httpClientAdapter = uploadAdapter;
    final repository = ApiRecipePhotoRepository(
      backendDio,
      uploadDio: uploadDio,
    );
    final photo = SelectedRecipePhoto.validate(
      bytes: Uint8List.fromList([1, 2, 3]),
      fileName: 'meal.jpg',
      contentType: 'image/jpeg',
    );

    final photoUrl = await repository.uploadRecipePhoto(
      recipeId: 42,
      photo: photo,
    );

    expect(backendAdapter.request!.path, '/recipes/42/photo-upload-url');
    expect(backendAdapter.request!.data, {
      'contentType': 'image/jpeg',
      'fileSizeBytes': 3,
    });
    expect(
      backendAdapter.request!.headers['Authorization'],
      'Bearer test-token',
    );
    expect(uploadAdapter.request!.uri.toString(),
        'https://storage.googleapis.com/signed-upload');
    expect(uploadAdapter.request!.headers['Authorization'], isNull);
    expect(uploadAdapter.request!.headers[Headers.contentTypeHeader],
        'image/jpeg');
    expect(uploadAdapter.body, [1, 2, 3]);
    expect(photoUrl, 'https://storage.googleapis.com/photo.jpg');
  });

  test('throws when the GCS upload fails', () async {
    final backendAdapter = _RecordingAdapter(
      (_) => ResponseBody.fromString(
        jsonEncode({
          'uploadUrl': 'https://storage.googleapis.com/signed-upload',
          'photoUrl': 'https://storage.googleapis.com/photo.jpg',
          'requiredHeaders': {
            'Content-Type': 'image/png',
            'Content-Length': '1',
          },
          'expiresAt': '2026-08-16T12:00:00Z',
        }),
        200,
        headers: {
          Headers.contentTypeHeader: ['application/json'],
        },
      ),
    );
    final backendDio = Dio(BaseOptions(baseUrl: 'https://backend.test'))
      ..httpClientAdapter = backendAdapter;
    final uploadDio = Dio()
      ..httpClientAdapter = _RecordingAdapter(
        (_) => ResponseBody.fromString('Forbidden', 403),
      );
    final repository = ApiRecipePhotoRepository(
      backendDio,
      uploadDio: uploadDio,
    );
    final photo = SelectedRecipePhoto.validate(
      bytes: Uint8List.fromList([1]),
      fileName: 'meal.png',
      contentType: 'image/png',
    );

    expect(
      repository.uploadRecipePhoto(recipeId: 42, photo: photo),
      throwsA(isA<DioException>()),
    );
  });
}
