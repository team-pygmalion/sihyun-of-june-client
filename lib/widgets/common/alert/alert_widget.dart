import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AlertWidget extends StatelessWidget {
  final String? title;
  final Widget? content;
  final String? confirmText;
  void Function()? onConfirm;

  AlertWidget(
      {super.key, this.title, this.content, this.confirmText, this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      clipBehavior: Clip.hardEdge,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      title: title != null
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: Text(
                title ?? "",
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            )
          : null,
      content: content,
      buttonPadding: const EdgeInsets.only(bottom: 20),
      actionsPadding: const EdgeInsets.all(0),
      actions: [
        confirmText != null
            ? SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0),
                      ),
                    ),
                  ),
                  onPressed: onConfirm ?? () => context.pop(),
                  child: Text(confirmText!),
                ),
              )
            : SizedBox.shrink(),
      ],
    );
  }
}
