import '../../../../core/storage/local_storage_service.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/post_dto.dart';

abstract class PostsLocalDataSource {
  Future<void> cachePosts(List<PostDto> posts);
  Future<List<PostDto>> getCachedPosts();
  Future<void> cachePost(PostDto post);
  Future<PostDto?> getCachedPost(int id);
  Future<void> clearCache();
}

class PostsLocalDataSourceImpl implements PostsLocalDataSource {
  final LocalStorageService localStorageService;

  PostsLocalDataSourceImpl(this.localStorageService);

  @override
  Future<void> cachePosts(List<PostDto> posts) async {
    try {
      final box = localStorageService.postsBox;
      await box.clear();

      for (var post in posts) {
        await box.put(post.id, post.toJson());
      }
    } catch (e) {
      throw CacheException('Failed to cache posts');
    }
  }

  @override
  Future<List<PostDto>> getCachedPosts() async {
    try {
      final box = localStorageService.postsBox;
      final posts = box.values
          .map((data) => PostDto.fromJson(Map<String, dynamic>.from(data)))
          .toList();

      return posts;
    } catch (e) {
      throw CacheException('Failed to get cached posts');
    }
  }

  @override
  Future<void> cachePost(PostDto post) async {
    try {
      await localStorageService.postsBox.put(post.id, post.toJson());
    } catch (e) {
      throw CacheException('Failed to cache post');
    }
  }

  @override
  Future<PostDto?> getCachedPost(int id) async {
    try {
      final data = localStorageService.postsBox.get(id);
      if (data != null) {
        return PostDto.fromJson(Map<String, dynamic>.from(data));
      }
      return null;
    } catch (e) {
      throw CacheException('Failed to get cached post');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await localStorageService.postsBox.clear();
    } catch (e) {
      throw CacheException('Failed to clear cache');
    }
  }
}

