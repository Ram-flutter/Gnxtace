import '../models/image_model.dart';
import '../services/image_api_service.dart';

class ImageRepository {
  final ImageApiService _apiService;

  ImageRepository({
    ImageApiService? apiService,
  }) : _apiService = apiService ?? ImageApiService();

  Future<List<ImageModel>> getImages({
    required int page,
    String query = '',
    String category = '',
  }) {
    return _apiService.fetchImages(
      page: page,
      query: query,
      category: category,
    );
  }
}