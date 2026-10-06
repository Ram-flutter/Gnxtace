import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gnxtace/widgets/image_sliver_grid.dart';

import '../providers/favorites_provider.dart';
import '../providers/gallery_provider.dart';
import '../widgets/category_chips.dart';
import '../widgets/error_view.dart';

import '../widgets/loading_grid.dart';
import '../widgets/search_box.dart';
import 'detail_screen.dart';
import 'favorites_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final ScrollController _scrollController;

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final position = _scrollController.position;

    if (position.pixels >= position.maxScrollExtent - 600) {
      ref.read(galleryProvider.notifier).loadNextPage();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentIndex == 1) {
      return const FavoritesScreen();
    }

    final gallery = ref.watch(galleryProvider);
    final favorites = ref.watch(favoritesProvider);

    final favoriteIds = favorites.map((image) => image.id).toSet();

    return Scaffold(
      backgroundColor: const Color(0xFF08090D),

      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),

            const SizedBox(height: 8),

            SearchBox(
              initialValue: gallery.searchQuery,
              onSearch: (value) {
                ref.read(galleryProvider.notifier).search(value);
              },
            ),

            const SizedBox(height: 12),

            CategoryChips(
              selected: gallery.selectedCategory,
              onSelected: (category) {
                ref
                    .read(galleryProvider.notifier)
                    .selectCategory(category);
              },
            ),

            const SizedBox(height: 8),

            Expanded(
              child: _buildGallery(
                gallery,
                favoriteIds,
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF101116),

        selectedIndex: _currentIndex,

        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },

        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        20,
        20,
        8,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'LUMA',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Discover beautiful images',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFF17131F),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Color(0xFFB794F6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGallery(
      GalleryState gallery,
      Set<int> favoriteIds,
      ) {
    // Initial loading
    if (gallery.isLoading && gallery.images.isEmpty) {
      return const LoadingGrid();
    }

    // Initial API error
    if (gallery.error != null && gallery.images.isEmpty) {
      return ErrorView(
        message: gallery.error!,
        onRetry: () {
          ref.read(galleryProvider.notifier).refresh();
        },
      );
    }

    // No result
    if (gallery.images.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              size: 60,
              color: Colors.white30,
            ),
            SizedBox(height: 16),
            Text(
              'No images found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Try another search or category',
              style: TextStyle(
                color: Colors.white54,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () {
        return ref.read(galleryProvider.notifier).refresh();
      },

      child: CustomScrollView(
        controller: _scrollController,

        physics: const AlwaysScrollableScrollPhysics(),

        slivers: [
          ImageSliverGrid(
            images: gallery.images,
            favorites: favoriteIds,

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
              final image = gallery.images.firstWhere(
                    (item) => item.id == id,
              );

              ref
                  .read(favoritesProvider.notifier)
                  .toggleFavorite(image);
            },
          ),

          // Pagination loading
          if (gallery.isLoadingMore)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 25,
                ),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),

          // Pagination error
          if (gallery.error != null &&
              gallery.images.isNotEmpty &&
              !gallery.isLoadingMore)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: TextButton.icon(
                    onPressed: () {
                      ref
                          .read(galleryProvider.notifier)
                          .loadNextPage();
                    },
                    icon: const Icon(
                      Icons.refresh,
                    ),
                    label: const Text(
                      'Load more',
                    ),
                  ),
                ),
              ),
            ),

          // Pixabay attribution
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(
                top: 10,
                bottom: 30,
              ),
              child: Center(
                child: Text(
                  'Images from Pixabay',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}