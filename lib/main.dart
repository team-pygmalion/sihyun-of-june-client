import 'package:cached_query_flutter/cached_query_flutter.dart';
import 'package:cached_storage/cached_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:project_june_client/actions/client.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'constants.dart';
import 'environments.dart';
import 'router.dart';

void main() async {
  CachedQuery.instance.configFlutter(
    config: QueryConfigFlutter(
      refetchOnConnection: true,
      refetchOnResume: true,
    ),
    storage: await CachedStorage.ensureInitialized(),
  );
  assertBuildTimeEnvironments();
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  KakaoSdk.init(
    nativeAppKey: BuildTimeEnvironments.kakaoNativeAppKey,
    javaScriptAppKey: BuildTimeEnvironments.kakaoJavascriptKey,
  );
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final fcmToken = await FirebaseMessaging.instance.getToken();
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  print('User granted permission: ${settings.authorizationStatus}');
  print('fcmToken: $fcmToken');
  runApp(const ProviderScope(child: ProjectJuneApp()));
}

class ProjectJuneApp extends StatefulWidget {
  const ProjectJuneApp({super.key});

  @override
  State<StatefulWidget> createState() => _ProjectJuneApp();
}

class _ProjectJuneApp extends State<ProjectJuneApp> {
  @override
  void initState() {
    super.initState();
    initServerErrorSnackbar(context);
  }

  @override
  Widget build(context) {
    return MaterialApp.router(
      title: '유월의 시현이',
      routerConfig: router,
      theme: ThemeData(
        fontFamily: 'MaruBuri',
        scaffoldBackgroundColor: ColorConstants.background,
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: ColorConstants.primary,
          onPrimary: ColorConstants.white,
          secondary: ColorConstants.secondary,
          onSecondary: ColorConstants.white,
          error: ColorConstants.alert,
          onError: ColorConstants.white,
          background: ColorConstants.background,
          onBackground: ColorConstants.primary,
          surface: ColorConstants.background,
          onSurface: ColorConstants.primary,
        ),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            splashFactory: NoSplash.splashFactory,
            padding: const EdgeInsets.symmetric(
              vertical: 17.0,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: FilledButton.styleFrom(
            splashFactory: NoSplash.splashFactory,
            padding: const EdgeInsets.symmetric(
              vertical: 17.0,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            splashFactory: NoSplash.splashFactory,
            side: BorderSide(
              color: ColorConstants.neutral,
            ),
            padding: const EdgeInsets.symmetric(
              vertical: 17.0,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: ColorConstants.background,
          elevation: 0,
          unselectedItemColor: ColorConstants.primary,
        ),
      ),
    );
  }
}
