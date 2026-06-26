import 'package:mealchemy/features/discovery/models/discovery_category.dart';
import 'package:mealchemy/features/discovery/repositories/discovery_repository.dart';
import 'package:mealchemy/features/discovery/models/explore_item.dart';

class MockDiscoveryRepository implements DiscoveryRepository {
  @override
  Future<List<DiscoveryCategory>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return const [
      DiscoveryCategory(
        id: 1,
        name: 'Italian',
        imageUrl:
            'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400',
      ),
      DiscoveryCategory(
        id: 2,
        name: 'Japanese',
        imageUrl:
            'https://images.unsplash.com/photo-1611518040286-9af8ba97ab46?w=400',
      ),
      DiscoveryCategory(
        id: 3,
        name: 'Indian',
        imageUrl:
            'https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=400',
      ),
      DiscoveryCategory(
        id: 4,
        name: 'Mexican',
        imageUrl:
            'https://images.unsplash.com/photo-1565299585323-38d6b0865b47?w=400',
      ),
      DiscoveryCategory(
        id: 5,
        name: 'Chinese',
        imageUrl:
            'https://images.unsplash.com/photo-1563245372-f21724e3856d?w=400',
      ),
      DiscoveryCategory(
        id: 6,
        name: 'Thai',
        imageUrl:
            'https://images.unsplash.com/photo-1559314809-0d155014e29e?w=400',
      ),
      DiscoveryCategory(
        id: 7,
        name: 'Mediterranean',
        imageUrl:
            'https://images.unsplash.com/photo-1540189549336-e6e99eb4b2e4?w=400',
      ),
      DiscoveryCategory(
        id: 8,
        name: 'French',
        imageUrl:
            'https://images.unsplash.com/photo-1529543544282-ea669407fca3?w=400',
      ),
      DiscoveryCategory(
        id: 9,
        name: 'American',
        imageUrl:
            'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400',
      ),
      DiscoveryCategory(
        id: 10,
        name: 'Middle Eastern',
        imageUrl:
            'https://images.unsplash.com/photo-1541518763669-27fef04b14ea?w=400',
      ),
      DiscoveryCategory(
        id: 11,
        name: 'South African',
        imageUrl:
            'https://images.unsplash.com/photo-1544025162-d76694265947?w=400',
      ),
    ];
  }

  @override
  Future<List<ExploreItem>> getExploreItems() async {
    return const [
      //Block 1 video on left
      ExploreItem(
        id: 1,
        title: 'Chef Special',
        imageUrl:
            'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400',
        isVideo: true,
      ),
      //images for the rest of the items
      ExploreItem(
        id: 2,
        title: 'Beet Salad',
        imageUrl:
            'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400',
        matchPercent: 85,
      ),
      ExploreItem(
        id: 3,
        title: 'Green Glow Bowl',
        imageUrl:
            'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=400',
        matchPercent: 88,
        isMissingItems: true,
      ),
      ExploreItem(
        id: 4,
        title: 'Pan-Seared Scallops',
        imageUrl:
            'https://images.unsplash.com/photo-1559314809-0d155014e29e?w=400',
        matchPercent: 88,
      ),
      ExploreItem(
        id: 5,
        title: 'Charred Sirloin',
        imageUrl:
            'https://images.unsplash.com/photo-1544025162-d76694265947?w=400',
        matchPercent: 95,
      ),

      //Block 2 video on right
      ExploreItem(
        id: 6,
        title: 'Citrus Salmon',
        imageUrl:
            'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=400',
        matchPercent: 85,
      ),
      ExploreItem(
        id: 7,
        title: 'Rainbow Tofu Bowl',
        imageUrl:
            'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400',
        matchPercent: 88,
        isMissingItems: true,
      ),
      ExploreItem(
        id: 8,
        title: 'Braised Short Rib',
        imageUrl:
            'https://images.unsplash.com/photo-1621996346565-e3dbc646d9a9?w=400',
        matchPercent: 85,
      ),
      ExploreItem(
        id: 9,
        title: 'Sourdough Margherita',
        imageUrl:
            'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=400',
        matchPercent: 88,
      ),
      ExploreItem(
        id: 10,
        title: 'Sauce Reel',
        imageUrl:
            'https://images.unsplash.com/photo-1606313564200-e75d5e30476c?w=400',
        isVideo: true,
      ),
    ];
  }
}
