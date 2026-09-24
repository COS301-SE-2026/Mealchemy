import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mealchemy/features/recipe/models/selected_recipe_video.dart';
import 'package:mealchemy/features/recipe/repositories/api_recipe_video_repository.dart';

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
  test('requests a slot and streams the MP4 without the backend JWT', () async {
    final backendAdapter = _RecordingAdapter(
      (_) => ResponseBody.fromString(
        jsonEncode({
          'uploadUrl': 'https://storage.googleapis.com/signed-video-upload',
          'videoUrl': 'https://storage.googleapis.com/recipe.mp4',
          'requiredHeaders': {
            'Content-Type': 'video/mp4',
            'Content-Length': '3',
          },
          'expiresAt': '2026-09-24T12:00:00Z',
        }),
        200,
        headers: {
          Headers.contentTypeHeader: ['application/json'],
        },
      ),
    );
    final backendDio = Dio(BaseOptions(baseUrl: 'https://backend.test'))
      ..httpClientAdapter = backendAdapter
      ..interceptors.add(
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
    final repository = ApiRecipeVideoRepository(
      backendDio,
      uploadDio: Dio()..httpClientAdapter = uploadAdapter,
      now: () => DateTime.utc(2026, 9, 24, 11),
    );
    final video = await SelectedRecipeVideo.validate(
      XFile.fromData(
        Uint8List.fromList([1, 2, 3]),
        path: 'recipe.mp4',
        name: 'recipe.mp4',
        mimeType: 'video/mp4',
      ),
    );

    final videoUrl = await repository.uploadRecipeVideo(
      recipeId: 42,
      video: video,
    );

    expect(backendAdapter.request!.path, '/recipes/42/video-upload-url');
    expect(backendAdapter.request!.data, {
      'contentType': 'video/mp4',
      'fileSizeBytes': 3,
    });
    expect(
      backendAdapter.request!.headers['Authorization'],
      'Bearer test-token',
    );
    expect(
      uploadAdapter.request!.uri.toString(),
      'https://storage.googleapis.com/signed-video-upload',
    );
    expect(uploadAdapter.request!.headers['Authorization'], isNull);
    expect(
      uploadAdapter.request!.headers[Headers.contentTypeHeader],
      'video/mp4',
    );
    expect(uploadAdapter.body, [1, 2, 3]);
    expect(videoUrl, 'https://storage.googleapis.com/recipe.mp4');
  });
}
