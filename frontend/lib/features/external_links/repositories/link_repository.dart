import '../models/link.dart';


abstract class LinkRepository {
  Future<List<Link>> getLinks();
  Future<Link> createLink({required String name, required String url});
  Future<Link> updateLink({
    required int linkId,
    required String name,
    required String url,
  });
  Future<void> deleteLink(int linkId);
}