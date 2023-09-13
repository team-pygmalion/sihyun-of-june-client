import 'package:cached_query_flutter/cached_query_flutter.dart';
import 'package:project_june_client/actions/auth/dtos.dart';

import 'actions.dart';

Mutation<void, void> getLoginAsKakaoMutation({
  OnSuccessCallback? onSuccess,
  OnErrorCallback? onError,
}) {
  return Mutation<void, void>(
    queryFn: (void _) async {
      final token = await getKakaoOAuthToken();
      final serverToken = await getServerTokenByKakaoToken(token);
      await saveServerToken(serverToken);
    },
    onSuccess: onSuccess,
    onError: onError,
  );
}

Mutation<void, void> getLoginAsAppleMutation({
  OnSuccessCallback? onSuccess,
  OnErrorCallback? onError,
}) {
  return Mutation<void, void>(
    queryFn: (void _) async {
      final appleCredentials = await getAppleLoginCredential();
      final serverToken =
          await getServerTokenByAppleCredential(appleCredentials);
      await saveServerToken(serverToken);
    },
    onSuccess: onSuccess,
    onError: onError,
  );
}

Mutation<void, String> getSmsSendMutation({
  OnSuccessCallback? onSuccess,
  OnErrorCallback? onError,
}) {
  return Mutation<void, String>(
    queryFn: smsSend,
    onSuccess: onSuccess,
    onError: onError,
  );
}

Mutation<bool, ValidatedAuthCodeDTO> getSmsVerifyMutation({
  OnSuccessCallback? onSuccess,
  OnErrorCallback? onError,
}) {
  return Mutation<bool, ValidatedAuthCodeDTO>(
    queryFn: smsVerify,
    onSuccess: onSuccess,
    onError: onError,
  );
}

Mutation<void, ValidatedVerifyDTO> getSmsTokenMutation({
  OnSuccessCallback? onSuccess,
  OnErrorCallback? onError,
}) {
  return Mutation<void, ValidatedVerifyDTO>(
    queryFn: (dto) async {
      if (dto is ValidatedUserDTO) {
        final serverToken = await getServerTokenBySMS(dto);
        await saveServerToken(serverToken);
      } else if (dto is ValidatedAuthCodeDTO) {
        final serverToken = await getServerTokenBySMSLogin(dto);
        await saveServerToken(serverToken);
      }
    },
    onSuccess: onSuccess,
    onError: onError,
  );
}
