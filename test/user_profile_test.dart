import 'package:flutter_test/flutter_test.dart';
import 'package:amudhu/models/nutrition_model.dart';
import 'package:amudhu/services/auth_service.dart';

void main() {
  group('UserProfile Model', () {
    test('creates UserProfile with defaults', () {
      const profile = UserProfile(
        uid: 'user-123',
        name: 'Test User',
        email: 'test@example.com',
      );

      expect(profile.uid, 'user-123');
      expect(profile.name, 'Test User');
      expect(profile.email, 'test@example.com');
      expect(profile.dietPreference, 'Vegetarian');
      expect(profile.role, 'user');
    });

    test('serializes toMap and deserializes fromMap', () {
      final now = DateTime(2026, 10, 9, 12, 0, 0);
      final profile = UserProfile(
        uid: 'user-456',
        name: 'Food Lover',
        email: 'food@example.com',
        dietPreference: 'Vegan',
        createdAt: now,
        updatedAt: now,
      );

      final map = profile.toMap();
      expect(map['uid'], 'user-456');
      expect(map['name'], 'Food Lover');
      expect(map['email'], 'food@example.com');
      expect(map['dietPreference'], 'Vegan');
      expect(map['role'], 'user');
      expect(map['createdAt'], now);

      final recreated = UserProfile.fromMap(map);
      expect(recreated.uid, 'user-456');
      expect(recreated.name, 'Food Lover');
      expect(recreated.email, 'food@example.com');
      expect(recreated.dietPreference, 'Vegan');
      expect(recreated.createdAt, now);
    });

    test('copyWith updates fields without mutating original', () {
      const original = UserProfile(
        uid: 'user-789',
        name: 'Original Name',
        email: 'orig@example.com',
      );

      final updated = original.copyWith(name: 'Updated Name');
      expect(updated.name, 'Updated Name');
      expect(updated.email, 'orig@example.com');
      expect(original.name, 'Original Name');
    });
  });

  group('AuthService Exception', () {
    test('AuthServiceException formats message properly', () {
      const ex = AuthServiceException('Invalid credentials', code: 'invalid-credential');
      expect(ex.toString(), 'Invalid credentials');
      expect(ex.code, 'invalid-credential');
    });
  });
}
