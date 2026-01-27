import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/posts_repository.dart';
import '../datasources/posts_local_data_source.dart';
import '../datasources/posts_remote_data_source.dart';

class PostsRepositoryImpl implements PostsRepository {
  final PostsRemoteDataSource remoteDataSource;
  final PostsLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  PostsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Post>>> getPosts({
    int limit = 30,
    int skip = 0,
  }) async {
    try {
      if (await networkInfo.isConnected) {
        final remotePosts = await remoteDataSource.getPosts(
          limit: limit,
          skip: skip,
        );

        // Cache only if it's the first page
        if (skip == 0) {
          await localDataSource.cachePosts(remotePosts);
        }

        return Right(remotePosts.map((dto) => dto.toEntity()).toList());
      } else {
        // Offline: return cached data
        final cachedPosts = await localDataSource.getCachedPosts();
        if (cachedPosts.isNotEmpty) {
          return Right(cachedPosts.map((dto) => dto.toEntity()).toList());
        }
        return const Left(NetworkFailure('No internet connection'));
      }
    } on ServerException catch (e) {
      // Network failed: fallback to cache
      try {
        final cachedPosts = await localDataSource.getCachedPosts();
        if (cachedPosts.isNotEmpty) {
          return Right(cachedPosts.map((dto) => dto.toEntity()).toList());
        }
      } catch (_) {}
      return Left(ServerFailure(e.message));
    } on SocketException {
      // Try to get cached data
      try {
        final cachedPosts = await localDataSource.getCachedPosts();
        if (cachedPosts.isNotEmpty) {
          return Right(cachedPosts.map((dto) => dto.toEntity()).toList());
        }
      } catch (_) {}
      return const Left(NetworkFailure('No internet connection'));
    } catch (e) {
      return Left(CacheFailure('Failed to load posts: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Post>> getPostById(int id) async {
    try {
      // Try cache first
      final cachedPost = await localDataSource.getCachedPost(id);
      if (cachedPost != null && !await networkInfo.isConnected) {
        return Right(cachedPost.toEntity());
      }

      // Fetch from remote if online
      if (await networkInfo.isConnected) {
        final post = await remoteDataSource.getPostById(id);
        await localDataSource.cachePost(post);
        return Right(post.toEntity());
      }

      // Return cached if available
      if (cachedPost != null) {
        return Right(cachedPost.toEntity());
      }

      return const Left(NetworkFailure('No internet connection'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to load post: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Post>> createPost({
    required String title,
    required String body,
    required int userId,
    List<String>? tags,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final post = await remoteDataSource.createPost(
        title: title,
        body: body,
        userId: userId,
        tags: tags,
      );

      return Right(post.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to create post: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deletePost(int id) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      await remoteDataSource.deletePost(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to delete post: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Post>>> searchPosts(String query) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final posts = await remoteDataSource.searchPosts(query);
      return Right(posts.map((dto) => dto.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to search posts: ${e.toString()}'));
    }
  }
}

