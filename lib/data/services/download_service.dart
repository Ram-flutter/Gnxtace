import 'dart:io';

import 'package:dio/dio.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';

class DownloadService {
  DownloadService._();

  static final Dio _dio = Dio();

  static Future<void> downloadImage({
    required String imageUrl,
    required String fileName,
    required void Function(double progress) onProgress,
  }) async {
    try {
      // Request gallery permission.
      final hasAccess = await Gal.hasAccess();

      if (!hasAccess) {
        final granted = await Gal.requestAccess();

        if (!granted) {
          throw Exception(
            'Gallery permission was denied.',
          );
        }
      }

      // Temporary directory.
      final directory = await getTemporaryDirectory();

      // Make sure filename has an extension.
      final safeFileName = fileName.toLowerCase().endsWith('.jpg')
          ? fileName
          : '$fileName.jpg';

      final filePath = '${directory.path}/$safeFileName';

      // Download image.
      await _dio.download(
        imageUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            onProgress(received / total);
          }
        },
      );

      // Save downloaded image to device gallery.
      await Gal.putImage(filePath);

      // Delete temporary file.
      final file = File(filePath);

      if (await file.exists()) {
        await file.delete();
      }
    } on DioException catch (e) {
      throw Exception(
        'Image download failed: ${e.message ?? 'Network error'}',
      );
    } on GalException catch (e) {
      throw Exception(
        'Unable to save image to gallery: ${e.type}',
      );
    } catch (e) {
      throw Exception(
        e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }
}