import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/favorites_provider.dart';
import '../widgets/image_grid.dart';
import 'detail_screen.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({
    super.key,
  });

  @override
  Widget build(
      BuildContext context,
      WidgetRef ref,
      ) {
    final favorites = ref.watch(
      favoritesProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Text(
              'Favorites',
              style: TextStyle(
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'Your saved collection',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white38,
              ),
            ),
          ],
        ),
      ),

      body: favorites.isEmpty
          ? const _EmptyFavorites()
          : ImageGrid(
        images: favorites,
        favorites: favorites
            .map((image) => image.id)
            .toSet(),

        onTap: (image) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetailScreen(
                image: image,
              ),
            ),
          );
        },

        onFavorite: (id) {
          final image =
          favorites.firstWhere(
                (item) => item.id == id,
          );

          ref
              .read(
            favoritesProvider.notifier,
          )
              .toggleFavorite(image);
        },
      ),
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.favorite_border_rounded,
            size: 70,
            color: Colors.white24,
          ),
          SizedBox(height: 16),
          Text(
            'No favorites yet',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tap the heart to save beautiful images.',
            style: TextStyle(
              color: Colors.white38,
            ),
          ),
        ],
      ),
    );
  }
}