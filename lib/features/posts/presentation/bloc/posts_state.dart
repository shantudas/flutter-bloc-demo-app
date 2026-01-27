import 'package:equatable/equatable.dart';
import '../../domain/entities/post.dart';

abstract class PostsState extends Equatable {
  const PostsState();

  @override
  List<Object> get props => [];
}

class PostsInitial extends PostsState {
  const PostsInitial();
}

class PostsLoading extends PostsState {
  const PostsLoading();
}

class PostsLoaded extends PostsState {
  final List<Post> posts;
  final bool hasMore;
  final bool isLoadingMore;

  const PostsLoaded({
    required this.posts,
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  @override
  List<Object> get props => [posts, hasMore, isLoadingMore];

  PostsLoaded copyWith({
    List<Post>? posts,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return PostsLoaded(
      posts: posts ?? this.posts,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class PostsError extends PostsState {
  final String message;

  const PostsError(this.message);

  @override
  List<Object> get props => [message];
}

