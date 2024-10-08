class BuildTimeEnvironments {
  static String apiBaseUrl = const String.fromEnvironment('API_BASE_URL');
  static String kakaoNativeAppKey =
      const String.fromEnvironment('KAKAO_NATIVE_APP_KEY');
  static String kakaoJavascriptKey =
      const String.fromEnvironment('KAKAO_JAVASCRIPT_KEY');
  static String kakaoTemplateId =
      const String.fromEnvironment('KAKAO_TEMPLATE_ID');
  static String sentryDsn =
      const String.fromEnvironment('SENTRY_DSN'); // Not required
  static String sentryEnvironment =
      const String.fromEnvironment('SENTRY_ENVIRONMENT'); // Not required
  static String appsFlyerDevKey =
      const String.fromEnvironment('APPSFLYER_DEV_KEY'); // Not required
  static bool isProduction =
      const bool.fromEnvironment('IS_LIVE');
}

final REQUIRED_VARIABLES = {
  'API_BASE_URL': BuildTimeEnvironments.apiBaseUrl,
  'KAKAO_NATIVE_APP_KEY': BuildTimeEnvironments.kakaoNativeAppKey,
  'KAKAO_JAVASCRIPT_KEY': BuildTimeEnvironments.kakaoJavascriptKey,
};

void _assertBuildTimeEnvironments(Map<String, String> variables) {
  variables.entries.forEach((entry) {
    assert(entry.value.isNotEmpty,
        '환경변수 ${entry.key} 값을 제공해주세요. (flutter run --dart-define ${entry.key}=...)');
  });
}

void assertBuildTimeEnvironments() {
  _assertBuildTimeEnvironments(REQUIRED_VARIABLES);
}
