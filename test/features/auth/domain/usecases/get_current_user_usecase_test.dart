import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:social_app/features/auth/domain/entities/user.dart';
import 'package:social_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:social_app/features/auth/domain/usecases/get_current_user_usecase.dart';

import 'get_current_user_usecase_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late GetCurrentUserUseCase useCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    useCase = GetCurrentUserUseCase(mockAuthRepository);
  });

  const tUser = User(
    id: 1,
    username: 'testuser',
    email: 'test@example.com',
    firstName: 'Test',
    lastName: 'User',
  );

  test('should get current user from the repository', () async {
    // arrange
    when(mockAuthRepository.getCurrentUser())
        .thenAnswer((_) async => const Right(tUser));

    // act
    final result = await useCase();

    // assert
    expect(result, const Right(tUser));
    verify(mockAuthRepository.getCurrentUser());
    verifyNoMoreInteractions(mockAuthRepository);
  });
}

