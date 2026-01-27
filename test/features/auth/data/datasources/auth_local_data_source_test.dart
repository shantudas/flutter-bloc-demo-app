import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:social_app/core/errors/exceptions.dart';
import 'package:social_app/core/storage/local_storage_service.dart';
import 'package:social_app/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:social_app/features/auth/data/models/user_dto.dart';
import 'package:hive/hive.dart';

import 'auth_local_data_source_test.mocks.dart';

@GenerateMocks([LocalStorageService, Box])
void main() {
  late AuthLocalDataSourceImpl dataSource;
  late MockLocalStorageService mockLocalStorageService;
  late MockBox mockBox;

  setUp(() {
    mockLocalStorageService = MockLocalStorageService();
    mockBox = MockBox();
    dataSource = AuthLocalDataSourceImpl(mockLocalStorageService);
    when(mockLocalStorageService.usersBox).thenReturn(mockBox);
  });

  group('cacheUser', () {
    final tUserDto = UserDto(
      id: 1,
      username: 'testuser',
      email: 'test@example.com',
      firstName: 'Test',
      lastName: 'User',
    );

    test('should call usersBox.put with correct key and data', () async {
      // arrange
      when(mockBox.put(any, any)).thenAnswer((_) async => Future.value());

      // act
      await dataSource.cacheUser(tUserDto);

      // assert
      verify(mockBox.put('cached_user', tUserDto.toJson()));
    });

    test('should throw CacheException when caching fails', () async {
      // arrange
      when(mockBox.put(any, any)).thenThrow(Exception('Cache error'));

      // act
      final call = dataSource.cacheUser;

      // assert
      expect(() => call(tUserDto), throwsA(isA<CacheException>()));
    });
  });

  group('getCachedUser', () {
    final tUserDto = UserDto(
      id: 1,
      username: 'testuser',
      email: 'test@example.com',
      firstName: 'Test',
      lastName: 'User',
    );

    final tUserJson = {
      'id': 1,
      'username': 'testuser',
      'email': 'test@example.com',
      'firstName': 'Test',
      'lastName': 'User',
    };

    test('should return UserDto from cache when data exists', () async {
      // arrange
      when(mockBox.get(any)).thenReturn(tUserJson);

      // act
      final result = await dataSource.getCachedUser();

      // assert
      verify(mockBox.get('cached_user'));
      expect(result!.id, tUserDto.id);
      expect(result.username, tUserDto.username);
      expect(result.email, tUserDto.email);
    });

    test('should return null when no cached data exists', () async {
      // arrange
      when(mockBox.get(any)).thenReturn(null);

      // act
      final result = await dataSource.getCachedUser();

      // assert
      verify(mockBox.get('cached_user'));
      expect(result, isNull);
    });

    test('should throw CacheException when getting cached user fails', () async {
      // arrange
      when(mockBox.get(any)).thenThrow(Exception('Cache error'));

      // act
      final call = dataSource.getCachedUser;

      // assert
      expect(() => call(), throwsA(isA<CacheException>()));
    });
  });

  group('clearCache', () {
    test('should call usersBox.delete with correct key', () async {
      // arrange
      when(mockBox.delete(any)).thenAnswer((_) async => Future.value());

      // act
      await dataSource.clearCache();

      // assert
      verify(mockBox.delete('cached_user'));
    });

    test('should throw CacheException when clearing cache fails', () async {
      // arrange
      when(mockBox.delete(any)).thenThrow(Exception('Cache error'));

      // act
      final call = dataSource.clearCache;

      // assert
      expect(() => call(), throwsA(isA<CacheException>()));
    });
  });
}

