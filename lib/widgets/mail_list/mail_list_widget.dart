import 'package:cached_query_flutter/cached_query_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:project_june_client/widgets/common/change_character_widget.dart';
import 'package:project_june_client/providers/character_provider.dart';
import 'package:project_june_client/widgets/common/top_navbar.dart';
import 'package:project_june_client/widgets/common/title_layout.dart';

import '../../actions/character/models/Character.dart';
import '../../actions/mails/queries.dart';
import '../../constants.dart';
import '../../services.dart';
import '../../widgets/common/alert/alert_widget.dart';

class MailListWidget extends ConsumerStatefulWidget {
  final Character selectedCharacter;

  const MailListWidget(this.selectedCharacter, {super.key});

  @override
  MailListWidgetState createState() => MailListWidgetState();
}

class MailListWidgetState extends ConsumerState<MailListWidget>
    with TickerProviderStateMixin {
  int? selectedPage;
  AnimationController? reloadMailController;
  Animation<double>? reloadMailFadeAnimation;
  final GlobalKey _changeCharacterKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    reloadMailController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300), // 애니메이션 지속 시간
    );
    reloadMailFadeAnimation =
        Tween<double>(begin: 1.0, end: 0.0).animate(reloadMailController!);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final activeCharacter = ref.read(activeCharacterProvider);
        final isSelectedCharacter =
            activeCharacter?.id == widget.selectedCharacter.id;
        characterService.redirectRetest(
          activeCharacter?.first_name,
          isSelectedCharacter,
          context,
        );
      }
    });
  }

  Future showSelectMonthAlert(int mailReceivedMonth) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertWidget(
            content: SizedBox(
              width: 300,
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 2.7,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: mailReceivedMonth,
                itemBuilder: (context, index) {
                  return FilledButton(
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                      ),
                      padding: MaterialStateProperty.all<EdgeInsets>(
                          const EdgeInsets.only(bottom: 3)),
                      backgroundColor: MaterialStateProperty.all<Color>(
                        selectedPage == index + 1
                            ? Color(
                                widget.selectedCharacter.theme.colors.primary)
                            : ColorConstants.lightGray,
                      ),
                    ),
                    onPressed: () async {
                      setState(() {
                        selectedPage = index + 1;
                      });
                      context.pop();
                    },
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        mailService.makePageLabel(index + 1),
                        style: TextStyle(
                            fontSize: 24,
                            fontFamily: 'NanumJungHagSaeng',
                            color: selectedPage == index + 1
                                ? ColorConstants.background
                                : ColorConstants.neutral),
                      ),
                    ),
                  );
                },
              ),
            ),
            confirmText: '확인');
      },
    );
  }

  void initializeSelectedPage(int initializedPage) {
    selectedPage = initializedPage;
  }

  @override
  Widget build(context) {
    if (selectedPage == null) {
      initializeSelectedPage(
          widget.selectedCharacter.assigned_characters!.length);
    }
    return SafeArea(
      child: TitleLayout(
        title: TopNavbarWidget(
          selectedCharacter: widget.selectedCharacter,
          titleText: '받은 편지함',
        ),
        body: QueryBuilder(
            query: checkMonthlyMailTicketQuery(
                assignId: widget
                    .selectedCharacter
                    .assigned_characters![selectedPage! - 1]
                    .assigned_character_id),
            builder: (context, monthlyTicketState) {
              if (monthlyTicketState.status != QueryStatus.success) {
                return const SizedBox.shrink();
              }
              return QueryBuilder(
                  query: fetchMailTicketInfoQuery(),
                  builder: (context, mailTicketInfoState) {
                    if (mailTicketInfoState.status != QueryStatus.success) {
                      return const SizedBox.shrink();
                    }
                    return QueryBuilder(
                      query: fetchMailListQuery(
                          assignId: widget
                              .selectedCharacter
                              .assigned_characters![selectedPage! - 1]
                              .assigned_character_id),
                      builder: (context, listMailState) {
                        if (listMailState.status != QueryStatus.success) {
                          return const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircularProgressIndicator.adaptive(),
                            ],
                          );
                        }
                        final mailWidgetList = mailService.makeMailWidgetList(
                          mailTicketInfo: mailTicketInfoState.data!,
                          mails: listMailState.data!,
                          assignId: widget
                              .selectedCharacter
                              .assigned_characters![selectedPage! - 1]
                              .assigned_character_id,
                          characterColors:
                              widget.selectedCharacter.theme.colors,
                          hasMonthlyMailTicket: monthlyTicketState.data!,
                        );
                        return Column(
                          children: [
                            if (widget.selectedCharacter.assigned_characters!
                                    .length >
                                1)
                              GestureDetector(
                                onTap: () => showSelectMonthAlert(widget
                                    .selectedCharacter
                                    .assigned_characters!
                                    .length),
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 20.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        mailService
                                            .makePageLabel(selectedPage!),
                                        style: TextStyle(
                                          fontSize: 32,
                                          fontFamily: 'NanumJungHagSaeng',
                                          color: ColorConstants.primary,
                                        ),
                                      ),
                                      const Padding(
                                        padding:
                                            EdgeInsets.only(left: 5.0, top: 5),
                                        child: Icon(
                                            PhosphorIcons.caret_down_bold,
                                            size: 18),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              const SizedBox(height: 20),
                            if (mailWidgetList.isEmpty == true)
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '아직 도착한 편지가 없어요!',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: ColorConstants.primary,
                                        fontSize: 21,
                                        height: 1,
                                        fontWeight:
                                            FontWeightConstants.semiBold,
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    Text(
                                      '${mailService.getFirstMailReceiveTimeStr()}에 첫 편지가 올 거에요. \n 조금만 기다려 주세요 :)',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: ColorConstants.neutral,
                                        fontSize: 16,
                                        height: 22 / 16,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    )
                                  ],
                                ),
                              )
                            else ...[
                              mailService.calendarWeekday(),
                              const SizedBox(height: 20),
                              Expanded(
                                child: RefreshIndicator.adaptive(
                                  onRefresh: () async {
                                    HapticFeedback.lightImpact();
                                    await checkMonthlyMailTicketQuery(
                                            assignId: widget
                                                .selectedCharacter
                                                .assigned_characters![
                                                    selectedPage! - 1]
                                                .assigned_character_id)
                                        .refetch();
                                    if (!mounted) return;
                                    await fetchMailListQuery(
                                            assignId: widget
                                                .selectedCharacter
                                                .assigned_characters![
                                                    selectedPage! - 1]
                                                .assigned_character_id)
                                        .refetch();
                                    await characterService
                                        .refreshProviderOfCharacter(ref);
                                    reloadMailController!.forward().then(
                                        (_) => reloadMailController!.reverse());
                                  },
                                  child: FadeTransition(
                                    opacity: reloadMailFadeAnimation!,
                                    child: GridView.count(
                                      crossAxisCount: 7,
                                      childAspectRatio: 7 / 11,
                                      children: mailWidgetList,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            Padding(
                              padding: const EdgeInsets.only(bottom:20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ChangeCharacterWidget(
                                    key: _changeCharacterKey,
                                    targetKey: _changeCharacterKey,
                                    parentContext: context,
                                  ),
                                  const SizedBox(width: 26),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  });
            }),
      ),
    );
  }
}
