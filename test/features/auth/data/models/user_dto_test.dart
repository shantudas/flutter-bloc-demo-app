import 'package:flutter_test/flutter_test.dart';
import 'package:social_app/features/auth/data/models/user_dto.dart';
import 'package:social_app/features/auth/domain/entities/user.dart';

void main() {
  final tUserDto = UserDto(
    id: 1,
    username: 'testuser',
    email: 'test@example.com',
    firstName: 'Test',
    lastName: 'User',
    image: 'https://example.com/image.jpg',
  );

  const tUser = User(
    id: 1,
    username: 'testuser',
    email: 'test@example.com',
    firstName: 'Test',
    lastName: 'User',
    image: 'https://example.com/image.jpg',
  );

  group('UserDto', () {
    test('should convert from JSON correctly', () {
      // arrange
      final Map<String, dynamic> jsonMap = {
        'id': 1,
        'username': 'testuser',
        'email': 'test@example.com',
        'firstName': 'Test',
        'lastName': 'User',
        'image': 'https://example.com/image.jpg',
      };

      // act
      final result = UserDto.fromJson(jsonMap);

      // assert
      expect(result, tUserDto);
    });

    test('should convert to JSON correctly', () {
      // act
      final result = tUserDto.toJson();

      // assert
      final expectedMap = {
        'id': 1,
        'username': 'testuser',
        'email': 'test@example.com',
        'firstName': 'Test',
        'lastName': 'User',
        'image': 'https://example.com/image.jpg',
      };
      expect(result, expectedMap);
    });

    test('should convert to entity correctly', () {
      // act
      final result = tUserDto.toEntity();

      // assert
      expect(result, tUser);
    });

    test('should create from entity correctly', () {
      // act
      final result = UserDto.fromEntity(tUser);

      // assert
      expect(result.id, tUserDto.id);
      expect(result.username, tUserDto.username);
      expect(result.email, tUserDto.email);
      expect(result.firstName, tUserDto.firstName);
      expect(result.lastName, tUserDto.lastName);
      expect(result.image, tUserDto.image);
    });

    test('should handle null image', () {
      // arrange
      final Map<String, dynamic> jsonMap = {
        'id': 1,
        'username': 'testuser',
        'email': 'test@example.com',
        'firstName': 'Test',
        'lastName': 'User',
        'image': null,
      };

      // act
      final result = UserDto.fromJson(jsonMap);

      // assert
      expect(result.image, isNull);
    });
  });
}

