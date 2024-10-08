import 'package:json_annotation/json_annotation.dart';
import 'package:project_june_client/actions/mails/models/Reply.dart';

part 'MailInList.g.dart';

@JsonSerializable()
class MailInList {
  int id;
  int assign;
  DateTime available_at;
  List<Reply>? replies;
  int day;
  bool has_permission;
  bool is_read;

  MailInList({
    required this.id,
    required this.assign,
    required this.available_at,
    required this.replies,
    required this.day,
    required this.has_permission,
    required this.is_read,
  });

  factory MailInList.fromJson(Map<String, dynamic> json) =>
      _$MailInListFromJson(json);

  Map<String, dynamic> toJson() => _$MailInListToJson(this);
}
