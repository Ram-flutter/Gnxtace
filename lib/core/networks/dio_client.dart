import 'package:dio/dio.dart';

import '../constants/api_constants.dart';

class DioClient {
  DioClient._();

  static final Dio instance = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,

      connectTimeout: const Duration(
        seconds: 15,
      ),

      receiveTimeout: const Duration(
        seconds: 30,
      ),

      headers: {
        'Accept': 'application/json',
      },

      responseType: ResponseType.json,
    ),
  );
}