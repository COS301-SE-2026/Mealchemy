import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/api_service_provider.dart';
import '../models/link.dart';
import '../repositories/api_link_repository.dart';
import '../repositories/link_repository.dart';

final linkRepositoryProvider = Provider<LinkRepository>((ref) {
  return ApiLinkRepository(ref.read(dioProvider));
});

final linksProvider = AsyncNotifierProvider<LinksNotifier, List<Link>>(
  LinksNotifier.new,
);

class LinksNotifier extends AsyncNotifier<List<Link>> {
  LinkRepository get _repository => ref.read(linkRepositoryProvider);

  @override
  Future<List<Link>> build() {
    return _repository.getLinks();
  }
  Future<void> addLink({required String name, required String url}) async {
    final current = state.valueOrNull ?? [];
    final created = await _repository.createLink(name: name, url: url);
    state = AsyncData([...current, created]);
  }

  Future<void> editLink({
    required int linkId,
    required String name,
    required String url,
  }) async {
    final current = state.valueOrNull ?? [];
    final updated = await _repository.updateLink(
      linkId: linkId,
      name: name,
      url: url,
    );
    state = AsyncData([
      for (final link in current)
        if (link.linkId == linkId) updated else link,
    ]);
  }
  
  Future<void> removeLink(int linkId) async {
    final current = state.valueOrNull ?? [];
    await _repository.deleteLink(linkId);
    state = AsyncData(
      current.where((link) => link.linkId != linkId).toList(),
    );
  }
}