import 'package:cached_query_flutter/cached_query_flutter.dart';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:project_june_client/actions/auth/dtos.dart';
import 'package:project_june_client/actions/auth/models/SihyunOfJuneUser.dart';
import 'package:project_june_client/actions/client.dart';
import 'package:project_june_client/contrib/flutter_secure_storage.dart';
import 'package:project_june_client/services.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../notification/actions.dart';
import 'models/Token.dart';

const _SERVER_TOKEN_KEY = 'SERVER_TOKEN';

Future<AuthorizationCredentialAppleID> getAppleLoginCredential() async {
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

Future<String> getServerTokenByAppleCredential(
    AuthorizationCredentialAppleID appleCredentials) async {
  Map<String, dynamic> data = {
    "user_id": appleCredentials.userIdentifier,
  };

  if (appleCredentials.email != null) {
    data["user"] = {
      "email": appleCredentials.email,
      "name": {
        "firstName": appleCredentials.givenName,
        "lastName": appleCredentials.familyName
      }
    };
  }

  final response = await dio
      .post('/auth/apple/join-or-login/by-id/', data: data)
      .then<Token>((response) => Token.fromJson(response.data));
  return response.token;
}

Future<void> smsSend(String phoneNumber) async {
  await dio.post('/auth/sms-auth/send/',
      data: {'phone': phoneNumber, 'country_code': '82'});
  return;
}

Future<bool> smsVerify(ValidatedAuthCodeDTO dto) async {
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
    throw error;
  }
}

Future<String> getServerTokenBySMS(ValidatedUserDTO dto) async {
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
    throw error;
  }
}

Future<String> getServerTokenBySMSLogin(ValidatedAuthCodeDTO dto) async {
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
    throw error;
  }
}

Future<OAuthToken> getKakaoOAuthToken() async {
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

Future<String> getServerTokenByKakaoToken(OAuthToken token) async {
  final tokenInstance =
      await dio.post('/auth/kakao/join-or-login/by-token/', data: {
    'token': token.accessToken,
  }).then<Token>((response) => Token.fromJson(response.data));
  return tokenInstance.token;
}

Future<SihyunOfJuneUser> retrieveMe() async {
  return await dio.get('/auth/me/').then<SihyunOfJuneUser>(
      (response) => SihyunOfJuneUser.fromJson(response.data));
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  if (message.notification != null) {
    notificationService.handleNewNotification();
  }
}

void setServerTokenOnDio(String serverToken) {
  dio.options.headers['Authorization'] = "Token $serverToken";
}

Future<void> login(String serverToken, {bool? saveTokenToClient}) async {
  saveTokenToClient ??= true;
  setServerTokenOnDio(serverToken);
  if (saveTokenToClient) {
    final storage = getSecureStorage();
    await storage.write(key: _SERVER_TOKEN_KEY, value: serverToken);
  }
  FirebaseMessaging.instance
      .getToken()
      .then((token) => token != null ? getOrCreateUserDevice(token) : null);
  FirebaseMessaging.instance.onTokenRefresh
      .listen((token) => getOrCreateUserDevice(token));
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (message.notification != null) {
      notificationService.handleNewNotification();
    }
  });
  FirebaseMessaging.onMessageOpenedApp
      .listen(notificationService.handleFCMMessageTap);
  await notificationService.addBadgeControlListener();
}

Future<String?> getServerToken() async {
  final storage = getSecureStorage();
  return await storage.read(key: _SERVER_TOKEN_KEY);
}

Future<bool> loadIsLogined() async {
  final storage = getSecureStorage();
  final loaded = await storage.read(key: _SERVER_TOKEN_KEY);
  if (loaded == null) return false;
  login(loaded, saveTokenToClient: false);
  return true;
}

logout() async {
  final storage = getSecureStorage();
  await storage.deleteAll();
  try {
    await UserApi.instance.logout();
  } catch (e) {}
  CachedQuery.instance.deleteCache();
  dio.options.headers.clear();
  return;
}
