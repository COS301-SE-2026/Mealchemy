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
  int requestCount = 0;
  Uint8List body = Uint8List(0);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    request = options;
    requestCount++;
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
      now: () => DateTime.utc(2026, 8, 16, 11),
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

  test('does not retry an unrelated GCS failure', () async {
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
      now: () => DateTime.utc(2026, 8, 16, 11),
    );
    final photo = SelectedRecipePhoto.validate(
      bytes: Uint8List.fromList([1]),
      fileName: 'meal.png',
      contentType: 'image/png',
    );

    await expectLater(
      repository.uploadRecipePhoto(recipeId: 42, photo: photo),
      throwsA(isA<DioException>()),
    );
    expect(backendAdapter.requestCount, 1);
    expect(
      (uploadDio.httpClientAdapter as _RecordingAdapter).requestCount,
      1,
    );
  });

  test('requests a fresh slot before using an expired URL', () async {
    late _RecordingAdapter backendAdapter;
    backendAdapter = _RecordingAdapter(
      (_) => ResponseBody.fromString(
        jsonEncode({
          'uploadUrl': backendAdapter.requestCount == 1
              ? 'https://storage.googleapis.com/expired-upload'
              : 'https://storage.googleapis.com/fresh-upload',
          'photoUrl': 'https://storage.googleapis.com/photo.jpg',
          'requiredHeaders': {
            'Content-Type': 'image/jpeg',
            'Content-Length': '1',
          },
          'expiresAt': backendAdapter.requestCount == 1
              ? '2026-08-16T11:00:00Z'
              : '2026-08-16T12:00:00Z',
        }),
        200,
        headers: {
          Headers.contentTypeHeader: ['application/json'],
        },
      ),
    );
    final backendDio = Dio(BaseOptions(baseUrl: 'https://backend.test'))
      ..httpClientAdapter = backendAdapter;
    final uploadAdapter = _RecordingAdapter(
      (_) => ResponseBody.fromString('', 200),
    );
    final repository = ApiRecipePhotoRepository(
      backendDio,
      uploadDio: Dio()..httpClientAdapter = uploadAdapter,
      now: () => DateTime.utc(2026, 8, 16, 11),
    );
    final photo = SelectedRecipePhoto.validate(
      bytes: Uint8List.fromList([1]),
      fileName: 'meal.jpg',
      contentType: 'image/jpeg',
    );

    final photoUrl = await repository.uploadRecipePhoto(
      recipeId: 42,
      photo: photo,
    );

    expect(photoUrl, 'https://storage.googleapis.com/photo.jpg');
    expect(backendAdapter.requestCount, 2);
    expect(uploadAdapter.requestCount, 1);
    expect(
      uploadAdapter.request!.uri.toString(),
      'https://storage.googleapis.com/fresh-upload',
    );
  });

  test('requests a fresh slot when GCS reports expiry', () async {
    late _RecordingAdapter backendAdapter;
    backendAdapter = _RecordingAdapter(
      (_) => ResponseBody.fromString(
        jsonEncode({
          'uploadUrl':
              'https://storage.googleapis.com/upload-${backendAdapter.requestCount}',
          'photoUrl': 'https://storage.googleapis.com/photo.png',
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
    late _RecordingAdapter uploadAdapter;
    uploadAdapter = _RecordingAdapter(
      (_) => uploadAdapter.requestCount == 1
          ? ResponseBody.fromString('Request has expired.', 403)
          : ResponseBody.fromString('', 200),
    );
    final repository = ApiRecipePhotoRepository(
      Dio(BaseOptions(baseUrl: 'https://backend.test'))
        ..httpClientAdapter = backendAdapter,
      uploadDio: Dio()..httpClientAdapter = uploadAdapter,
      now: () => DateTime.utc(2026, 8, 16, 11),
    );
    final photo = SelectedRecipePhoto.validate(
      bytes: Uint8List.fromList([1]),
      fileName: 'meal.png',
      contentType: 'image/png',
    );

    final photoUrl = await repository.uploadRecipePhoto(
      recipeId: 42,
      photo: photo,
    );

    expect(photoUrl, 'https://storage.googleapis.com/photo.png');
    expect(backendAdapter.requestCount, 2);
    expect(uploadAdapter.requestCount, 2);
    expect(
      uploadAdapter.request!.uri.toString(),
      'https://storage.googleapis.com/upload-2',
    );
  });

  test('throws when the refreshed signed URL also expires', () async {
    final backendAdapter = _RecordingAdapter(
      (_) => ResponseBody.fromString(
        jsonEncode({
          'uploadUrl': 'https://storage.googleapis.com/signed-upload',
          'photoUrl': 'https://storage.googleapis.com/photo.webp',
          'requiredHeaders': {
            'Content-Type': 'image/webp',
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
    final uploadAdapter = _RecordingAdapter(
      (_) => ResponseBody.fromString('Request has expired.', 403),
    );
    final repository = ApiRecipePhotoRepository(
      Dio(BaseOptions(baseUrl: 'https://backend.test'))
        ..httpClientAdapter = backendAdapter,
      uploadDio: Dio()..httpClientAdapter = uploadAdapter,
      now: () => DateTime.utc(2026, 8, 16, 11),
    );
    final photo = SelectedRecipePhoto.validate(
      bytes: Uint8List.fromList([1]),
      fileName: 'meal.webp',
      contentType: 'image/webp',
    );

    await expectLater(
      repository.uploadRecipePhoto(recipeId: 42, photo: photo),
      throwsA(isA<DioException>()),
    );
    expect(backendAdapter.requestCount, 2);
    expect(uploadAdapter.requestCount, 2);
  });
}
