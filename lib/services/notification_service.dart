import 'dart:async';

import 'package:cached_query_flutter/cached_query_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:project_june_client/actions/character/models/CharacterColors.dart';
import 'package:project_june_client/actions/character/models/CharacterTheme.dart';
import 'package:project_june_client/actions/notification/actions.dart';
import 'package:project_june_client/actions/notification/models/AppNotification.dart';
import 'package:project_june_client/actions/notification/queries.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:project_june_client/globals.dart';
import 'package:project_june_client/widgets/common/create_notification_snackbar.dart';
import 'package:url_launcher/url_launcher.dart';

import '../router.dart';

class NotificationService {
  const NotificationService();

  void routeRedirectLink(String? redirectLink) {
    if (redirectLink != null && redirectLink.isNotEmpty) {
      if (redirectLink.length > 4 && redirectLink.substring(0, 4) == 'http') {
        launchUrl(Uri.parse(redirectLink));
      } else {
        router.push(redirectLink);
      }
    }
  }

  void handleClickNotification(String? redirectLink, int notificationId) {
    final mutation = readNotificationMutation(
        onSuccess: (res, arg) => routeRedirectLink(redirectLink));
    mutation.mutate(notificationId);
  }

  void handleNewNotification() {
    CachedQuery.instance.refetchQueries(keys: ["list-app-notifications"]);
  }

  void handleFCMMessageTap(RemoteMessage remoteMessage) async {
    // 앱 열릴때 실행되는 함수
    String? redirectLink = await remoteMessage.data['link'];
    int? notificationId = await int.tryParse(remoteMessage.data['id'] ?? '');
    // id의 유무는 전체에게 보내면 id가 없고, 개인에게 보내면 id가 있음.
    if (notificationId == null || notificationId.isNaN) {
      routeRedirectLink(redirectLink); // id가 없고, link가 있는 경우. 예) 공지사항
      router.go("/notifications"); // 전체에게 보냈는데, link가 없는 경우. 예) 죄송합니다 메세지
      return;
    } else {
      final mutation = readNotificationMutation(onSuccess: (res, arg) {
        router.go("/notifications",
            extra: redirectLink); // 개인한테 보냈는데, link가 있는 경우. 예) 캐릭터가 보낸 메일
        if (redirectLink == null || redirectLink.isEmpty) {
          router.go("/notifications"); // 개인한테 보냈는데, link가 없는 경우. 예) 포인트 쌓임
        }
      });
      mutation.mutate(notificationId);
    }
  }

  void initializeNotificationHandlers(CharacterColors characterColors) {
    FirebaseMessaging.instance
        .getToken()
        .then((token) => token != null ? getOrCreateUserDevice(token) : null);
    FirebaseMessaging.instance.onTokenRefresh
        .listen((token) => getOrCreateUserDevice(token));
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // 포그라운드
      String snackBarText = message.notification?.body ?? message.data['body'];
      scaffoldMessengerKey.currentState?.showSnackBar(
        createNotificationSnackbar(
          snackBarText: snackBarText,
          redirectLink: message.data['link'],
          notificationId: int.tryParse(message.data['id'] ?? ''),
          characterColors: characterColors,
        ),
      );
    });
    FirebaseMessaging.onMessageOpenedApp
        .listen(handleFCMMessageTap); //백그라운드 -> 포그라운드
    addBadgeControlListener();
  }

  Future<StreamSubscription<QueryState<List<AppNotification>>>>
      addBadgeControlListener() async {
    final supported = await FlutterAppBadger.isAppBadgeSupported();
    final query = getListAppNotificationQuery();
    return query.stream.listen((state) {
      if (state.data == null) {
        return;
      }
      if (supported == true) {
        FlutterAppBadger.updateBadgeCount(state.data!
            .where((notification) => notification.is_read == false)
            .length);
      }
    });
  }
}
