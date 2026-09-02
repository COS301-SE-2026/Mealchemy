import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/profile/models/user_profile.dart';

void main() {
  group('UserProfile.fromJson', () {
    test(' parses a full payload ', () {
      final profile = UserProfile.fromJson(<String, dynamic>{
        'display_name': 'Mutombo Kabau',
        'avatar_url': 'https://cdn.test/a.png',
        'preferred_unit': 'IMPERIAL',
        'equipment': ['OVEN', 'BLENDER'],
        'updated_at': '2026-08-19T23:00:00Z',
      });
      expect(profile.displayName, 'Mutombo Kabau');
      expect(profile.avatarUrl, 'https://cdn.test/a.png');
      expect(profile.preferredUnit, PreferredUnit.imperial);
      expect(profile.equipment, ['OVEN', 'BLENDER']);
      expect(profile.updatedAt, DateTime.utc(2026, 8, 19, 23));
    });

    test('defaults to metric and empty equipment on a minimal payload', () {
      final profile = UserProfile.fromJson(<String, dynamic>{
        'display_name': 'Chef',
      });

      expect(profile.displayName, 'Chef');
      expect(profile.avatarUrl, isNull);
      expect(profile.preferredUnit, PreferredUnit.metric);
      expect(profile.equipment, isEmpty);
      expect(profile.updatedAt, isNull);
    });

    test('falls back to metric when preferred_unit is unrecognized', () {
      final profile = UserProfile.fromJson(<String, dynamic>{
        'display_name': 'Chef',
        'preferred_unit': 'NONSENSE',
      });
      expect(profile.preferredUnit, PreferredUnit.metric);
    });
  });

  group('UserProfile.toUpdateJson', () {
    test('always sends all four fields (full replace)', () {
      const profile = UserProfile(
        displayName: 'Mutombo Kabau',
        avatarUrl: 'https://cdn.test/a.png',
        preferredUnit: PreferredUnit.metric,
        equipment: ['OVEN'],
      );
      final json = profile.toUpdateJson();

      expect(
          json.keys,
          containsAll(
              ['display_name', 'avatar_url', 'preferred_unit', 'equipment']));
      expect(json['display_name'], 'Mutombo Kabau');
      expect(json['avatar_url'], 'https://cdn.test/a.png');
      expect(json['preferred_unit'], 'METRIC');
      expect(json['equipment'], ['OVEN']);
    });

    test('converts the unit as it backend value and keeps [] equpment', () {
      const profile = UserProfile(
        displayName: 'Chef',
        preferredUnit: PreferredUnit.imperial,
        equipment: [],
      );

      final json = profile.toUpdateJson();
      expect(json['preferred_unit'], 'IMPERIAL');
      expect(json['equipment'], isEmpty);
      expect(json.containsKey('avatar_url'), isTrue); 
      expect(json['avatar_url'], isNull);
    });
  });

  group('UserProfile.initials', () {
    test('takes first and last initials from a full name', () {
      const profile = UserProfile(
        displayName: 'Mutombo Kabau',
        preferredUnit: PreferredUnit.metric,
        equipment: [],
      );
      expect(profile.initials, 'MK');
    });

    test('uses a single initial for a one word name', () {
      const profile = UserProfile(
        displayName: 'Chef',
        preferredUnit: PreferredUnit.metric,
        equipment: [],
      );
      expect(profile.initials, 'C');
    });

    test('falls back to ? for a blank name', () {
      const profile = UserProfile(
        displayName: '   ',
        preferredUnit: PreferredUnit.metric,
        equipment: [],
      );
      expect(profile.initials, '?');
    });
  });

  group('PreferredUnit.fromValue', () {
    test('maps known values', () {
      expect(PreferredUnit.fromValue('METRIC'), PreferredUnit.metric);
      expect(PreferredUnit.fromValue('IMPERIAL'), PreferredUnit.imperial);
    });

    test('defaults to metric for null or unknown', () {
      expect(PreferredUnit.fromValue(null), PreferredUnit.metric);
      expect(PreferredUnit.fromValue('OTHER'), PreferredUnit.metric);
    });
  });
}
