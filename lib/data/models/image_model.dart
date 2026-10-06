class ImageModel {
  final int id;
  final String pageUrl;
  final String previewUrl;
  final String webFormatUrl;
  final String largeImageUrl;
  final String user;
  final String userImageUrl;
  final String tags;
  final int views;
  final int downloads;
  final int likes;
  final int comments;
  final int imageWidth;
  final int imageHeight;

  const ImageModel({
    required this.id,
    required this.pageUrl,
    required this.previewUrl,
    required this.webFormatUrl,
    required this.largeImageUrl,
    required this.user,
    required this.userImageUrl,
    required this.tags,
    required this.views,
    required this.downloads,
    required this.likes,
    required this.comments,
    required this.imageWidth,
    required this.imageHeight,
  });

  factory ImageModel.fromJson(Map<String, dynamic> json) {
    return ImageModel(
      id: json['id'] ?? 0,
      pageUrl: json['pageURL'] ?? '',
      previewUrl: json['previewURL'] ?? '',
      webFormatUrl: json['webformatURL'] ?? '',
      largeImageUrl: json['largeImageURL'] ?? '',
      user: json['user'] ?? 'Unknown',
      userImageUrl: json['userImageURL'] ?? '',
      tags: json['tags'] ?? '',
      views: json['views'] ?? 0,
      downloads: json['downloads'] ?? 0,
      likes: json['likes'] ?? 0,
      comments: json['comments'] ?? 0,
      imageWidth: json['imageWidth'] ?? 1,
      imageHeight: json['imageHeight'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pageURL': pageUrl,
      'previewURL': previewUrl,
      'webformatURL': webFormatUrl,
      'largeImageURL': largeImageUrl,
      'user': user,
      'userImageURL': userImageUrl,
      'tags': tags,
      'views': views,
      'downloads': downloads,
      'likes': likes,
      'comments': comments,
      'imageWidth': imageWidth,
      'imageHeight': imageHeight,
    };
  }

  List<String> get tagList {
    return tags
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();
  }

  double get aspectRatio {
    if (imageHeight == 0) {
      return 1;
    }

    return imageWidth / imageHeight;
  }
}