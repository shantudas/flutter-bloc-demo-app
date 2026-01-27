import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/post.dart';

abstract class PostsRepository {
  Future<Either<Failure, List<Post>>> getPosts({
    int limit = 30,
    int skip = 0,
  });

  Future<Either<Failure, Post>> getPostById(int id);

  Future<Either<Failure, Post>> createPost({
    required String title,
    required String body,
    required int userId,
    List<String>? tags,
  });

  Future<Either<Failure, void>> deletePost(int id);

  Future<Either<Failure, List<Post>>> searchPosts(String query);
}

