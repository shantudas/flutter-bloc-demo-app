import 'package:flutter_test/flutter_test.dart';
import 'package:social_app/features/auth/domain/entities/auth_response.dart';
import 'package:social_app/features/auth/domain/entities/user.dart';

void main() {
  group('AuthResponse', () {
    const tUser = User(
      id: 1,
      username: 'testuser',
      email: 'test@example.com',
      firstName: 'Test',
      lastName: 'User',
    );

    const tAuthResponse = AuthResponse(
      user: tUser,
      accessToken: 'test_access_token',
      refreshToken: 'test_refresh_token',
    );

    test('should be a subclass of Equatable', () {
      expect(tAuthResponse, isA<AuthResponse>());
    });

    test('props should contain all properties', () {
      expect(
        tAuthResponse.props,
        [tAuthResponse.user, tAuthResponse.accessToken, tAuthResponse.refreshToken],
      );
    });

    test('two AuthResponse instances with same properties should be equal', () {
      const tAuthResponse1 = AuthResponse(
        user: tUser,
        accessToken: 'test_access_token',
        refreshToken: 'test_refresh_token',
      );

      const tAuthResponse2 = AuthResponse(
        user: tUser,
        accessToken: 'test_access_token',
        refreshToken: 'test_refresh_token',
      );

      expect(tAuthResponse1, equals(tAuthResponse2));
    });

    test('two AuthResponse instances with different tokens should not be equal', () {
      const tAuthResponse1 = AuthResponse(
        user: tUser,
        accessToken: 'test_access_token',
        refreshToken: 'test_refresh_token',
      );

      const tAuthResponse2 = AuthResponse(
        user: tUser,
        accessToken: 'different_access_token',
        refreshToken: 'test_refresh_token',
      );

      expect(tAuthResponse1, isNot(equals(tAuthResponse2)));
    });
  });
}

