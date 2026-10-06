import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/image_model.dart';
import '../data/repositories/image_repository.dart';

final imageRepositoryProvider = Provider<ImageRepository>((ref) {
  return ImageRepository();
});

final galleryProvider =
NotifierProvider<GalleryNotifier, GalleryState>(
  GalleryNotifier.new,
);

class GalleryState {
  final List<ImageModel> images;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;
  final String searchQuery;
  final String selectedCategory;

  const GalleryState({
    this.images = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
    this.searchQuery = '',
    this.selectedCategory = '',
  });

  GalleryState copyWith({
    List<ImageModel>? images,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    String? searchQuery,
    String? selectedCategory,
    bool clearError = false,
  }) {
    return GalleryState(
      images: images ?? this.images,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : error ?? this.error,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory:
      selectedCategory ?? this.selectedCategory,
    );
  }
}

class GalleryNotifier extends Notifier<GalleryState> {
  late final ImageRepository _repository;

  int _currentPage = 1;

  @override
  GalleryState build() {
    _repository = ref.read(imageRepositoryProvider);

    Future.microtask(loadInitial);

    return const GalleryState();
  }

  Future<void> loadInitial() async {
    _currentPage = 1;

    state = state.copyWith(
      isLoading: true,
      isLoadingMore: false,
      hasMore: true,
      clearError: true,
    );

    try {
      final images = await _repository.getImages(
        page: 1,
        query: state.searchQuery,
        category: state.selectedCategory,
      );

      state = state.copyWith(
        images: images,
        isLoading: false,
        hasMore: images.length >= 20,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadNextPage() async {
    if (state.isLoading ||
        state.isLoadingMore ||
        !state.hasMore) {
      return;
    }

    state = state.copyWith(
      isLoadingMore: true,
    );

    final nextPage = _currentPage + 1;

    try {
      final newImages = await _repository.getImages(
        page: nextPage,
        query: state.searchQuery,
        category: state.selectedCategory,
      );

      _currentPage = nextPage;

      state = state.copyWith(
        images: [
          ...state.images,
          ...newImages,
        ],
        isLoadingMore: false,
        hasMore: newImages.length >= 20,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    await loadInitial();
  }

  Future<void> search(String query) async {
    state = state.copyWith(
      searchQuery: query,
    );

    await loadInitial();
  }

  Future<void> selectCategory(String category) async {
    state = state.copyWith(
      selectedCategory: category,
    );

    await loadInitial();
  }

  void clearSearch() {
    state = state.copyWith(
      searchQuery: '',
    );

    loadInitial();
  }
}