// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostDto _$PostDtoFromJson(Map<String, dynamic> json) => PostDto(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      body: json['body'] as String,
      userId: (json['userId'] as num).toInt(),
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      reactionsData: json['reactions'],
      views: (json['views'] as num).toInt(),
    );

Map<String, dynamic> _$PostDtoToJson(PostDto instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'body': instance.body,
      'userId': instance.userId,
      'tags': instance.tags,
      'reactions': instance.reactionsData,
      'views': instance.views,
    };
