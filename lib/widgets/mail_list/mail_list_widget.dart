import 'package:cached_query_flutter/cached_query_flutter.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:project_june_client/actions/auth/queries.dart';
import 'package:project_june_client/actions/character/queries.dart';
import 'package:project_june_client/providers/character_provider.dart';
import 'package:project_june_client/providers/common_provider.dart';
import 'package:project_june_client/providers/mail_list_provider.dart';
import 'package:project_june_client/screens/character_profile/profile_details_screen.dart';
import 'package:project_june_client/services/unique_cachekey_service.dart';
import 'package:project_june_client/widgets/mail_list/change_character_overlay_widget.dart';
import 'package:project_june_client/widgets/common/title_underline.dart';
import 'package:project_june_client/widgets/common/title_layout.dart';

import '../../actions/character/models/Character.dart';
import '../../actions/mails/queries.dart';
import '../../constants.dart';
import '../../services.dart';
import '../../widgets/common/alert/alert_widget.dart';

class MailListWidget extends ConsumerStatefulWidget {
  const MailListWidget({super.key});

  @override
  MailListWidgetState createState() => MailListWidgetState();
}

class MailListWidgetState extends ConsumerState<MailListWidget>
    with TickerProviderStateMixin {
  int? selectedPage;
  List<Widget>? mailWidgetList;
  final GlobalKey _targetKey = GlobalKey();
  AnimationController? profileChangeController, reloadMailController;
  Animation<double>? reloadMailFadeAnimation;
  OverlayEntry? overlayEntry;

  @override
  void initState() {
    super.initState();
    profileChangeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100), // 애니메이션 지속 시간
    );
    reloadMailController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300), // 애니메이션 지속 시간
    );
    reloadMailFadeAnimation =
        Tween<double>(begin: 1.0, end: 0.0).animate(reloadMailController!);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(initializeMailListProvider.notifier).state = () {
        setState(() {
          mailWidgetList = null;
          selectedPage = null;
        });
      };
    });
    redirectRetest();
  }

  void initializeMailList() {
    setState(() {
      mailWidgetList = null;
      selectedPage = null;
    });
  }

  void redirectRetest() async {
    final myCharacterList =
        await getRetrieveMyCharacterQuery().result.then((value) => value.data);
    final currentCharacterList =
        myCharacterList!.where((character) => character.is_current == true);
    if (currentCharacterList.isEmpty) return; // current character가 없는 경우
    final currentCharacter = currentCharacterList.first;
    final bool is30DaysFinished = await getRetrieveMeQuery()
        .result
        .then((value) => value.data!.is_30days_finished);
    if (!mounted) return;
    if (currentCharacter.id == ref.read(selectedCharacterProvider) &&
        is30DaysFinished) {
      context.push(
        "/retest",
        extra: <String, dynamic>{
          "firstName": currentCharacter.first_name,
          "characterIds": characterService.getCharacterIds(myCharacterList),
        },
      );
    }
  }

  void changeProfileList(List<Character> characterList) {
    final RenderObject? renderBox =
        _targetKey.currentContext?.findRenderObject();
    if (renderBox is RenderBox) {
      final Offset offset = renderBox.localToGlobal(Offset.zero);
      overlayEntry = OverlayEntry(
        builder: (context) => ChangeCharacterOverlayWidget(
          hideOverlay: hideOverlay,
          offset: offset,
          characterList: characterList,
          profileChangeController: profileChangeController!,
        ),
      );
      Overlay.of(context).insert(overlayEntry!);
      profileChangeController!.forward();
    }
  }

  void hideOverlay() {
    profileChangeController!.reverse().then((_) {
      overlayEntry!.remove();
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
                            ? Color(ref
                                .watch(characterThemeProvider)
                                .colors!
                                .primary!)
                            : ColorConstants.veryLightGray,
                      ),
                    ),
                    onPressed: () async {
                      setState(() {
                        selectedPage = index + 1;
                        ref.read(mailPageProvider.notifier).state = index + 1;
                        mailWidgetList = null;
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

  @override
  Widget build(context) {
    final retrieveMyCharacterQuery = getRetrieveMyCharacterQuery();
    return SafeArea(
      child: QueryBuilder(
          query: retrieveMyCharacterQuery,
          builder: (context, charactersState) {
            if (charactersState.data == null) {
              return const SizedBox();
            }
            final selectedCharacterList = charactersState.data!.where(
                (character) =>
                    character.id == ref.watch(selectedCharacterProvider));
            if (selectedCharacterList.isEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ref.read(selectedCharacterProvider.notifier).state =
                    charactersState.data!.first.id;
              });
              return const SizedBox();
            }
            final selectedCharacter = selectedCharacterList.first;
            final mainImageSrc = characterService
                .getMainImage(selectedCharacter.character_info!.images!);
            if (selectedPage == null) {
              selectedPage = selectedCharacter.date_allocated!.length;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ref.read(mailPageProvider.notifier).state =
                    selectedCharacter.date_allocated!.length;
              });
            }
            return TitleLayout(
              title: Row(
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(width: 10),
                        Text(
                          '${selectedCharacter.first_name}이와의\n${mailService.getDDay(selectedCharacter.date_allocated!.last)}',
                          style: TextStyle(
                            fontFamily: 'NanumJungHagSaeng',
                            color: ColorConstants.primary,
                            fontSize: 21,
                            height: 15 / 18.5,
                            letterSpacing: 2,
                            fontWeight: FontWeightConstants.semiBold,
                          ),
                          textAlign: TextAlign.start,
                        ),
                      ],
                    ),
                  ),
                  const TitleUnderline(titleText: "받은 편지함"),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            selectedCharacter.is_image_updated!
                                ? showModalBottomSheet(
                                    isScrollControlled: true,
                                    context: context,
                                    builder: (context) => ProfileDetailsScreen(
                                      imageList: selectedCharacter
                                          .character_info!.images!,
                                      index: mainImageSrc.order - 1,
                                    ),
                                  )
                                : context.push('/mails/my-character');
                          },
                          onLongPressStart: (_) {
                            HapticFeedback.heavyImpact();
                          },
                          onLongPressEnd: (_) {
                            HapticFeedback.heavyImpact();
                            changeProfileList(charactersState.data!);
                          },
                          child: Container(
                            key: _targetKey,
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(70.0),
                              // 원형 테두리 반경
                              border: Border.all(
                                color: selectedCharacter.is_image_updated!
                                    ? Color(ref
                                        .watch(characterThemeProvider)
                                        .colors!
                                        .primary!)
                                    : ColorConstants.background,
                                // 테두리 색상
                                width: 2.0, // 테두리 두께
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: SizedBox(
                                height: 40,
                                width: 40,
                                child: ExtendedImage.network(
                                  timeLimit:
                                      ref.watch(imageCacheDurationProvider),
                                  cacheKey: UniqueCacheKeyService.makeUniqueKey(
                                      mainImageSrc.src),
                                  mainImageSrc.src,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              body: QueryBuilder(
                query: getListMailQuery(
                    characterId: ref.watch(selectedCharacterProvider)!,
                    page: selectedPage!),
                builder: (context, listMailState) {
                  if (listMailState.data != null) {
                    if (mailWidgetList == null) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        setState(() {
                          mailWidgetList = mailService
                              .makeMailWidgetList(listMailState.data!);
                        });
                      });
                    }
                  }
                  if ((selectedPage == null || mailWidgetList == null)) {
                    return const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircularProgressIndicator.adaptive(),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        if (selectedCharacter.date_allocated!.length > 1)
                          GestureDetector(
                            onTap: () => showSelectMonthAlert(
                                selectedCharacter.date_allocated!.length),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 20.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    mailService.makePageLabel(selectedPage!),
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontFamily: 'NanumJungHagSaeng',
                                      color: ColorConstants.primary,
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.only(left: 5.0, top: 5),
                                    child: Icon(PhosphorIcons.caret_down_bold,
                                        size: 18),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          const SizedBox(height: 20),
                        if (mailWidgetList!.isEmpty == true)
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
                                    fontWeight: FontWeightConstants.semiBold,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  '${mailService.getNextMailReceiveTimeStr()}에 첫 편지가 올 거에요. \n 조금만 기다려 주세요 :)',
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
                          ),
                        if (mailWidgetList!.isEmpty == false) ...[
                          mailService.calendarWeekday(),
                          const SizedBox(height: 20),
                          Expanded(
                            child: RefreshIndicator.adaptive(
                              onRefresh: () async {
                                HapticFeedback.lightImpact();
                                await retrieveMyCharacterQuery.refetch();
                                await getListMailQuery(
                                        characterId: ref
                                            .watch(selectedCharacterProvider)!,
                                        page: selectedPage!)
                                    .refetch();
                                reloadMailController!.forward().then((_) {
                                  setState(() {
                                    mailWidgetList = null;
                                  });
                                  reloadMailController!.reverse();
                                });
                              },
                              child: FadeTransition(
                                opacity: reloadMailFadeAnimation!,
                                child: GridView.count(
                                  crossAxisCount: 7,
                                  childAspectRatio: 7 / 11,
                                  children: mailWidgetList!,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    );
                  }
                },
              ),
            );
          }),
    );
  }
}
