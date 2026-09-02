import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/external_links/models/link.dart';

void main() {
  test('fromJson parses snake_case fields', () {
    final link = Link.fromJson({
      'link_id': 7,
      'name': 'Creamy Garlic Pasta',
      'url': 'https://test1.com/pasta',
      'created_at': '2026-08-31T23:00:00Z',
      'updated_at': null,
    });
    expect(link.linkId, 7);
    expect(link.name, 'Creamy Garlic Pasta');
    expect(link.url, 'https://test1.com/pasta');
    expect(link.createdAt, DateTime.parse('2026-08-31T23:00:00Z'));
    expect(link.updatedAt, isNull);
  });

  test('isEdited is false when updated_at is null', () {
    final link = Link.fromJson({
      'link_id': 1,
      'name': 'Fresh',
      'url': 'https://example.com',
      'created_at': '2026-08-31T23:00:00Z',
      'updated_at': null,
    });

    expect(link.isEdited, isFalse);
  });

  test('isEdited is true once updated_at is set', () {
    final link = Link.fromJson({
      'link_id': 1,
      'name': 'Edited',
      'url': 'https://example.com',
      'created_at': '2026-08-31T23:00:00Z',
      'updated_at': '2026-09-01T10:00:00Z',
    });

    expect(link.isEdited, isTrue);
    expect(link.updatedAt, DateTime.parse('2026-09-01T10:00:00Z'));
  });

  test('toJson sends only name and url', () {
    final link = Link(
      linkId: 3,
      name: 'Lasagna',
      url: 'https://example.com/lasagna',
      createdAt: DateTime.parse('2026-08-31T23:00:00Z'),
    );

    expect(link.toJson(), {
      'name': 'Lasagna',
      'url': 'https://example.com/lasagna',
    });
  });
}