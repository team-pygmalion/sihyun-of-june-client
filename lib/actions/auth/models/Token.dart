import 'package:json_annotation/json_annotation.dart';

part 'Token.g.dart';

@JsonSerializable()
class Token {
  int id;
  String token;

  Token({required this.id, required this.token});

  factory Token.fromJson(Map<String, dynamic> json) => _$TokenFromJson(json);

  Map<String, dynamic> toJson() => _$TokenToJson(this);
}
