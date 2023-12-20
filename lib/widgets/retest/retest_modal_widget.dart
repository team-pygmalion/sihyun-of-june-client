import 'package:cached_query_flutter/cached_query_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:project_june_client/widgets/common/modal/modal_description_widget.dart';
import 'package:project_june_client/widgets/common/modal/modal_widget.dart';
import 'package:project_june_client/widgets/retest/retest_choice_widget.dart';

import '../../actions/auth/queries.dart';
import '../../actions/character/queries.dart';
import '../../globals.dart';
import '../../providers/character_provider.dart';
import '../../providers/user_provider.dart';
import '../../services.dart';
import '../common/create_snackbar.dart';

class RetestModalWidget extends ConsumerWidget {
  final String? firstName;

  const RetestModalWidget({super.key, required this.firstName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool isEnableToRetest = ref.read(isEnableToRetestProvider);
    return ModalWidget(
      title: isEnableToRetest
          ? '아직 $firstName이와의 시간이 남았어요.\n그래도 새 친구를 만나시겠어요?'
          : '모든 상대를 만나보셨군요!',
      description: ModalDescriptionWidget(
        description: isEnableToRetest
            ? '$firstName이와의 기억이 지워지고,\n더 이상 편지를 받아볼 수 없어요.'
            : '현재 상대하고만 편지를 주고받을 수 있어요.',
      ),
      choiceColumn: isEnableToRetest
          ? MutationBuilder(
              mutation: getRetestMutation(
                refetchQueries: [
                  getRetrieveMyCharacterQuery(),
                  getRetrieveMeQuery(),
                ],
                onSuccess: (res, arg) {
                  scaffoldMessengerKey.currentState?.showSnackBar(
                    createSnackBar(
                      snackBarText: transactionService.getPurchaseStateText(arg),
                      characterColors:
                          ref.watch(characterThemeProvider).colors!,
                    ),
                  );
                  context.go('/character-test');
                },
              ),
              builder: (context, state, mutate) {
                void handleRetest(String payment) {
                  mutate(payment);
                }

                return RetestChoiceWidget(
                  inModal: true,
                  onRetest: handleRetest,
                );
              },
            )
          : FilledButton(
              onPressed: () {
                context.pop();
              },
              child: const Text(
                '알겠어요',
              ),
            ),
    );
  }
}
