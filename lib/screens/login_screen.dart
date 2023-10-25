import 'dart:io';

import 'package:cached_query_flutter/cached_query_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:project_june_client/actions/auth/queries.dart';
import 'package:project_june_client/constants.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../widgets/auth/KakaoLoginButton.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  double totalHeight = constraints.maxHeight;
                  double targetPosition = (2 / 5) * totalHeight;

                  return Stack(
                    children: [
                      Positioned(
                        top: targetPosition,
                        left: 0,
                        right: 0,
                        child: Image.asset(
                          'assets/images/logo.png',
                          height: 75,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (Platform.isIOS)
                      MutationBuilder(
                        mutation: getLoginAsAppleMutation(
                          onSuccess: (res, arg) {
                            context.go('/');
                          },
                          onError: (arg, error, callback) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  '애플 로그인 중 에러가 발생했어요.',
                                ),
                              ),
                            );
                          },
                        ),
                        builder: (context, state, mutate) {
                          return FilledButton(
                            onPressed: () => mutate(null),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.apple),
                                SizedBox(width: 8),
                                Text('Apple로 계속하기')
                              ],
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: 10),
                    const KakaoLoginButton(),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        context.go('/login/by-phone');
                      },
                      child: const Text('전화번호로 계속하기'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

