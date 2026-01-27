import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/features/auth/domain/entities/auth_response.dart';
import 'package:social_app/features/auth/domain/entities/user.dart';
import 'package:social_app/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:social_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:social_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:social_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:social_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:social_app/features/auth/presentation/bloc/auth_state.dart';

import 'auth_bloc_test.mocks.dart';

@GenerateMocks([LoginUseCase, LogoutUseCase, GetCurrentUserUseCase])
void main() {
  late AuthBloc bloc;
  late MockLoginUseCase mockLoginUseCase;
  late MockLogoutUseCase mockLogoutUseCase;
  late MockGetCurrentUserUseCase mockGetCurrentUserUseCase;

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    mockLogoutUseCase = MockLogoutUseCase();
    mockGetCurrentUserUseCase = MockGetCurrentUserUseCase();
    bloc = AuthBloc(
      loginUseCase: mockLoginUseCase,
      logoutUseCase: mockLogoutUseCase,
      getCurrentUserUseCase: mockGetCurrentUserUseCase,
    );
  });

  tearDown(() {
    bloc.close();
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

  test('initial state should be AuthInitial', () {
    expect(bloc.state, const AuthInitial());
  });

  group('AuthLoginRequested', () {
    blocTest<AuthBloc, AuthState>(
      'should emit [AuthLoading, AuthAuthenticated] when login is successful',
      build: () {
        when(mockLoginUseCase(any))
            .thenAnswer((_) async => const Right(tAuthResponse));
        return bloc;
      },
      act: (bloc) => bloc.add(const AuthLoginRequested(
        username: tUsername,
        password: tPassword,
      )),
      expect: () => [
        const AuthLoading(),
        const AuthAuthenticated(tUser),
      ],
      verify: (_) {
        verify(mockLoginUseCase(const LoginParams(
          username: tUsername,
          password: tPassword,
        ))).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'should emit [AuthLoading, AuthError] when login fails',
      build: () {
        when(mockLoginUseCase(any))
            .thenAnswer((_) async => const Left(ServerFailure('Login failed')));
        return bloc;
      },
      act: (bloc) => bloc.add(const AuthLoginRequested(
        username: tUsername,
        password: tPassword,
      )),
      expect: () => [
        const AuthLoading(),
        const AuthError('Login failed'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'should emit [AuthLoading, AuthError] with network error message',
      build: () {
        when(mockLoginUseCase(any))
            .thenAnswer((_) async => const Left(NetworkFailure('No internet connection')));
        return bloc;
      },
      act: (bloc) => bloc.add(const AuthLoginRequested(
        username: tUsername,
        password: tPassword,
      )),
      expect: () => [
        const AuthLoading(),
        const AuthError('No internet connection'),
      ],
    );
  });

  group('AuthLogoutRequested', () {
    blocTest<AuthBloc, AuthState>(
      'should emit [AuthUnauthenticated] when logout is successful',
      build: () {
        when(mockLogoutUseCase()).thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(const AuthLogoutRequested()),
      expect: () => [
        const AuthUnauthenticated(),
      ],
      verify: (_) {
        verify(mockLogoutUseCase()).called(1);
      },
    );
  });

  group('AuthCheckRequested', () {
    blocTest<AuthBloc, AuthState>(
      'should emit [AuthLoading, AuthAuthenticated] when user is authenticated',
      build: () {
        when(mockGetCurrentUserUseCase())
            .thenAnswer((_) async => const Right(tUser));
        return bloc;
      },
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => [
        const AuthLoading(),
        const AuthAuthenticated(tUser),
      ],
      verify: (_) {
        verify(mockGetCurrentUserUseCase()).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'should emit [AuthLoading, AuthUnauthenticated] when user is not authenticated',
      build: () {
        when(mockGetCurrentUserUseCase())
            .thenAnswer((_) async => const Left(CacheFailure('No user found')));
        return bloc;
      },
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => [
        const AuthLoading(),
        const AuthUnauthenticated(),
      ],
    );
  });

  group('AuthUserUpdated', () {
    blocTest<AuthBloc, AuthState>(
      'should emit [AuthAuthenticated] with updated user',
      build: () => bloc,
      act: (bloc) => bloc.add(const AuthUserUpdated(tUser)),
      expect: () => [
        const AuthAuthenticated(tUser),
      ],
    );
  });
}

