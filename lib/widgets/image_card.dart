import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../data/models/image_model.dart';

class ImageCard extends StatelessWidget {
  final ImageModel image;
  final bool isFavorite;

  final VoidCallback onTap;
  final VoidCallback onFavorite;

  const ImageCard({
    super.key,
    required this.image,
    required this.isFavorite,
    required this.onTap,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildImage(),

            // Bottom gradient
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 100,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black87,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Favorite button
            Positioned(
              top: 10,
              right: 10,
              child: Material(
                color: Colors.black54,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onFavorite,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Icon(
                      isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: isFavorite
                          ? Colors.redAccent
                          : Colors.white,
                      size: 21,
                    ),
                  ),
                ),
              ),
            ),

            // User information
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: IgnorePointer(
                child: Row(
                  children: [
                    if (image.userImageUrl.isNotEmpty)
                      _buildUserAvatar(),

                    if (image.userImageUrl.isNotEmpty)
                      const SizedBox(width: 8),

                    Expanded(
                      child: Text(
                        image.user.isEmpty
                            ? 'Unknown'
                            : image.user,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    // IMPORTANT:
    // Flutter Web + CanvasKit can have CORS/WebGL
    // problems with remote images.
    //
    // Therefore use Image.network on Web.
    if (kIsWeb) {
      return Image.network(
        image.webFormatUrl,
        fit: BoxFit.cover,

        loadingBuilder: (
            context,
            child,
            loadingProgress,
            ) {
          if (loadingProgress == null) {
            return child;
          }

          return Container(
            color: const Color(0xFF171920),
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
          );
        },

        errorBuilder: (
            context,
            error,
            stackTrace,
            ) {
          return _imageError();
        },
      );
    }

    // Android / iOS
    return CachedNetworkImage(
      imageUrl: image.webFormatUrl,
      fit: BoxFit.cover,

      placeholder: (
          context,
          url,
          ) {
        return Container(
          color: const Color(0xFF171920),
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),
        );
      },

      errorWidget: (
          context,
          url,
          error,
          ) {
        return _imageError();
      },
    );
  }

  Widget _imageError() {
    return Container(
      color: const Color(0xFF171920),
      child: const Center(
        child: Icon(
          Icons.broken_image_outlined,
          size: 40,
          color: Colors.white38,
        ),
      ),
    );
  }

  Widget _buildUserAvatar() {
    if (kIsWeb) {
      return CircleAvatar(
        radius: 16,
        backgroundColor: Colors.white12,
        backgroundImage: NetworkImage(
          image.userImageUrl,
        ),
      );
    }

    return CircleAvatar(
      radius: 16,
      backgroundColor: Colors.white12,
      backgroundImage: NetworkImage(
        image.userImageUrl,
      ),
    );
  }
}