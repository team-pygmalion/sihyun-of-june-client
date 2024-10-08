import 'package:cached_query_flutter/cached_query_flutter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:project_june_client/actions/auth/dtos.dart';
import 'package:project_june_client/actions/auth/models/SihyunOfJuneUser.dart';
import 'package:project_june_client/actions/client.dart';
import 'package:project_june_client/constants.dart';
import 'package:project_june_client/contrib/flutter_secure_storage.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'models/Token.dart';

Future<AuthorizationCredentialAppleID> fetchAppleLoginCredential() async {
  try {
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName
      ],
    );
    return credential;
  } catch (error) {
    rethrow;
  }
}

Future<String> fetchServerTokenByAppleCredential(
    AuthorizationCredentialAppleID appleCredentials) async {
  Map<String, dynamic> data = {
    'user_id': appleCredentials.userIdentifier,
  };

  if (appleCredentials.email != null) {
    data['user'] = {
      'email': appleCredentials.email,
      'name': {
        'firstName': appleCredentials.givenName,
        'lastName': appleCredentials.familyName
      }
    };
  }

  final response = await dio
      .post('/auth/apple/join-or-login/by-id/', data: data)
      .then<Token>((response) => Token.fromJson(response.data));
  return response.token;
}

Future<void> sendSmsVerification(String phoneNumber) async {
  await dio.post('/auth/sms-auth/send/',
      data: {'phone': phoneNumber, 'country_code': '82'});
  return;
}

Future<bool> verifySmsCode(ValidatedAuthCodeDTO dto) async {
  try {
    final response = await dio.post('/auth/sms-auth/verify/', data: {
      'phone': dto.phone,
      'country_code': dto.countryCode,
      'auth_code': dto.authCode,
    });
    return await response.data['is_joined'];
  } catch (error) {
    if (error is DioException) {
      if (error.response != null && error.response!.data != null) {
        String detailError = error.response!.data['detail'].toString();
        throw detailError;
      }
    }
    rethrow;
  }
}

Future<String> fetchServerTokenBySMS(ValidatedUserDTO dto) async {
  try {
    final response = await dio.post('/auth/sms-auth/join-or-login/', data: {
      'phone': dto.phone,
      'country_code': dto.countryCode,
      'auth_code': dto.authCode,
      'last_name': dto.lastName,
      'first_name': dto.firstName
    }).then<Token>((response) => Token.fromJson(response.data));
    return response.token;
  } catch (error) {
    if (error is DioException) {
      if (error.response != null && error.response!.data != null) {
        String detailError = error.response!.data['detail'];
        throw detailError;
      }
    }
    rethrow;
  }
}

Future<String> fetchServerTokenBySMSLogin(ValidatedAuthCodeDTO dto) async {
  try {
    final response = await dio.post('/auth/sms-auth/join-or-login/', data: {
      'phone': dto.phone,
      'country_code': dto.countryCode,
      'auth_code': dto.authCode,
    }).then<Token>((response) => Token.fromJson(response.data));
    return response.token;
  } catch (error) {
    if (error is DioException) {
      if (error.response != null && error.response!.data != null) {
        String detailError = error.response!.data['detail'];
        throw detailError;
      }
    }
    rethrow;
  }
}

Future<OAuthToken> fetchKakaoOAuthToken() async {
  if (await isKakaoTalkInstalled()) {
    try {
      return await UserApi.instance.loginWithKakaoTalk();
    } catch (error) {
      if (error is PlatformException && error.code == 'CANCELED') {
        rethrow;
      }
      return await UserApi.instance.loginWithKakaoAccount();
    }
  }
  return await UserApi.instance.loginWithKakaoAccount();
}

Future<String> fetchServerTokenByKakaoToken(OAuthToken token) async {
  final tokenInstance =
      await dio.post('/auth/kakao/join-or-login/by-token/', data: {
    'token': token.accessToken,
  }).then<Token>((response) => Token.fromJson(response.data));
  return tokenInstance.token;
}

Future<SihyunOfJuneUser> fetchMe() async {
  return await dio.get('/auth/me/').then<SihyunOfJuneUser>(
      (response) => SihyunOfJuneUser.fromJson(response.data));
}

void setServerTokenOnDio(String serverToken) {
  dio.options.headers['Authorization'] = 'Token $serverToken';
}

Future<void> login(String serverToken, {bool? saveTokenToClient}) async {
  saveTokenToClient ??= true;
  setServerTokenOnDio(serverToken);
  if (saveTokenToClient) {
    final storage = getSecureStorage();
    await storage.write(
        key: StorageKeyConstants.serverToken, value: serverToken);
  }
}

Future<String?> getServerToken() async {
  final storage = getSecureStorage();
  return await storage.read(key: StorageKeyConstants.serverToken);
}

Future<bool> loadIsLogined() async {
  final storage = getSecureStorage();
  final loaded = await storage.read(key: StorageKeyConstants.serverToken);
  if (loaded == null) return false;
  login(loaded, saveTokenToClient: false);
  return true;
}

Future<void> logout() async {
  final storage = getSecureStorage();
  await storage.deleteAll();
  try {
    await UserApi.instance.logout();
  } catch (error) {}
  CachedQuery.instance.deleteCache();
  dio.options.headers.clear();
  Sentry.configureScope((scope) => scope.setUser(null));
  return;
}

Future<void> changeName(UserNameDTO dto) async {
  await dio.post('/auth/me/name/', data: {
    'first_name': dto.firstName,
    'last_name': dto.lastName,
  });
  return;
}

Future<void> sendQuitResponse(QuitReasonDTO dto) async {
  await dio.post('/auth/quit-response/', data: {
    'reason_multiple_choice': dto.reasons,
    'reason_other': dto.otherReason
  });
  return;
}

Future<void> deleteUser() async {
  var response = await dio.delete('/auth/delete-user/');
  return response.data;
}

Future<void> withdrawUser(QuitReasonDTO dto) async {
  await sendQuitResponse(dto);
  await deleteUser();
  return;
}

Future<void> uploadUserImage(Uint8List img) async {
  var imgFile = MultipartFile.fromBytes(img, filename: 'user_profile.jpg');
  FormData formData = FormData.fromMap({'image': imgFile});
  await dio.post('/auth/me/image/', data: formData);
  return;
}

Future<void> deleteUserImage() async {
  await dio.delete('/auth/me/image/');
  return;
}

Future<String> fetchReferralCode() async {
  var response = await dio.get('/auth/me/referral-code/');
  return response.data['referral_code'];
}

Future<int> fetchNumOfReplies() async {
  var response = await dio.get('/auth/me/num-of-replies/');
  return response.data['num_of_replies'];
}
