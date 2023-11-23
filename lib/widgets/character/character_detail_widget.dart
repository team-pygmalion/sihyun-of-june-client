import 'package:cached_query_flutter/cached_query_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:launcher_icon_switcher/launcher_icon_switcher.dart';
import 'package:project_june_client/actions/character/models/Character.dart';
import 'package:project_june_client/actions/character/queries.dart';
import 'package:project_june_client/providers/character_theme_provider.dart';
import 'package:project_june_client/widgets/profile_widget.dart';

import '../../screens/character_choice_screen.dart';

class CharacterDetailWidget extends ConsumerWidget {
  final void Function(ActiveScreen) onActiveScreen;
  final void Function(int) onTestId;
  final void Function(String) onName;

  const CharacterDetailWidget(
      {super.key,
      required this.onActiveScreen,
      required this.onTestId,
      required this.onName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = getPendingTestQuery();
    return QueryBuilder(
      query: query,
      builder: (context, state) {
        Character? character;
        if (state.data == null) {
          return const SizedBox.shrink();
        }
        character = Character.fromJson(state.data!['character']);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(characterThemeProvider.notifier).state = character!.theme!;
          print("왜그럼?");
          if (state.status == QueryStatus.success) {
            switch (character.name!) {
              case "류시현":
                LauncherIconSwitcher().setIcon('LauncherSihyun');
                break;
              case "남우빈":
                LauncherIconSwitcher().setIcon('LauncherWoobin');
                break;
            }
          }
        });
        return Scaffold(
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(
                  height: 50,
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28.0,
                      vertical: 10,
                    ),
                    children: [
                      ProfileWidget(
                        name: character.name!,
                        defaultImage: character.default_image,
                        characterInfo: character.character_info!,
                        primaryColor: Color(character.theme!.colors!.primary!),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 28.0, right: 28.0, bottom: 20.0),
                  child: FilledButton(
                    onPressed: () {
                      onActiveScreen(ActiveScreen.confirm);
                      onTestId(state.data!['test_id']);
                      onName(character!.name!.substring(1));
                    },
                    child: const Text('다음'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
