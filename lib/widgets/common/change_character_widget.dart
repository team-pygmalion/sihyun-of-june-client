import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:project_june_client/actions/auth/queries.dart';
import 'package:project_june_client/actions/character/models/Character.dart';
import 'package:project_june_client/actions/character/queries.dart';
import 'package:project_june_client/constants.dart';
import 'package:project_june_client/providers/character_provider.dart';
import 'package:project_june_client/services.dart';
import 'package:project_june_client/widgets/retest/retest_modal_widget.dart';

const double catSize = 60;

class ChangeCharacterWidget extends StatefulWidget {
  final GlobalKey targetKey;

  const ChangeCharacterWidget({
    super.key,
    required this.targetKey,
  });

  @override
  State<ChangeCharacterWidget> createState() => _ChangeCharacterWidgetState();
}

class _ChangeCharacterWidgetState extends State<ChangeCharacterWidget>
    with SingleTickerProviderStateMixin {
  AnimationController? _changeCharacterController;
  OverlayEntry? _overlayEntry;
  Future<void> Function()? _hideOverlay;

  @override
  void initState() {
    super.initState();
    _changeCharacterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100), // 애니메이션 지속 시간
    );
    _hideOverlay = () async {
      await _changeCharacterController?.reverse();
      _overlayEntry?.remove();
    };
  }

  @override
  void dispose() {
    _changeCharacterController?.dispose();
    super.dispose();
  }

  void _changeProfileList(List<Character> characterList) {
    final RenderObject? renderBox =
        widget.targetKey.currentContext?.findRenderObject();
    if (renderBox is RenderBox) {
      final Offset offset = renderBox.localToGlobal(Offset.zero);
      _overlayEntry = OverlayEntry(
        builder: (context) => _OverLayWidget(
          hideOverlay: _hideOverlay!,
          offset: offset,
          characterList: characterList,
          changeCharacterController: _changeCharacterController!,
        ),
      );
      Overlay.of(context).insert(_overlayEntry!);
      _changeCharacterController?.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final characterList =
            await fetchMyCharactersQuery().result.then((value) => value.data!);
        _changeProfileList(characterList);
      },
      child: Column(
        children: [
          const Text('상대 바꾸기'),
          ExtendedImage.asset(
            'assets/images/character_change_cat.png',
            width: catSize,
            height: catSize,
          ),
        ],
      ),
    );
  }
}

class _OverLayWidget extends ConsumerStatefulWidget {
  final Future<void> Function() hideOverlay;
  final Offset offset;
  final List<Character> characterList;
  final AnimationController changeCharacterController;

  const _OverLayWidget({
    super.key,
    required this.hideOverlay,
    required this.offset,
    required this.characterList,
    required this.changeCharacterController,
  });

  @override
  _OverLayWidgetState createState() => _OverLayWidgetState();
}

class _OverLayWidgetState extends ConsumerState<_OverLayWidget> {
  Animation<double>? changeCharacterFadeAnimation;

  @override
  void initState() {
    super.initState();
    changeCharacterFadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(widget.changeCharacterController);
  }

