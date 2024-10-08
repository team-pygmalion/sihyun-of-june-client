import 'dart:io';
import 'dart:typed_data';

import 'package:cached_query_flutter/cached_query_flutter.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_june_client/globals.dart';
import 'package:project_june_client/providers/common_provider.dart';
import 'package:project_june_client/widgets/common/modal/modal_choice_widget.dart';
import 'package:project_june_client/widgets/common/modal/modal_widget.dart';

import '../actions/auth/queries.dart';
import '../constants.dart';
import 'package:image/image.dart' as image;

class UserProfileService {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;

  Future<void> _pickImage() async {
    _image = await _picker.pickImage(source: ImageSource.gallery);
  }

  Future<Uint8List> cropImage(Uint8List imageData, Rect cropRect) async {
    // Uint8List 데이터를 Image 객체로 변환합니다.
    image.Image originalImage = image.decodeImage(imageData)!;

    // Image 객체를 잘라냅니다.
    image.Image croppedImage = image.copyCrop(
      originalImage,
      x: cropRect.left.toInt(),
      y: cropRect.top.toInt(),
      width: cropRect.width.toInt(),
      height: cropRect.height.toInt(),
    );

    // 잘라낸 이미지를 Uint8List로 다시 변환합니다.
    return Uint8List.fromList(image.encodeJpg(croppedImage));
  }

  void showEditImageModal(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet(
      enableDrag: false,
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        var editorKey = GlobalKey<ExtendedImageEditorState>();
        return Container(
          margin: EdgeInsets.only(top: ref.watch(topPaddingProvider)!),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      context.pop();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('취소',
                          style: TextStyle(
                              fontSize: 20, color: ColorConstants.gray)),
                    ),
                  ),
                  MutationBuilder(
                    mutation: uploadUserImageMutation(),
                    builder: (context, state, mutate) => TextButton(
                      onPressed: () async {
                        context.pop();
                        scaffoldMessengerKey.currentState?.showSnackBar(
                          const SnackBar(
                            content: Text('프로필 변경중입니다...'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                        final cropRect = editorKey.currentState?.getCropRect();
                        if (cropRect != null) {
                          Future.delayed(
                              const Duration(milliseconds: 250),
                              () => _image!.readAsBytes().then((img) =>
                                  cropImage(img, cropRect).then((croppedImg) =>
                                      uploadUserImageMutation()
                                          .mutate(croppedImg)
                                          .then((_) => scaffoldMessengerKey
                                                  .currentState
                                                  ?.showSnackBar(
                                                const SnackBar(
                                                  content:
                                                      Text('프로필 변경이 완료되었어요!'),
                                                  duration:
                                                      Duration(seconds: 1),
                                                ),
                                              )))));
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('확인',
                            style: TextStyle(
                                fontSize: 20, color: ColorConstants.gray)),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height *
                    0.7, // 70% of screen height
                child: ClipRect(
                  child: ExtendedImage.file(File(_image!.path),
                      fit: BoxFit.contain,
                      mode: ExtendedImageMode.editor,
                      extendedImageEditorKey: editorKey,
                      initEditorConfigHandler: (state) {
                    return (EditorConfig(
                      cornerColor: ColorConstants.neutral,
                      cropAspectRatio: 1.0,
                      initCropRectType:
                          InitCropRectType.layoutRect, // image rect
                    ));
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void showChangeImageModal(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      builder: (BuildContext context) {
        return MutationBuilder(
          mutation: deleteUserImageMutation(),
          builder: (context, state, mutate) => ModalWidget(
            title: '프로필 이미지 선택',
            choiceColumn: ModalChoiceWidget(
              submitText: '앨범에서 사진 선택하기',
              onSubmit: () async {
                await _pickImage();
                if (_image != null) {
                  context.pop();
                  showEditImageModal(context, ref);
                }
              },
              cancelText: '기본 이미지 설정',
              onCancel: () async {
                if (state.status == QueryStatus.loading) return;
                mutate(null).then((_) => context.pop());
              },
            ),
          ),
        );
      },
    );
  }
}
