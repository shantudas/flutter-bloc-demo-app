import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user.dart';

part 'user_dto.g.dart';

@JsonSerializable()
class UserDto {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String? image;

  UserDto({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.image,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) => _$UserDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UserDtoToJson(this);

  User toEntity() {
    return User(
      id: id,
      username: username,
      email: email,
      firstName: firstName,
      lastName: lastName,
      image: image,
    );
  }

  factory UserDto.fromEntity(User user) {
    return UserDto(
      id: user.id,
      username: user.username,
      email: user.email,
      firstName: user.firstName,
      lastName: user.lastName,
      image: user.image,
    );
  }
}

