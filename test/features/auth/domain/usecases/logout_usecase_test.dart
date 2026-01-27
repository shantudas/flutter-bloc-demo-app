import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:social_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:social_app/features/auth/domain/usecases/logout_usecase.dart';

import 'logout_usecase_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late LogoutUseCase useCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    useCase = LogoutUseCase(mockAuthRepository);
  });

  test('should call logout on the repository', () async {
    // arrange
    when(mockAuthRepository.logout())
        .thenAnswer((_) async => const Right(null));

    // act
    final result = await useCase();

    // assert
    expect(result, const Right(null));
    verify(mockAuthRepository.logout());
    verifyNoMoreInteractions(mockAuthRepository);
  });
}

