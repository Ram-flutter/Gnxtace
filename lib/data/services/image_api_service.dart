import 'package:dio/dio.dart';

import '../../core/constants/api_constants.dart';
import '../../core/networks/dio_client.dart';
import '../models/image_model.dart';

class ImageApiService {
  final Dio _dio;

  ImageApiService({
    Dio? dio,
  }) : _dio = dio ?? DioClient.instance;

  Future<List<ImageModel>> fetchImages({
    required int page,
    String query = '',
    String category = '',
  }) async {
    try {
      final response = await _dio.get(
        '',
        queryParameters: {
          'key': ApiConstants.apiKey,
          'page': page,
          'per_page': ApiConstants.perPage,
          'image_type': 'photo',
          'orientation': 'all',
          'safesearch': true,
          if (query.trim().isNotEmpty) 'q': query.trim(),
          if (category.isNotEmpty) 'category': category,
        },
      );

      final data = response.data;

      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid server response');
      }

      final hits = data['hits'];

      if (hits is! List) {
        throw Exception('Invalid image data');
      }

      return hits
          .whereType<Map<String, dynamic>>()
          .map(ImageModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.message ?? 'Unable to connect to image service',
      );
    } catch (e) {
      throw Exception(
        e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }
}