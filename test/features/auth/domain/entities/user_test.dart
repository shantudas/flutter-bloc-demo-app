import 'package:flutter_test/flutter_test.dart';
import 'package:social_app/features/auth/domain/entities/user.dart';

void main() {
  group('User', () {
    const tUser = User(
      id: 1,
      username: 'testuser',
      email: 'test@example.com',
      firstName: 'Test',
      lastName: 'User',
      image: 'https://example.com/image.jpg',
    );

    test('should be a subclass of Equatable', () {
      expect(tUser, isA<User>());
    });

    test('fullName should return firstName and lastName combined', () {
      expect(tUser.fullName, 'Test User');
    });

    test('props should contain all user properties', () {
      expect(
        tUser.props,
        [
          tUser.id,
          tUser.username,
          tUser.email,
          tUser.firstName,
          tUser.lastName,
          tUser.image,
        ],
      );
    });

    test('two User instances with same properties should be equal', () {
      const tUser1 = User(
        id: 1,
        username: 'testuser',
        email: 'test@example.com',
        firstName: 'Test',
        lastName: 'User',
        image: 'https://example.com/image.jpg',
      );

      const tUser2 = User(
        id: 1,
        username: 'testuser',
        email: 'test@example.com',
        firstName: 'Test',
        lastName: 'User',
        image: 'https://example.com/image.jpg',
      );

      expect(tUser1, equals(tUser2));
    });

    test('two User instances with different properties should not be equal', () {
      const tUser1 = User(
        id: 1,
        username: 'testuser',
        email: 'test@example.com',
        firstName: 'Test',
        lastName: 'User',
      );

      const tUser2 = User(
        id: 2,
        username: 'testuser2',
        email: 'test2@example.com',
        firstName: 'Test',
        lastName: 'User',
      );

      expect(tUser1, isNot(equals(tUser2)));
    });

    test('should support null image', () {
      const tUserWithoutImage = User(
        id: 1,
        username: 'testuser',
        email: 'test@example.com',
        firstName: 'Test',
        lastName: 'User',
      );

      expect(tUserWithoutImage.image, isNull);
    });
  });
}

