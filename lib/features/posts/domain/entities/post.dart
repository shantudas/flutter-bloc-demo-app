import 'package:equatable/equatable.dart';

class Post extends Equatable {
  final int id;
  final String title;
  final String body;
  final int userId;
  final List<String> tags;
  final int reactions;
  final int views;

  const Post({
    required this.id,
    required this.title,
    required this.body,
    required this.userId,
    required this.tags,
    required this.reactions,
    required this.views,
  });

  @override
  List<Object> get props => [id, title, body, userId, tags, reactions, views];
}

