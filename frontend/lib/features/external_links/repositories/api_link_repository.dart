import 'package:dio/dio.dart';

import '../models/link.dart';
import 'link_repository.dart';

class ApiLinkRepository implements LinkRepository {
  ApiLinkRepository(this._dio);

  final Dio _dio;

  static const _base = '/api/external-links';
  @override
  Future<List<Link>> getLinks() async {
    final response = await _dio.get<List<dynamic>>(_base);
    final data = response.data ?? [];
    return data
        .map((json) => Link.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Link> createLink({
    required String name,
    required String url,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      _base,
      data: {'name': name, 'url': url},
    );
    return Link.fromJson(response.data!);
  }

  @override
  Future<Link> updateLink({
    required int linkId,
    required String name,
    required String url,
  }) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '$_base/$linkId',
      data: {'name': name, 'url': url},
    );
    return Link.fromJson(response.data!);
  }

  @override
  Future<void> deleteLink(int linkId) async {
    await _dio.delete('$_base/$linkId');
  }
}