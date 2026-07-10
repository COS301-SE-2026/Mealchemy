import 'package:mealchemy/features/discovery/models/discovery_category.dart';
import 'package:mealchemy/features/discovery/repositories/discovery_repository.dart';
import 'package:mealchemy/features/discovery/models/explore_item.dart';
class ApiDiscoveryRepository implements DiscoveryRepository {
  @override
  Future<List<DiscoveryCategory>> getCategories() {
    throw UnimplementedError('Will be implemeneted in the future');
  }

  @override
  Future<List<ExploreItem>> getExploreItems() {
    throw UnimplementedError('Will be implemeneted in the future');
  }
}