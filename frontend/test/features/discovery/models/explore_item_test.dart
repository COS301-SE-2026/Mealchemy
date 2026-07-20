import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/discovery/models/explore_item.dart';

void main() {
  group('ExploreItem constructor', () {
    test('creates a recipe item with all fields', () {
      const item = ExploreItem(
        id: 2,
        title: 'Beet Salad',
        imageUrl: 'https://images.unsplash.com/photo-123?w=400',
        matchPercent: 85,
        isMissingItems: true,
        isVideo: false,
      );

      expect(item.id, 2);
      expect(item.title, 'Beet Salad');
      expect(item.matchPercent, 85);
      expect(item.isMissingItems, true);
      expect(item.isVideo, false);
    });

    test('creates a video item with null matchPercent and false isMissingItems', () {
      const item = ExploreItem(
        id: 1,
        title: 'Chef Special',
        imageUrl: '',
        isVideo: true,
      );

      expect(item.isVideo, true);
      expect(item.matchPercent, isNull);
      expect(item.isMissingItems, false);
    });

    test('all optional fields default correctly', () {
      const item = ExploreItem(
        id: 3,
        title: 'Test Recipe',
        imageUrl: '',
      );

      expect(item.isVideo, false);
      expect(item.isMissingItems, false);
      expect(item.matchPercent, isNull);
    });
  });
}