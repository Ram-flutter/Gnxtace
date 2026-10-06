import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/image_model.dart';
import '../providers/favorites_provider.dart';

class DetailScreen extends ConsumerWidget {
  final ImageModel image;

  const DetailScreen({
    super.key,
    required this.image,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);

    final isFavorite = favorites.any(
          (item) => item.id == image.id,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF08090D),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 430,
            pinned: true,
            backgroundColor: const Color(0xFF08090D),

            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back_rounded,
              ),
            ),

            actions: [
              IconButton(
                onPressed: () {
                  ref
                      .read(favoritesProvider.notifier)
                      .toggleFavorite(image);
                },
                icon: Icon(
                  isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: isFavorite
                      ? Colors.redAccent
                      : Colors.white,
                ),
              ),
            ],

            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'image_${image.id}',
                child: CachedNetworkImage(
                  imageUrl: image.largeImageUrl,
                  fit: BoxFit.cover,
                  errorWidget: (
                      context,
                      url,
                      error,
                      ) {
                    return const Center(
                      child: Icon(
                        Icons.broken_image_outlined,
                        size: 50,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    image.user,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    image.tags,
                    style: const TextStyle(
                      color: Colors.white54,
                    ),
                  ),

                  const SizedBox(height: 30),

                  Row(
                    children: [
                      _Stat(
                        icon: Icons.favorite_rounded,
                        value: _formatNumber(
                          image.likes,
                        ),
                        label: 'Likes',
                      ),
                      _Stat(
                        icon: Icons.visibility_rounded,
                        value: _formatNumber(
                          image.views,
                        ),
                        label: 'Views',
                      ),
                      _Stat(
                        icon: Icons.download_rounded,
                        value: _formatNumber(
                          image.downloads,
                        ),
                        label: 'Downloads',
                      ),
                    ],
                  ),

                  const SizedBox(height: 35),

                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Download feature coming next',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.download_rounded,
                      ),
                      label: const Text(
                        'Download Image',
                      ),
                      style: FilledButton.styleFrom(
                        padding:
                        const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    }

    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }

    return number.toString();
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _Stat({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            color: const Color(0xFFB7A1FF),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}