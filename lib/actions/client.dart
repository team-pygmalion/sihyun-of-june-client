import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:project_june_client/actions/auth/actions.dart';
import 'package:project_june_client/constants.dart';
import 'package:project_june_client/environments.dart';
import 'package:project_june_client/globals.dart';
import 'package:project_june_client/router.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

final Dio dioForShortener = Dio(
  BaseOptions(
    baseUrl: 'http://pygmalion.im',
  ),
);

final Dio dio = Dio(
  BaseOptions(
    baseUrl: BuildTimeEnvironments.apiBaseUrl,
  ),
);

void initServerErrorSnackbar() {
  dio.interceptors.add(
    InterceptorsWrapper(
      onError: (error, handler) async {
        Sentry.captureException(error);
        if (error.response?.statusCode != null) {
          if (error.response!.statusCode! >= 500) {
            scaffoldMessengerKey.currentState?.showSnackBar(
              const SnackBar(
                content: Text(
                  '서버에 문제가 발생했습니다. 잠시 후 다시 시도해주세요.',
                ),
              ),
            );
          } else if (error.response!.statusCode == 401) {
            await logout();
            router.go(RoutePaths.landing);
            scaffoldMessengerKey.currentState?.showSnackBar(
              const SnackBar(
                content: Text(
                  '로그인이 필요합니다.',
                ),
              ),
            );
          }
        }
        return handler.next(error);
      },
    ),
  );
}
