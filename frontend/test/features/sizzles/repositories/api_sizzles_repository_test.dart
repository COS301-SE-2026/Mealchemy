import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/sizzles/repositories/api_sizzles_repository.dart';

void main() {
  test('loads global Sizzles as recipes', () async {
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          expect(options.path, '/recipes/community/sizzles');
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: [
                {
                  'recipeId': 1,
                  'title': 'Pasta Sizzle',
                  'videoUrl': 'https://cdn.test/pasta.mp4',
                  'isCommunityPublished': true,
                },
              ],
            ),
          );
        },
      ),
    );

    final recipes = await ApiSizzlesRepository(dio).getSizzles();

    expect(recipes, hasLength(1));
    expect(recipes.single.title, 'Pasta Sizzle');
    expect(recipes.single.videoUrl, 'https://cdn.test/pasta.mp4');
  });
}
