import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/image_model.dart';
import '../data/services/download_service.dart';
import '../providers/favorites_provider.dart';

class DetailScreen extends ConsumerStatefulWidget {
  final ImageModel image;

  const DetailScreen({
    super.key,
    required this.image,
  });

  @override
  ConsumerState<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends ConsumerState<DetailScreen> {
  bool _isDownloading = false;
  double _downloadProgress = 0;

  Future<void> _downloadImage() async {
    if (_isDownloading) return;

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0;
    });

    try {
      final fileName =
          'luma_${widget.image.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      await DownloadService.downloadImage(
        imageUrl: widget.image.largeImageUrl,
        fileName: fileName,
        onProgress: (progress) {
          if (!mounted) return;

          setState(() {
            _downloadProgress = progress;
          });
        },
      );

      if (!mounted) return;

      setState(() {
        _isDownloading = false;
        _downloadProgress = 1;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.white,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Image saved successfully to your gallery.',
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isDownloading = false;
        _downloadProgress = 0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: _downloadImage,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final favorites = ref.watch(favoritesProvider);

    final isFavorite = favorites.any(
          (item) => item.id == widget.image.id,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF08090D),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 430,
            pinned: true,
            backgroundColor: const Color(0xFF08090D),
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: isFavorite
                          ? Colors.redAccent
                          : Colors.white,
                    ),
                    onPressed: () {
                      ref
                          .read(favoritesProvider.notifier)
                          .toggleFavorite(widget.image);
                    },
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'image_${widget.image.id}',
                child: _buildDetailImage(),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                24,
                20,
                40,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitleSection(),

                  const SizedBox(height: 22),

                  _buildStats(),

                  const SizedBox(height: 24),

                  _buildDownloadButton(),

                  const SizedBox(height: 28),

                  _buildDescription(),

                  const SizedBox(height: 28),

                  _buildTags(),

                  const SizedBox(height: 28),

                  _buildImageInformation(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailImage() {
    if (kIsWeb) {
      return Image.network(
        widget.image.largeImageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return _imageError();
        },
      );
    }

    return CachedNetworkImage(
      imageUrl: widget.image.largeImageUrl,
      fit: BoxFit.cover,
      placeholder: (_, __) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
      errorWidget: (_, __, ___) {
        return _imageError();
      },
    );
  }

  Widget _imageError() {
    return Container(
      color: const Color(0xFF15171E),
      child: const Center(
        child: Icon(
          Icons.broken_image_outlined,
          size: 60,
          color: Colors.white54,
        ),
      ),
    );
  }

  Widget _buildTitleSection() {
    return Row(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundImage:
          widget.image.userImageUrl.isNotEmpty
              ? NetworkImage(widget.image.userImageUrl)
              : null,
          child: widget.image.userImageUrl.isEmpty
              ? const Icon(Icons.person)
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                widget.image.user.isEmpty
                    ? 'Unknown Photographer'
                    : widget.image.user,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Photographer',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.55),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStats() {
    return Row(
      children: [
        Expanded(
          child: _Stat(
            icon: Icons.favorite,
            label: 'Likes',
            value: _formatNumber(widget.image.likes),
          ),
        ),
        Expanded(
          child: _Stat(
            icon: Icons.visibility,
            label: 'Views',
            value: _formatNumber(widget.image.views),
          ),
        ),
        Expanded(
          child: _Stat(
            icon: Icons.download,
            label: 'Downloads',
            value: _formatNumber(widget.image.downloads),
          ),
        ),
      ],
    );
  }

  Widget _buildDownloadButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton.icon(
        onPressed: _isDownloading
            ? null
            : _downloadImage,
        icon: _isDownloading
            ? SizedBox(
          width: 21,
          height: 21,
          child: CircularProgressIndicator(
            value: _downloadProgress > 0
                ? _downloadProgress
                : null,
            strokeWidth: 2.5,
            color: Colors.white,
          ),
        )
            : const Icon(Icons.download_rounded),
        label: Text(
          _isDownloading
              ? 'Downloading ${(_downloadProgress * 100).toInt()}%'
              : 'Download Image',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildDescription() {
    final description = widget.image.tags.trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF12141A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const Text(
            'About this image',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description.isEmpty
                ? 'A beautiful image available on Pixabay.'
                : 'This image contains content related to '
                '$description.',
            style: TextStyle(
              height: 1.5,
              color: Colors.white.withValues(alpha: 0.65),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTags() {
    final tags = widget.image.tagList;

    if (tags.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        const Text(
          'Tags',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: tags.map(
                (tag) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF181A22),
                  borderRadius:
                  BorderRadius.circular(30),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    color: Colors.white.withValues(
                      alpha: 0.75,
                    ),
                    fontSize: 12,
                  ),
                ),
              );
            },
          ).toList(),
        ),
      ],
    );
  }

  Widget _buildImageInformation() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF12141A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const Text(
            'Image Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          _InfoRow(
            title: 'Dimensions',
            value:
            '${widget.image.imageWidth} × ${widget.image.imageHeight}',
          ),
          _InfoRow(
            title: 'Aspect Ratio',
            value:
            widget.image.aspectRatio.toStringAsFixed(2),
          ),
          _InfoRow(
            title: 'Comments',
            value:
            _formatNumber(widget.image.comments),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }

    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }

    return value.toString();
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _Stat({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          size: 21,
          color: Colors.white70,
        ),
        const SizedBox(height: 7),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(
              alpha: 0.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String title;
  final String value;

  const _InfoRow({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white.withValues(
                  alpha: 0.55,
                ),
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}