import 'package:cached_query_flutter/cached_query_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:project_june_client/actions/mails/queries.dart';
import 'package:project_june_client/constants.dart';

import '../actions/mails/models/Mail.dart';

class MailWidget extends StatelessWidget {
  final Mail mail;

  const MailWidget({super.key, required this.mail});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: MutationBuilder(
        mutation: getSendMailReadMutation(),
        builder: (context, state, mutate) {
          return TextButton(
            onPressed: () {
              mutate(mail.id);
              context.go('/mail-view/${mail.id}');
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                const SizedBox(
                  height: 57,
                  width: 50,
                ),
                Positioned(
                  top: 0,
                  child: Icon(
                      mail.is_read == true
                          ? (PhosphorIcons.envelope_simple_open_thin)
                          : (PhosphorIcons.envelope_simple),
                      color: mail.is_read == true
                          ? ColorConstants.neutral
                          : ColorConstants.primary,
                      size: 50),
                ),
                Positioned(
                  top: 43,
                  child: Text(
                    mail.available_at.toString().substring(5, 10),
                    style: TextStyle(
                      fontWeight: mail.is_read == true
                          ? FontWeight.normal
                          : FontWeight.bold,
                      color: mail.is_read == true
                          ? ColorConstants.neutral
                          : ColorConstants.primary,
                      fontSize: 10,
                    ),
                  ),
                ),
                mail.is_read == true
                    ? const SizedBox(
                        height: 0,
                        width: 0,
                      )
                    : Positioned(
                        top: 5,
                        left: 39,
                        child: Container(
                          height: 10,
                          width: 10,
                          decoration: BoxDecoration(
                            color: const Color(0xffFE3140),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
              ],
            ),
          );
        },
      ),
    );
  }
}
