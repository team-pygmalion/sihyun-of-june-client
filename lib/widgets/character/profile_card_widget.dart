import 'package:carousel_slider/carousel_slider.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:project_june_client/actions/character/models/Character.dart';
import 'package:project_june_client/actions/character/models/CharacterImage.dart';
import 'package:project_june_client/constants.dart';
import 'package:project_june_client/services/unique_cachekey_service.dart';
import 'package:project_june_client/widgets/character/profile_list_widget.dart';

const indicatorPadding = 15.0;

class ProfileCardWidget extends ConsumerStatefulWidget {
  final Character character;
  final int mainImageIndex;
  final ProfileWidgetType profileWidgetType;

  const ProfileCardWidget({
    super.key,
    required this.character,
    required this.mainImageIndex,
    required this.profileWidgetType,
  });

  @override
  ProfileCardWidgetState createState() => ProfileCardWidgetState();
}

class ProfileCardWidgetState extends ConsumerState<ProfileCardWidget> {
  late int imageIndex = widget.mainImageIndex;
  late String selectedCharacterName = widget.character.name;
  final CarouselController _imageListController = CarouselController();
  String questText = '';
  late double initialDragPosX;
  bool dismiss = false;

  void _preloadImages(List<CharacterImage> imageList) {
    for (final image in imageList) {
      precacheImage(
        ExtendedNetworkImageProvider(
          image.src,
          cache: true,
          cacheMaxAge: CachingDuration.image,
          cacheKey: UniqueCacheKeyService.makeUniqueKey(image.src),
        ),
        context,
      );
    }
  }

  @override
  void didUpdateWidget(covariant ProfileCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.character.name != widget.character.name) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _preloadImages(widget.character.character_info.images);
      });
      _imageListController.jumpToPage(widget.mainImageIndex);
      setState(() {
        imageIndex = widget.mainImageIndex;
        selectedCharacterName = widget.character.name;
        if (widget.character.character_info.images[imageIndex].is_blurred) {
          questText =
              widget.character.character_info.images[imageIndex].quest_text;
        } else {
          questText = '';
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _preloadImages(widget.character.character_info.images);
    });
  }

  Widget _buildIndicator(int index, int totalImageLength) {
    const innerIndicatorMargin = 3.0;
    final indicatorWidth =
        (MediaQuery.of(context).size.width - 2 * indicatorPadding) /
                totalImageLength -
            (2 * innerIndicatorMargin);
    return Container(
      width: indicatorWidth,
      height: 3.0,
      margin: const EdgeInsets.symmetric(horizontal: innerIndicatorMargin),
      decoration: BoxDecoration(
        color: imageIndex >= index
            ? ColorConstants.background
            : ColorConstants.background.withOpacity(0.3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalImageLength = widget.character.character_info.images.length;
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(12),
        topRight: Radius.circular(12),
      ),
      child: GestureDetector(
        onHorizontalDragStart: (details) {
          initialDragPosX = details.globalPosition.dx;
        },
        onHorizontalDragUpdate: (details) {
          double currentDragPosX = details.globalPosition.dx;
          double dragOffset = currentDragPosX - initialDragPosX;
          if (dragOffset > 0) {
            setState(() {
              dismiss = true;
            });
          }
        },
        onHorizontalDragEnd: (details) {
          if (dismiss) {
            final isCanPop = context.canPop();
            if (!isCanPop) return;
            context.pop();
          }
        },
        onTapUp: (details) {
          final double screenWidth = MediaQuery.of(context).size.width;
          final double dx = details.localPosition.dx;
          if (dx < screenWidth / 2) {
            if (imageIndex == 0) return;
            _imageListController.jumpToPage(imageIndex - 1);
            if (widget.character.character_info.images[imageIndex].is_blurred) {
              questText =
                  widget.character.character_info.images[imageIndex].quest_text;
            } else {
              questText = '';
            }
          } else {
            if (imageIndex == totalImageLength - 1) return;
            _imageListController.jumpToPage(imageIndex + 1);
            if (widget.character.character_info.images[imageIndex].is_blurred) {
              questText =
                  widget.character.character_info.images[imageIndex].quest_text;
            } else {
              questText = '';
            }
          }
        },
        child: Stack(
          children: [
            CarouselSlider.builder(
              carouselController: _imageListController,
              itemCount: totalImageLength,
              options: CarouselOptions(
                scrollPhysics: const NeverScrollableScrollPhysics(),
                initialPage: widget.mainImageIndex,
                height: MediaQuery.of(context).size.height,
                viewportFraction: 1.0,
                enableInfiniteScroll: false,
                onPageChanged: (index, reason) {
                  setState(() {
                    imageIndex = index;
                  });
                },
              ),
              itemBuilder: (context, index, realIndex) {
                final imageSrc =
                    widget.character.character_info.images[index].src;
                return ExtendedImage.network(
                  imageSrc,
                  cacheMaxAge: CachingDuration.image,
                  enableLoadState: false,
                  cacheKey: UniqueCacheKeyService.makeUniqueKey(imageSrc),
                  fit: BoxFit.cover,
                );
              },
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(indicatorPadding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(totalImageLength,
                      (index) => _buildIndicator(index, totalImageLength)),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 155,
              child: Padding(
                padding: const EdgeInsets.all(21),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (questText.isNotEmpty)
                      Column(
                        children: [
                          Icon(
                            PhosphorIcons.lock_bold,
                            color: ColorConstants.background,
                            size: 24,
                          ),
                          const SizedBox(height: 7),
                          Text(
                            questText.replaceAll("\\n", "\n"),
                            style: TextStyle(
                              color: ColorConstants.background,
                              fontSize: 14,
                              height: 19 / 14,
                              fontWeight: FontWeightConstants.semiBold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                              height: MediaQuery.of(context).size.height * 0.1),
                        ],
                      ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: widget.character.name,
                                style: const TextStyle(
                                  fontSize: 60,
                                ),
                              ),
                              TextSpan(
                                text:
                                    '(${widget.character.character_info.age})',
                                style: const TextStyle(
                                  fontSize: 48,
                                ),
                              ),
                            ],
                            style: TextStyle(
                                fontFamily: 'NanumJungHagSaeng',
                                fontSize: 60,
                                fontWeight: FontWeightConstants.semiBold,
                                color: ColorConstants.background,
                                height: 1),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.7,
                          child: Text(
                            widget.character.character_info.summary_description,
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.45,
                              fontWeight: FontWeightConstants.semiBold,
                              color: ColorConstants.background,
                            ),
                          ),
                        ),
                        Text(
                          widget.character.character_info.one_line_description,
                          style: TextStyle(
                            fontFamily: 'NanumJungHagSaeng',
                            fontSize: 32,
                            fontWeight: FontWeight.normal,
                            color: ColorConstants.background,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
