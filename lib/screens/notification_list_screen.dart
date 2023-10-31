import 'package:cached_query_flutter/cached_query_flutter.dart';
import 'package:flutter/material.dart';
import 'package:project_june_client/widgets/common/title_layout.dart';
import 'package:project_june_client/widgets/notification_widget.dart';

import '../actions/notification/queries.dart';
import '../constants.dart';

class NotificationListScreen extends StatelessWidget {
  const NotificationListScreen({super.key});

  @override
  Widget build(context) {
    final query = getListAppNotificationQuery();
    return QueryBuilder(
        query: query,
        builder: (context, state) {
          if (state.data == null) {
            return const SizedBox.shrink();
          }
          return SafeArea(
            child: TitleLayout(
              titleText: '알림',
              body: state.data!.isEmpty
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Text(
                            "아직 도착한 알림이 없습니다.",
                            style: TextStyle(
                              fontSize: 14,
                              color: ColorConstants.lightPink,
                            ),
                          ),
                        ),
                      ],
                    )
                  : ListView(
                      children: state.data!
                          .map<Widget>(
                            (notification) => NotificationWidget(
                              notification: notification,
                            ),
                          )
                          .toList(),
                    ),
            ),
          );
        });
  }
}
