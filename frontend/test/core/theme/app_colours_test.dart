import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealchemy/core/theme/app_colours.dart';

void main() {
  group('AppColors', () {
    test('primary colour is not transparent', () {
      expect(AppColors.primary.alpha, 255);
    });

    test('brand gradient has correct direction', () {
      expect(AppColors.brand.begin, Alignment.centerLeft);
      expect(AppColors.brand.end, Alignment.centerRight);
    });

    test('brand gradient has at least 2 colours', () {
      expect(AppColors.brand.colors.length, greaterThanOrEqualTo(2));
    });
  });
}
