import '../../../../core/storage/local_storage_service.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_dto.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserDto user);
  Future<UserDto?> getCachedUser();
  Future<void> clearCache();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final LocalStorageService localStorageService;

  static const String _userKey = 'cached_user';

  AuthLocalDataSourceImpl(this.localStorageService);

  @override
  Future<void> cacheUser(UserDto user) async {
    try {
      await localStorageService.usersBox.put(_userKey, user.toJson());
    } catch (e) {
      throw CacheException('Failed to cache user');
    }
  }

  @override
  Future<UserDto?> getCachedUser() async {
    try {
      final data = localStorageService.usersBox.get(_userKey);
      if (data != null) {
        return UserDto.fromJson(Map<String, dynamic>.from(data));
      }
      return null;
    } catch (e) {
      throw CacheException('Failed to get cached user');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await localStorageService.usersBox.delete(_userKey);
    } catch (e) {
      throw CacheException('Failed to clear cache');
    }
  }
}

