import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:project_june_client/actions/character/models/CharacterImage.dart';
import 'package:project_june_client/contrib/flutter_secure_storage.dart';

class CharacterService {
  const CharacterService();

  static const _CHARACTER_ID_KEY = 'CHARACTER_ID';

  List<CharacterImage> selectStackedImageList(List<CharacterImage> imageList) {
    final revealedImageList =
        imageList.where((image) => image.is_blurred == false).toList();
    if (revealedImageList.length >= 3) {
      return revealedImageList.sublist(revealedImageList.length - 3);
    }
    return List.from(imageList.sublist(0, 3 - revealedImageList.length))
      ..addAll(revealedImageList);
  }

  CharacterImage getMainImage(List<CharacterImage> imageList) {
    final mainImageList =
        imageList.where((image) => image.is_main == true).toList();
    return mainImageList.first;
  }

  List<Widget> addBlur() {
    return [
      Positioned.fill(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      ),
      Positioned.fill(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        ),
      ),
    ];
  }

  Future<int?> getSelectedCharacterId() async {
    final storage = getSecureStorage();
    final selectedCharacterId = await storage.read(key: _CHARACTER_ID_KEY);
    if (selectedCharacterId == null) return null;
    return int.parse(selectedCharacterId);
  }

  Future<void> saveSelectedCharacterId({
    required int selectedCharacterId,
  }) async {
    final storage = getSecureStorage();
    await storage.write(
        key: _CHARACTER_ID_KEY, value: selectedCharacterId.toString());
  }

  Future<void> deleteSelectedCharacterId() async {
    final storage = getSecureStorage();
    await storage.delete(key: _CHARACTER_ID_KEY);
  }
}
