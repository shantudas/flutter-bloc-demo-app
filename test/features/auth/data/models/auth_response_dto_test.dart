import 'package:flutter_test/flutter_test.dart';
import 'package:social_app/features/auth/data/models/auth_response_dto.dart';
import 'package:social_app/features/auth/data/models/user_dto.dart';
import 'package:social_app/features/auth/domain/entities/auth_response.dart';
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

  final tAuthResponseDto = AuthResponseDto(
    id: 1,
    username: 'testuser',
    email: 'test@example.com',
    firstName: 'Test',
    lastName: 'User',
    image: 'https://example.com/image.jpg',
    accessToken: 'test_access_token',
    refreshToken: 'test_refresh_token',
  );

  const tUser = User(
    id: 1,
    username: 'testuser',
    email: 'test@example.com',
    firstName: 'Test',
    lastName: 'User',
    image: 'https://example.com/image.jpg',
  );

  const tAuthResponse = AuthResponse(
    user: tUser,
    accessToken: 'test_access_token',
    refreshToken: 'test_refresh_token',
  );

  group('AuthResponseDto', () {
    test('should convert from JSON correctly', () {
      // arrange
      final Map<String, dynamic> jsonMap = {
        'id': 1,
        'username': 'testuser',
        'email': 'test@example.com',
        'firstName': 'Test',
        'lastName': 'User',
        'image': 'https://example.com/image.jpg',
        'accessToken': 'test_access_token',
        'refreshToken': 'test_refresh_token',
      };

      // act
      final result = AuthResponseDto.fromJson(jsonMap);

      // assert
      expect(result.id, tAuthResponseDto.id);
      expect(result.username, tAuthResponseDto.username);
      expect(result.accessToken, tAuthResponseDto.accessToken);
      expect(result.refreshToken, tAuthResponseDto.refreshToken);
    });

    test('should convert to JSON correctly', () {
      // act
      final result = tAuthResponseDto.toJson();

      // assert
      final expectedMap = {
        'id': 1,
        'username': 'testuser',
        'email': 'test@example.com',
        'firstName': 'Test',
        'lastName': 'User',
        'image': 'https://example.com/image.jpg',
        'accessToken': 'test_access_token',
        'refreshToken': 'test_refresh_token',
      };
      expect(result, expectedMap);
    });

    test('should convert to entity correctly', () {
      // act
      final result = tAuthResponseDto.toEntity();

      // assert
      expect(result, tAuthResponse);
    });

    test('should handle null refreshToken and use accessToken as fallback', () {
      // arrange
      final dtoWithoutRefreshToken = AuthResponseDto(
        id: 1,
        username: 'testuser',
        email: 'test@example.com',
        firstName: 'Test',
        lastName: 'User',
        accessToken: 'test_access_token',
        refreshToken: null,
      );

      // act
      final result = dtoWithoutRefreshToken.toEntity();

      // assert
      expect(result.refreshToken, 'test_access_token');
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
        'accessToken': 'test_access_token',
        'refreshToken': 'test_refresh_token',
      };

      // act
      final result = AuthResponseDto.fromJson(jsonMap);

      // assert
      expect(result.image, isNull);
    });
  });
}

