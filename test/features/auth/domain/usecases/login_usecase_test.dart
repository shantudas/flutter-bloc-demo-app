import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:social_app/features/auth/domain/entities/auth_response.dart';
import 'package:social_app/features/auth/domain/entities/user.dart';
import 'package:social_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:social_app/features/auth/domain/usecases/login_usecase.dart';

import 'login_usecase_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late LoginUseCase useCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    useCase = LoginUseCase(mockAuthRepository);
  });

  const tUsername = 'testuser';
  const tPassword = 'password123';
  const tUser = User(
    id: 1,
    username: tUsername,
    email: 'test@example.com',
    firstName: 'Test',
    lastName: 'User',
  );
  const tAuthResponse = AuthResponse(
    user: tUser,
    accessToken: 'test_access_token',
    refreshToken: 'test_refresh_token',
  );

  test('should get auth response from the repository', () async {
    // arrange
    when(mockAuthRepository.login(
      username: anyNamed('username'),
      password: anyNamed('password'),
    )).thenAnswer((_) async => const Right(tAuthResponse));

    // act
    final result = await useCase(const LoginParams(
      username: tUsername,
      password: tPassword,
    ));

    // assert
    expect(result, const Right(tAuthResponse));
    verify(mockAuthRepository.login(
      username: tUsername,
      password: tPassword,
    ));
    verifyNoMoreInteractions(mockAuthRepository);
  });

  test('LoginParams should have correct props', () {
    const params = LoginParams(username: tUsername, password: tPassword);
    expect(params.props, [tUsername, tPassword]);
  });

  test('LoginParams instances with same values should be equal', () {
    const params1 = LoginParams(username: tUsername, password: tPassword);
    const params2 = LoginParams(username: tUsername, password: tPassword);
    expect(params1, equals(params2));
  });
}

