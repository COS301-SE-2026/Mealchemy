import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/discovery/models/discovery_category.dart';

void main() {
  group('DiscoveryCategory constructor', () {
    test('stores all fields correctly', () {
      const category = DiscoveryCategory(
        id: 1,
        name: 'Italian',
        imageUrl: 'https://images.unsplash.com/photo-123?w=400',
      );

      expect(category.id, 1);
      expect(category.name, 'Italian');
      expect(category.imageUrl, 'https://images.unsplash.com/photo-123?w=400');
    });
  });
}