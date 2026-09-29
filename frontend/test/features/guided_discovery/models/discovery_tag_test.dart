import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/guided_discovery/models/discovery_tag.dart';

void main() {
  group('DiscoveryTag.fromJson', () {
    test('reads id, name and dietary flag', () {
      final tag = DiscoveryTag.fromJson({
        'tagId': 1,
        'tagName': 'VEGETARIAN',
        'isDietary': true,
      });

      expect(tag.tagId, 1);
      expect(tag.tagName, 'VEGETARIAN');
      expect(tag.isDietary, isTrue);
    });

    test('missing dietary flag defaults to false', () {
      final tag = DiscoveryTag.fromJson({'tagId': 12, 'tagName': 'SPICY'});
      expect(tag.isDietary, isFalse);
    });
  });

  group('label', () {
    DiscoveryTag tag(String name) =>
        DiscoveryTag(tagId: 1, tagName: name, isDietary: true);
    test('single word becomes title case', () {
      expect(tag('VEGETARIAN').label, 'Vegetarian');
      expect(tag('KETO').label, 'Keto');
    });

    test('undersores become spaces', () {
      expect(tag('GLUTEN_FREE').label, 'Gluten Free');
      expect(tag('DAIRY_FREE').label, 'Dairy Free');
    });

    test('mixed case from the db still comes out clean ', () {
      expect(tag('DIABETES_Friendly').label, 'Diabetes Friendly');
    });

    test('stray underscores do not leave extra spaces', () {
      expect(tag('_NUT__FREE_').label, 'Nut Free');
    });
  });
}