  @override
  Widget build(BuildContext context) {
    final safeAreaHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top +
        MediaQuery.of(context).padding.bottom;
    final heightFromTopToCatBottom =
        widget.offset.dy + catSize + 10; // 왠진 모르겠는데 10 추가하니 딱맞음
    final widthFromLeftToCatRight = widget.offset.dx + catSize;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        widget.hideOverlay();
      },
      child: FadeTransition(
        opacity: changeCharacterFadeAnimation!,
        child: Material(
          color: Colors.black54,
          child: Stack(
            children: [
              Positioned(
                bottom: safeAreaHeight - heightFromTopToCatBottom,
                right:
                    MediaQuery.of(context).size.width - widthFromLeftToCatRight,
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Column(
                          children: [
                            Text(
                              '새로운 관계는\n언제나 짜릿한\n법이지!',
                              style: TextStyle(
                                color: ColorConstants.black,
                                fontSize: 34,
                                height: 1,
                                letterSpacing: 0.2,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'NanumJungHagSaeng',
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 52),
                          ],
                        ),
                        Positioned(
                          bottom: -20,
                          child: ExtendedImage.asset(
                            'assets/images/character_change_cat_overlay.png',
                            width: 80,
                            height: 80,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 180,
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          _OverlayComponentWidget(
                            hideOverlay: widget.hideOverlay,
                            isSelected: false,
                          ),
                          ...widget.characterList
                              .where((character) =>
                                  character.id !=
                                  ref.watch(selectedCharacterProvider)!.id)
                              .map(
                                (character) => _OverlayComponentWidget(
                                  character: character,
                                  hideOverlay: widget.hideOverlay,
                                  isSelected: false,
                                ),
                              )
                              .toList(),
                          if (ref.watch(selectedCharacterProvider) != null)
                            _OverlayComponentWidget(
                              character: ref.watch(selectedCharacterProvider)!,
                              hideOverlay: widget.hideOverlay,
                              isSelected: true,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _OverlayComponentWidget extends ConsumerWidget {
  final Character? character;
  final Future<void> Function()? hideOverlay;
  final bool isSelected;

  const _OverlayComponentWidget({
    this.character,
    this.hideOverlay,
    required this.isSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeCharacterFirstName =
        ref.watch(activeCharacterProvider)?.first_name;
    return GestureDetector(
      behavior: HitTestBehavior.deferToChild,
      onTap: () async {
        if (isSelected) return;

        if (character == null) {
          if (activeCharacterFirstName == null) {
            context.go(RoutePaths.assignment);
            hideOverlay!();
            return;
          }
          final bool is30DaysFinished = await fetchMeQuery()
              .result
              .then((value) => value.data!.is_30days_finished);
          if (is30DaysFinished == false) {
            final canRetest = await characterService.checkCanRetest();
            showModalBottomSheet(
              context: context,
              builder: (context) => RetestModalWidget(
                firstName: activeCharacterFirstName,
                canRetest: canRetest,
              ),
            );
            hideOverlay!();
            return;
          }
          context.push(
            RoutePaths.retest,
            extra: {'firstName': activeCharacterFirstName},
          );
          hideOverlay!();
          return;
        } else {
          await hideOverlay!();
          ref.read(selectedCharacterProvider.notifier).state = character;
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? ColorConstants.background
              : ColorConstants.veryLightGray,
          border: const Border(
            top: BorderSide(
              width: 1,
              color: Color(0xffBFBFBF),
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: EdgeInsets.only(right: character == null ? 0 : 5),
              child: Text(
                character == null
                    ? '새 친구 만나기'
                    : 'D+${mailService.getMailDateDiff(DateTime.now(), character!.assigned_characters!.first.first_mail_available_at) + 1} ${character?.name}',
                style: TextStyle(
                  color: isSelected
                      ? Color(ref
                          .watch(selectedCharacterProvider)!
                          .theme
                          .colors
                          .primary)
                      : ColorConstants.primary,
                  fontSize: 14.5,
                  height: 1,
                  letterSpacing: 0.2,
                  fontWeight: FontWeightConstants.semiBold,
                  fontFamily: 'Pretendard',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: SizedBox(
                  child: character == null
                      ? Icon(
                          PhosphorIcons.plus_circle_thin,
                          size: 45,
                          color: ColorConstants.neutral,
                        )
                      : ExtendedImage.network(
                          cacheMaxAge: CachingDuration.image,
                          cacheKey: commonService.makeUniqueKey(characterService
                              .getMainImage(character!.character_info.images)
                              .src),
                          characterService
                              .getMainImage(character!.character_info.images)
                              .src,
                          fit: BoxFit.cover,
                          width: 40,
                          height: 40,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
