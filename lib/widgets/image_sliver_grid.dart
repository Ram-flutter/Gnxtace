import 'package:flutter/material.dart';

import '../data/models/image_model.dart';
import 'image_card.dart';

class ImageSliverGrid extends StatelessWidget {
  final List<ImageModel> images;
  final Set<int> favorites;

  final ValueChanged<ImageModel> onTap;
  final ValueChanged<int> onFavorite;

  const ImageSliverGrid({
    super.key,
    required this.images,
    required this.favorites,
    required this.onTap,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    int columns;

    if (screenWidth >= 1200) {
      columns = 4;
    } else if (screenWidth >= 800) {
      columns = 3;
    } else {
      columns = 2;
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        16,
        8,
        16,
        20,
      ),

      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            final image = images[index];

            return ImageCard(
              image: image,
              isFavorite: favorites.contains(image.id),

              onTap: () {
                onTap(image);
              },

              onFavorite: () {
                onFavorite(image.id);
              },
            );
          },

          childCount: images.length,
        ),

        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,

          childAspectRatio: 0.72,
        ),
      ),
    );
  }
}