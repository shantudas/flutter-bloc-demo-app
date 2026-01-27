import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/post.dart';

part 'post_dto.g.dart';

@JsonSerializable()
class PostDto {
  final int id;
  final String title;
  final String body;
  final int userId;
  final List<String> tags;
  @JsonKey(name: 'reactions')
  final dynamic reactionsData;
  final int views;

  PostDto({
    required this.id,
    required this.title,
    required this.body,
    required this.userId,
    required this.tags,
    this.reactionsData,
    required this.views,
  });

  factory PostDto.fromJson(Map<String, dynamic> json) => _$PostDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PostDtoToJson(this);

  int get reactions {
    if (reactionsData is Map) {
      final likes = (reactionsData as Map)['likes'] ?? 0;
      final dislikes = (reactionsData as Map)['dislikes'] ?? 0;
      return (likes + dislikes) as int;
    } else if (reactionsData is int) {
      return reactionsData as int;
    }
    return 0;
  }

  Post toEntity() {
    return Post(
      id: id,
      title: title,
      body: body,
      userId: userId,
      tags: tags,
      reactions: reactions,
      views: views,
    );
  }

  factory PostDto.fromEntity(Post post) {
    return PostDto(
      id: post.id,
      title: post.title,
      body: post.body,
      userId: post.userId,
      tags: post.tags,
      reactionsData: post.reactions,
      views: post.views,
    );
  }
}

