import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/models/image_model.dart';

final favoritesProvider =
NotifierProvider<FavoritesNotifier, List<ImageModel>>(
  FavoritesNotifier.new,
);

class FavoritesNotifier
    extends Notifier<List<ImageModel>> {
  static const String _storageKey = 'favorite_images';

  @override
  List<ImageModel> build() {
    Future.microtask(_loadFavorites);

    return [];
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getStringList(_storageKey);

    if (data == null) {
      return;
    }

    final favorites = data.map((item) {
      final json = jsonDecode(item);

      return ImageModel.fromJson(
        Map<String, dynamic>.from(json),
      );
    }).toList();

    state = favorites;
  }

  bool isFavorite(int id) {
    return state.any((image) => image.id == id);
  }

  Future<void> toggleFavorite(ImageModel image) async {
    final exists = isFavorite(image.id);

    if (exists) {
      state = state
          .where((item) => item.id != image.id)
          .toList();
    } else {
      state = [
        image,
        ...state,
      ];
    }

    await _saveFavorites();
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();

    final data = state
        .map(
          (image) => jsonEncode(image.toJson()),
    )
        .toList();

    await prefs.setStringList(
      _storageKey,
      data,
    );
  }
}