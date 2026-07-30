import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/features/dashboard/repositories/api_dashboard_repository.dart';

void main() {
  group('ApiDashboardRepository (unimplemented stub)', () {
    final repo = ApiDashboardRepository();

    test('getDisplayName throws UnimplementedError', () {
      expect(repo.getDisplayName, throwsUnimplementedError);
    });

    test('getPantryItemCount throws UnimplementedError', () {
      expect(repo.getPantryItemCount, throwsUnimplementedError);
    });
  });
}