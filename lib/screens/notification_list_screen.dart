import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:project_june_client/constants.dart';
import 'package:project_june_client/widgets/common/title_layout.dart';
import 'package:project_june_client/widgets/notification_widget.dart';

class NotificationListScreen extends HookWidget {
  const NotificationListScreen({super.key});

  @override
  Widget build(context) {
    return SafeArea(
      child: TitleLayout(
        showProfile: false,
        titleText: '알림',
        body: Column(
          children: [
            NotificationWidget(time: 11, title: '새로 추가된 공지사항을 적어주세요.'),
            NotificationWidget(time: 10, title: '시현이가 편지를 읽고 갸우뚱했어요.🤔'),
          ],
        ),
      ),
    );
  }
}
