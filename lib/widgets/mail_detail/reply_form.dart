import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:project_june_client/actions/mails/models/mail_in_detail.dart';
import 'package:project_june_client/actions/mails/actions.dart';
import 'package:project_june_client/router.dart';
import 'package:project_june_client/services.dart';
import 'package:project_june_client/widgets/mail_detail/mail_info.dart';
import 'package:project_june_client/widgets/common/modal/modal_choice_widget.dart';
import 'package:project_june_client/widgets/common/modal/modal_description_widget.dart';
import 'package:project_june_client/widgets/common/modal/modal_widget.dart';
import 'package:project_june_client/widgets/mail_detail/replied.dart';

import '../../constants.dart';

class ReplyFormWidget extends ConsumerStatefulWidget {
  final MailInDetail mail;
  final int primaryColorInMail;
  final String characterName;
  final int characterId;
  final FocusNode focusNode;
  final GlobalKey<FormState> formKey;

  const ReplyFormWidget({
    Key? key,
    required this.characterId,
    required this.mail,
    required this.primaryColorInMail,
    required this.characterName,
    required this.focusNode,
    required this.formKey,
  }) : super(key: key);

  @override
  ReplyFormWidgetState createState() => ReplyFormWidgetState();
}

class ReplyFormWidgetState extends ConsumerState<ReplyFormWidget> {
  final controller = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    mailService.getBeforeReply(controller: controller, mailId: widget.mail.id);
  }

  @override
  void dispose() {
    mailService.saveBeforeReply(
      reply: controller.value.text,
      mailId: widget.mail.id,
    );
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    showConfirmModal() {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return PopScope(
            canPop: !isLoading,
            child: ModalWidget(
              title: '정말 이대로 보내시겠어요?',
              description: const ModalDescriptionWidget(
                  description: '답장을 보내면 수정이 불가능해요.🥲'),
              choiceColumn: ModalChoiceWidget(
                submitText: '네',
                onSubmit: () async {
                  if (!isLoading) {
                    if (!mounted) return;
                    setState(() {
                      isLoading = true;
                    });
                    ref.read(mailProvider(widget.mail.id).notifier).reply(
                      controller.value.text,
                      () async {
                        await ref.refresh(
                            mailListProvider(widget.mail.assign).future);
                        mailService.deleteBeforeReply(widget.mail.id);
                        mailService.requestRandomlyAppReview();
                        if (!mounted) return;
                        setState(() {
                          isLoading = false;
                        });
                      },
                    );
                    router.pop();
                  }
                },
                cancelText: '아니요',
                onCancel: () async {
                  if (!isLoading) {
                    context.pop();
                  }
                },
              ),
            ),
          );
        },
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MailInfoWidget(
          byFullName: widget.mail.to_first_name,
          toFullName: widget.characterName,
          byImage: widget.mail.to_image,
          isMe: true,
          availableAt: clock.now(),
          primaryColorInMail: widget.primaryColorInMail,
        ),
        Form(
          key: widget.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                focusNode: widget.focusNode,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '답장을 입력해주세요.';
                  }
                  return null;
                },
                onChanged: (value) {
                  mailService.saveBeforeReply(
                    reply: value,
                    mailId: widget.mail.id,
                  );
                },
                controller: controller,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                minLines: 8,
                maxLength: 1000,
                decoration: InputDecoration(
                  helperText: '',
                  counterText: controller.text.length > 900
                      ? '${controller.text.length}/1000'
                      : '',
                  hintText: '답장을 입력해주세요...',
                  hintStyle:
                      userMailFontStyle.copyWith(color: ColorConstants.neutral),
                  border: InputBorder.none,
                ),
                style: userMailFontStyle,
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: FilledButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(ColorConstants.gray),
                  ),
                  onPressed: () {
                    if (isLoading) return;
                    if (widget.formKey.currentState!.validate()) {
                      showConfirmModal();
                    }
                  },
                  child: Builder(builder: (context) {
                    if (isLoading) {
                      return const Center(
                          child: CircularProgressIndicator.adaptive());
                    }
                    return const Text(
                      '답장 보내기',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 16,
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ],
    );
  }
}
