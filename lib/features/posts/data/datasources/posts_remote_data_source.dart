import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/post_dto.dart';

abstract class PostsRemoteDataSource {
  Future<List<PostDto>> getPosts({int limit = 30, int skip = 0});
  Future<PostDto> getPostById(int id);
  Future<PostDto> createPost({
    required String title,
    required String body,
    required int userId,
    List<String>? tags,
  });
  Future<void> deletePost(int id);
  Future<List<PostDto>> searchPosts(String query);
}

class PostsRemoteDataSourceImpl implements PostsRemoteDataSource {
  final ApiClient apiClient;

  PostsRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<PostDto>> getPosts({int limit = 30, int skip = 0}) async {
    try {
      final response = await apiClient.dio.get(
        ApiEndpoints.posts,
        queryParameters: {
          'limit': limit,
          'skip': skip,
        },
      );

      final List<dynamic> posts = response.data['posts'];
      return posts.map((json) => PostDto.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? 'Failed to fetch posts',
      );
    } catch (e) {
      throw ServerException('Unexpected error occurred');
    }
  }

  @override
  Future<PostDto> getPostById(int id) async {
    try {
      final response = await apiClient.dio.get(ApiEndpoints.postById(id));

      return PostDto.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? 'Failed to fetch post',
      );
    } catch (e) {
      throw ServerException('Unexpected error occurred');
    }
  }

  @override
  Future<PostDto> createPost({
    required String title,
    required String body,
    required int userId,
    List<String>? tags,
  }) async {
    try {
      final response = await apiClient.dio.post(
        ApiEndpoints.addPost,
        data: {
          'title': title,
          'body': body,
          'userId': userId,
          'tags': tags ?? [],
        },
      );

      return PostDto.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? 'Failed to create post',
      );
    } catch (e) {
      throw ServerException('Unexpected error occurred');
    }
  }

  @override
  Future<void> deletePost(int id) async {
    try {
      await apiClient.dio.delete(ApiEndpoints.deletePost(id));
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? 'Failed to delete post',
      );
    } catch (e) {
      throw ServerException('Unexpected error occurred');
    }
  }

  @override
  Future<List<PostDto>> searchPosts(String query) async {
    try {
      final response = await apiClient.dio.get(
        ApiEndpoints.searchPosts,
        queryParameters: {'q': query},
      );

      final List<dynamic> posts = response.data['posts'];
      return posts.map((json) => PostDto.fromJson(json)).toList();
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? 'Failed to search posts',
      );
    } catch (e) {
      throw ServerException('Unexpected error occurred');
    }
  }
}

