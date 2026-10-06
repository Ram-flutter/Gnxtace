import 'package:flutter/material.dart';

import '../data/models/image_model.dart';
import 'image_card.dart';

class ImageGrid extends StatelessWidget {
  final List<ImageModel> images;
  final Set<int> favorites;
  final ValueChanged<ImageModel> onTap;
  final ValueChanged<int> onFavorite;

  const ImageGrid({
    super.key,
    required this.images,
    required this.favorites,
    required this.onTap,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(
        16,
        8,
        16,
        100,
      ),
      itemCount: images.length,
      gridDelegate:
      const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      itemBuilder: (context, index) {
        final image = images[index];

        return ImageCard(
          image: image,
          isFavorite: favorites.contains(image.id),
          onTap: () => onTap(image),
          onFavorite: () => onFavorite(image.id),
        );
      },
    );
  }
}