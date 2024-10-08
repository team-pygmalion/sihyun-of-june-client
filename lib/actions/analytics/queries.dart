import 'package:cached_query_flutter/cached_query_flutter.dart';
import 'package:project_june_client/actions/analytics/dtos.dart';

import 'actions.dart';

Mutation<void, UserFunnelDTO> sendUserFunnelMutation({
  OnSuccessCallback? onSuccess,
  OnErrorCallback? onError,
}) {
  return Mutation<void, UserFunnelDTO>(
    queryFn: (dto) async {
      await sendUserFunnel(dto.funnel);
      if (dto.refCode != null && dto.refCode!.isNotEmpty) {
        await sendUserRefCode(dto.refCode!);
      }
    },
    onSuccess: onSuccess,
    onError: onError,
  );
}

Mutation<String, String> convertShorterUrlMutation({
  OnSuccessCallback? onSuccess,
  OnErrorCallback? onError,
}) {
  return Mutation<String, String>(
    queryFn: (url) async {
      return await convertShorterUrl(url);
    },
    onSuccess: onSuccess,
    onError: onError,
  );
}
