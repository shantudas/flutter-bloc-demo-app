import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/post.dart';
import '../repositories/posts_repository.dart';

class GetPostsUseCase {
  final PostsRepository repository;

  GetPostsUseCase(this.repository);

  Future<Either<Failure, List<Post>>> call(GetPostsParams params) async {
    return await repository.getPosts(
      limit: params.limit,
      skip: params.skip,
    );
  }
}

class GetPostsParams extends Equatable {
  final int limit;
  final int skip;

  const GetPostsParams({
    this.limit = 30,
    this.skip = 0,
  });

  @override
  List<Object> get props => [limit, skip];
}

