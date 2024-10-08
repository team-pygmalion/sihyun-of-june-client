import 'dart:core';

import 'package:flutter/foundation.dart';

@immutable
class ValidatedPhoneDTO {
  final String phone;
  final String countryCode;

  const ValidatedPhoneDTO({
    required this.phone,
    required this.countryCode,
  });
}

abstract class ValidatedVerifyDTO {
  const ValidatedVerifyDTO();
}

@immutable
class ValidatedAuthCodeDTO extends ValidatedVerifyDTO {
  final int authCode;
  final String countryCode;
  final String phone;

  const ValidatedAuthCodeDTO({
    required this.authCode,
    required this.countryCode,
    required this.phone,
  });
}

@immutable
class ValidatedUserDTO extends ValidatedVerifyDTO {
  final int authCode;
  final String countryCode;
  final String phone;
  final String? firstName;
  final String? lastName;

  const ValidatedUserDTO({
    required this.authCode,
    required this.countryCode,
    required this.phone,
    required this.firstName,
    required this.lastName,
  });
}

@immutable
class UserNameDTO {
  final String firstName;
  final String lastName;

  const UserNameDTO({
    required this.firstName,
    required this.lastName,
  });
}

class QuitReasonDTO {
  Map<String, bool> reasons = <String, bool>{
    'dailyReplyBurden': false,
    'wantOtherCharacters': false,
    'notLikeHuman': false,
    'toResetLetters': false,
    'manyErrors': false,
  };

  bool haveOtherReason = false;
  late String? otherReason;

  QuitReasonDTO({this.otherReason});

  bool get isAllFalse {
    return reasons.values.every((element) => element == false);
  }
}
