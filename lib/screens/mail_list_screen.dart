import 'package:cached_query_flutter/cached_query_flutter.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:project_june_client/actions/character/queries.dart';
import 'package:project_june_client/widgets/mail_widget.dart';
import 'package:project_june_client/widgets/common/title_layout.dart';
import 'package:project_june_client/widgets/notification_permission_check.dart';

import '../actions/mails/queries.dart';
import '../actions/notification/queries.dart';
import '../constants.dart';

class MailListScreen extends StatefulWidget {
  const MailListScreen({super.key});

  @override
  State<MailListScreen> createState() => _MailListScreenState();
}

class _MailListScreenState extends State<MailListScreen> {
  @override
  Widget build(context) {
    final isNotificationAcceptedQuery =
        getIsNotificationAcceptedQuery(onError: (err) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('알림 권한을 받아오지 못했습니다. 에러가 계속되면 고객센터에 문의해주세요.'),
      ));
    });
    final listMailQuery = getListMailQuery(onError: (err) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('메일을 불러오지 못했습니다. 에러가 계속되면 고객센터에 문의해주세요.'),
      ));
    });
    final retrieveMyCharacterQuery =
        getRetrieveMyCharacterQuery(onError: (err) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('내 캐릭터를 불러오지 못했습니다. 에러가 계속되면 고객센터에 문의해주세요.'),
      ));
    });
    return SafeArea(
      child: TitleLayout(
        showProfile: Padding(
          padding: const EdgeInsets.only(right: 28.0),
          child: QueryBuilder(
            query: retrieveMyCharacterQuery,
            builder: (context, state) {
              if (state.data != null) {
                return TextButton(
                  onPressed: () => context.push('/mails/my-character'),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      state.data![0].image,
                      height: 35,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
        titleText: '받은 편지함',
        body: Stack(
          children: [
            QueryBuilder(
              query: isNotificationAcceptedQuery,
              builder: (context, state) {
                return state.data == false
                    ? RequestNotificationPermissionWidget()
                    : const SizedBox.shrink();
              },
            ),
            Positioned.fill(
              child: QueryBuilder(
                query: listMailQuery,
                builder: (context, state) {
                  if (state.data?.isEmpty == true) {
                    return Column(
                      children: [
                        const SizedBox(height: 50),
                        const Text(
                          '🍂',
                          style: TextStyle(fontSize: 100),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          '아직 도착한 편지가 없어요. \n 내일 9시에 첫 편지가 올 거에요.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: ColorConstants.neutral,
                              fontSize: 15,
                              height: 1.5),
                        )
                      ],
                    );
                  }
                  return GridView.count(
                    crossAxisCount: 3,
                    padding: const EdgeInsets.all(20.0),
                    children: state.data
                            ?.map<Widget>((mail) => MailWidget(mail: mail))
                            .toList() ??
                        [],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
