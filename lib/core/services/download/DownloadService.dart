import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class DownloadService {
  final Dio _dio = Dio();

  Future<File> downloadAudio({
    required String url,
    required String fileName,
    required Function(double progress) onProgress,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/audio/$fileName';

    final file = File(filePath);
    await file.parent.create(recursive: true);

    await _dio.download(
      url,
      filePath,
      onReceiveProgress: (received, total) {
        if (total > 0) {
          onProgress(received / total);
        }
      },
    );

    return file;
  }
}
