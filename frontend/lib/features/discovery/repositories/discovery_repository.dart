import 'package:mealchemy/features/discovery/models/discovery_category.dart';
import 'package:mealchemy/features/discovery/models/explore_item.dart';
abstract class DiscoveryRepository {
  Future<List<DiscoveryCategory>> getCategories();
  Future<List<ExploreItem>> getExploreItems();
}