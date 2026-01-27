import 'package:json_annotation/json_annotation.dart';
import 'user_dto.dart';
import '../../domain/entities/auth_response.dart';

part 'auth_response_dto.g.dart';

@JsonSerializable()
class AuthResponseDto {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String? image;
  final String accessToken;
  final String? refreshToken;

  AuthResponseDto({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.image,
    required this.accessToken,
    this.refreshToken,
  });

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) => _$AuthResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseDtoToJson(this);

  AuthResponse toEntity() {
    return AuthResponse(
      user: UserDto(
        id: id,
        username: username,
        email: email,
        firstName: firstName,
        lastName: lastName,
        image: image,
      ).toEntity(),
      accessToken: accessToken,
      refreshToken: refreshToken ?? accessToken,
    );
  }
}

