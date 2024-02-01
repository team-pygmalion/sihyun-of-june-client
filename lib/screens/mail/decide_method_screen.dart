import 'package:cached_query_flutter/cached_query_flutter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:project_june_client/actions/auth/queries.dart';
import 'package:project_june_client/actions/character/dtos.dart';
import 'package:project_june_client/actions/character/queries.dart';
import 'package:project_june_client/constants.dart';
import 'package:project_june_client/globals.dart';
import 'package:project_june_client/providers/character_provider.dart';
import 'package:project_june_client/services.dart';
import 'package:project_june_client/widgets/common/back_appbar.dart';
import 'package:project_june_client/widgets/common/create_snackbar.dart';
import 'package:project_june_client/widgets/common/modal/modal_choice_widget.dart';
import 'package:project_june_client/widgets/common/modal/modal_description_widget.dart';
import 'package:project_june_client/widgets/common/modal/modal_widget.dart';
import 'package:project_june_client/widgets/common/title_layout.dart';

class DecideAssignmentMethodScreen extends ConsumerStatefulWidget {
  const DecideAssignmentMethodScreen({super.key});

  @override
  DecideAssignmentMethodScreenState createState() {
    return DecideAssignmentMethodScreenState();
  }
}

class DecideAssignmentMethodScreenState
    extends ConsumerState<DecideAssignmentMethodScreen> {
  bool isEnableToClick = true;

  void showNoMoreCharacterModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => ModalWidget(
        title: '모든 상대를 만나보셨군요!',
        description: const ModalDescriptionWidget(
          description: '현재 상대하고만 편지를 주고받을 수 있어요.',
        ),
        choiceColumn: FilledButton(
          onPressed: () => context.pop(),
          child: const Text('알겠어요'),
        ),
      ),
    );
  }

  void showNeedMoreGoodsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => ModalWidget(
        title: '앗, 재화가 부족해요.',
        choiceColumn: ModalChoiceWidget(
          isDefaultButton: true,
          cancelText: '코인 구매하러 가기',
          submitText: '친구 초대하고 300P 받기',
          onCancel: () {
            context.pop();
            context.push(RoutePaths.allMyCoinCharge);
          },
          onSubmit: () {
            context.pop();
            context.push(RoutePaths.allShare);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ReallocateDTO makeReallocateDto(String payment) {
      if (payment == 'coin') {
        return ReallocateDTO(
          method: 'character_selection',
          payment: payment,
        );
      } else {
        return ReallocateDTO(
          method: 'character_test',
          payment: payment,
        );
      }
    }

    return Scaffold(
      appBar: const BackAppbar(),
      body: SafeArea(
        child: TitleLayout(
          title: Text(
            '혹시\n원하는 상대가 있으신가요?',
            style: Theme.of(context).textTheme.titleLarge,
            softWrap: true,
            textAlign: TextAlign.center,
          ),
          body: const SizedBox(),
          actions: MutationBuilder(
            mutation: getReallocateMutation(
              onSuccess: (res, arg) async {
                scaffoldMessengerKey.currentState?.showSnackBar(
                  createSnackBar(
                    snackBarText:
                        transactionService.getPurchaseStateText(arg.payment),
                    characterColors: ColorTheme.defaultTheme.colors,
                  ),
                );
                context.go(RoutePaths.assignment);
              },
              onError: (arg, error, fallback) {
                setState(() {
                  isEnableToClick = true;
                });
                if (error is DioException) {
                  if (error.response?.data.toString().trim() ==
                      '모든 캐릭터를 배정받았습니다.'.trim()) {
                    showNoMoreCharacterModal(context);
                  } else {
                    showNeedMoreGoodsModal(context);
                  }
                }
              },
            ),
            builder: (context, state, mutate) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FilledButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(isEnableToClick
                          ? ColorConstants.pink
                          : Color(ColorTheme.defaultTheme.colors.secondary)),
                    ),
                    onPressed: () async {
                      if (isEnableToClick) {
                        setState(() {
                          isEnableToClick = false;
                        });
                        final bool is30DaysFinished = await getRetrieveMeQuery()
                            .result
                            .then((value) => value.data!.is_30days_finished);
                        if (is30DaysFinished == false) {
                          await characterService.deleteSelectedCharacterId();
                          ref.read(selectedCharacterProvider.notifier).state =
                              await null;
                        }
                        await mutate(makeReallocateDto('point')); // 결제
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '누구든 괜찮아요',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeightConstants.semiBold,
                            height: 1.0,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 6.0),
                          child: Text(
                            '100P',
                            style: TextStyle(
                              fontSize: 14,
                              color: ColorConstants.lightGray.withOpacity(0.5),
                              fontWeight: FontWeight.bold,
                              height: 1.0,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 13,
                  ),
                  FilledButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(isEnableToClick
                          ? ColorConstants.pink
                          : Color(ColorTheme.defaultTheme.colors.secondary)),
                    ),
                    onPressed: () async {
                      if (isEnableToClick) {
                        setState(() {
                          isEnableToClick = false;
                        });
                        final bool is30DaysFinished = await getRetrieveMeQuery()
                            .result
                            .then((value) => value.data!.is_30days_finished);
                        if (is30DaysFinished == false) {
                          await characterService.deleteSelectedCharacterId();
                          ref.read(selectedCharacterProvider.notifier).state =
                              await null;
                        }
                        await mutate(makeReallocateDto('coin')); // 결제
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '원하는 상대로 해주세요',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeightConstants.semiBold,
                            height: 1.0,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 6.0),
                          child: Text(
                            '50코인',
                            style: TextStyle(
                              fontSize: 14,
                              color: ColorConstants.lightGray.withOpacity(0.5),
                              fontWeight: FontWeight.bold,
                              height: 1.0,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
