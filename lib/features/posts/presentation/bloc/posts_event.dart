import 'package:equatable/equatable.dart';

abstract class PostsEvent extends Equatable {
  const PostsEvent();

  @override
  List<Object?> get props => [];
}

class PostsLoadRequested extends PostsEvent {
  const PostsLoadRequested();
}

class PostsRefreshRequested extends PostsEvent {
  const PostsRefreshRequested();
}

class PostsLoadMoreRequested extends PostsEvent {
  const PostsLoadMoreRequested();
}

class PostsSearchRequested extends PostsEvent {
  final String query;

  const PostsSearchRequested(this.query);

  @override
  List<Object> get props => [query];
}

class PostCreateRequested extends PostsEvent {
  final String title;
  final String body;
  final List<String> tags;

  const PostCreateRequested({
    required this.title,
    required this.body,
    this.tags = const [],
  });

  @override
  List<Object> get props => [title, body, tags];
}

