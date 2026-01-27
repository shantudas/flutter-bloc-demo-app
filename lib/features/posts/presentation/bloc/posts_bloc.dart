import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/usecases/get_posts_usecase.dart';
import 'posts_event.dart';
import 'posts_state.dart';

class PostsBloc extends Bloc<PostsEvent, PostsState> {
  final GetPostsUseCase getPostsUseCase;

  int _currentSkip = 0;

  PostsBloc({
    required this.getPostsUseCase,
  }) : super(const PostsInitial()) {
    on<PostsLoadRequested>(_onLoadRequested);
    on<PostsRefreshRequested>(_onRefreshRequested);
    on<PostsLoadMoreRequested>(_onLoadMoreRequested);
  }

  Future<void> _onLoadRequested(
    PostsLoadRequested event,
    Emitter<PostsState> emit,
  ) async {
    emit(const PostsLoading());

    _currentSkip = 0;
    final result = await getPostsUseCase(
      GetPostsParams(
        limit: AppConstants.postsPerPage,
        skip: _currentSkip,
      ),
    );

    result.fold(
      (failure) => emit(PostsError(failure.message)),
      (posts) {
        emit(PostsLoaded(
          posts: posts,
          hasMore: posts.length >= AppConstants.postsPerPage,
        ));
      },
    );
  }

  Future<void> _onRefreshRequested(
    PostsRefreshRequested event,
    Emitter<PostsState> emit,
  ) async {
    _currentSkip = 0;
    final result = await getPostsUseCase(
      GetPostsParams(
        limit: AppConstants.postsPerPage,
        skip: _currentSkip,
      ),
    );

    result.fold(
      (failure) => emit(PostsError(failure.message)),
      (posts) {
        emit(PostsLoaded(
          posts: posts,
          hasMore: posts.length >= AppConstants.postsPerPage,
        ));
      },
    );
  }

  Future<void> _onLoadMoreRequested(
    PostsLoadMoreRequested event,
    Emitter<PostsState> emit,
  ) async {
    if (state is! PostsLoaded) return;

    final currentState = state as PostsLoaded;
    if (!currentState.hasMore || currentState.isLoadingMore) return;

    emit(currentState.copyWith(isLoadingMore: true));

    _currentSkip += AppConstants.postsPerPage;
    final result = await getPostsUseCase(
      GetPostsParams(
        limit: AppConstants.postsPerPage,
        skip: _currentSkip,
      ),
    );

    result.fold(
      (failure) {
        emit(currentState.copyWith(isLoadingMore: false));
      },
      (newPosts) {
        final allPosts = [...currentState.posts, ...newPosts];
        emit(PostsLoaded(
          posts: allPosts,
          hasMore: newPosts.length >= AppConstants.postsPerPage,
          isLoadingMore: false,
        ));
      },
    );
  }
}

