import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:project_june_client/actions/client.dart';
import 'package:project_june_client/contrib/flutter_secure_storage.dart';

import 'models/Token.dart';

const _SERVER_TOKEN_KEY = 'SERVER_TOKEN';

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
  final response = await dio.post('/auth/kakao/join-or-login/by-token/', data: {
    'token': token.accessToken,
  }).then<Token>((response) => Token.fromJson(response.data));
  print(response.token);
  return '';
}

void setServerTokenOnDio(String serverToken) {
  dio.options.headers['Authorization'] = "Token $serverToken";
}

Future<void> saveServerToken(String serverToken) async {
  setServerTokenOnDio(serverToken);
  final storage = getSecureStorage();
  await storage.write(key: _SERVER_TOKEN_KEY, value: serverToken);
  return;
}

Future<String?> getServerToken() async {
  final storage = getSecureStorage();
  return await storage.read(key: _SERVER_TOKEN_KEY);
}

Future<bool> loadServerToken() async {
  final storage = getSecureStorage();
  final loaded = await storage.read(key: _SERVER_TOKEN_KEY);
  if (loaded == null) return false;
  setServerTokenOnDio(loaded);
  return true;
}