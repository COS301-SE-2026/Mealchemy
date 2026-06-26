import 'package:mealchemy/features/discovery/models/discovery_category.dart';

abstract class DiscoveryRepository {
  Future<List<DiscoveryCategory>> getCategories();
}