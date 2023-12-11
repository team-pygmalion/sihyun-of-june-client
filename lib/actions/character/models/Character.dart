import 'package:json_annotation/json_annotation.dart';
import 'package:project_june_client/actions/character/models/CharacterInfo.dart';
import 'package:project_june_client/actions/character/models/CharacterTheme.dart';

part 'Character.g.dart';

@JsonSerializable()
class Character {
  int id;
  bool is_active;
  String? name;
  CharacterInfo? character_info;
  CharacterTheme? theme;
  bool is_image_updated;

  Character(
      {required this.id,
      required this.is_active,
      required this.name,
      required this.character_info,
      required this.theme,
      required this.is_image_updated});

  factory Character.fromJson(Map<String, dynamic> json) =>
      _$CharacterFromJson(json);

  Map<String, dynamic> toJson() => _$CharacterToJson(this);
}
