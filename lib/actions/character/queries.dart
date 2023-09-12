import 'package:cached_query_flutter/cached_query_flutter.dart';
import 'package:project_june_client/actions/character/actions.dart';
import 'package:project_june_client/actions/client.dart';

import 'models/Character.dart';
import 'models/Question.dart';

Query<List<Character>> getlistCharactersQuery() {
  return Query(
    key: ["characters"],
    queryFn: () => dio.get('/character/characters/').then(
      (response) {
        return response.data
            .map<Character>((json) => Character.fromJson(json))
            .toList();
      },
    ),
  );
}

Query<List<Question>> getQuestionsQuery({
  OnQueryErrorCallback? onError,
}) {
  return Query(
    key: ["questions"],
    queryFn: () => dio.post('/character/test/start/').then(
      (response) {
        return response.data
            .map<Question>((json) => Question.fromJson(json))
            .toList();
      },
    ),
    onError: onError,
  );
}

Mutation<void, List<Map<String, dynamic>>> sendResponseMutation({
  OnSuccessCallback? onSuccess,
  OnErrorCallback? onError,
}) {
  return Mutation<void, List<Map<String, dynamic>>>(
    queryFn: sendResponses,
    onSuccess: onSuccess,
    onError: onError,
  );
}

Query<String> getTestStatusQuery({
  OnQueryErrorCallback? onError,
}) {
  return Query(
    key: ["test-status"],
    queryFn: () => dio.get('/character/me/test-status/').then(
      (response) {
        if (response.data is List && response.data.isNotEmpty) {
          return response.data[0]['status'];
        } else {
          throw Exception('Response format is not as expected');
        }
      },
    ),
    onError: onError,
  );
}

Query<Character> getPendingTestQuery({
  OnQueryErrorCallback? onError,
}) {
  return Query(
    key: ["pending-test"],
    queryFn: () => dio.get('/character/test/pending/').then(
      (response) {
        if (response.data != null && response.data.isNotEmpty) {
          return Character.fromJson(response.data);
        } else {
          throw Exception('Response format is not as expected');
        }
      },
    ),
    onError: onError,
  );
}
