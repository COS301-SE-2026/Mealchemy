import 'package:mealchemy/features/discovery/models/discovery_category.dart';
import 'package:mealchemy/features/discovery/repositories/discovery_repository.dart';


class MockDiscoveryRepository implements DiscoveryRepository{
  @override
  Future<List<DiscoveryCategory>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return const [
       DiscoveryCategory(
        id: 1,
        name: 'Italian',
        imageUrl: '',
      ),
      DiscoveryCategory(
        id: 2,
        name: 'Japanese',
        imageUrl: '',
      ),
      DiscoveryCategory(
        id: 3,
        name: 'Indian',
        imageUrl: '',
      ),
      DiscoveryCategory(
        id: 4,
        name: 'Mexican',
        imageUrl: '',
      ),
      DiscoveryCategory(
        id: 5,
        name: 'Chinese',
        imageUrl: '',
      ),
      DiscoveryCategory(
        id: 6,
        name: 'Thai',
        imageUrl: '',
      ),
      DiscoveryCategory(
        id: 7,
        name: 'Mediterranean',
        imageUrl: '',
      ),
      DiscoveryCategory(
        id: 8,
        name: 'French',
        imageUrl: '',
      ),
      DiscoveryCategory(
        id: 9,
        name: 'American',
        imageUrl: '',
      ),
      DiscoveryCategory(
        id: 10,
        name: 'Middle Eastern',
        imageUrl: '',
      ),
      DiscoveryCategory(
        id: 11,
        name: 'South African',
        imageUrl: '',
      ),
    ];
  }
}