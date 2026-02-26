import 'dart:io';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../../openim_common.dart';

class MultiThreadDownloader {
  final Dio dio = Dio();
  final String url;
  final int threads; // Number of threads
  final String fileName;
  final int? length;

  MultiThreadDownloader({required this.url, this.threads = 4, required this.fileName, this.length}) {
    _lastReceived = List<int>.filled(threads, 0); // Initialize list for tracking progress
  }

  double _downloadedBytes = 0; // Total bytes downloaded
  String? _realUrl;
  ValueChanged? _onProgress;
  late int _fileSize; // Total file size
  final CancelToken _cancelToken = CancelToken();

  List<int> _lastReceived = []; // Store last received bytes for each thread

  Future<String?> start({ValueChanged? onProgress}) async {
    _onProgress = onProgress;
    // Step 1: Get the file size after handling redirection
    _fileSize = await _getFileSize() ?? 0;
    if (_fileSize == 0) {
      Logger.print('Unable to retrieve file size');
      return null;
    }
    Logger.print('File size: $_fileSize bytes');

    // Step 2: Create local file path
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String filePath = '${appDocDir.path}/$fileName';

    // Step 3: Calculate the byte range for each thread
    final chunkSize = (_fileSize / threads).ceil(); // Size of each chunk

    List<Future<File>> futures = [];

    // Step 4: Download chunks concurrently
    for (int i = 0; i < threads; i++) {
      final start = i * chunkSize;
      final end = (i == threads - 1) ? _fileSize - 1 : (start + chunkSize - 1);

      futures.add(_downloadChunk(start, end, i, filePath));
    }

    // Wait for all threads to finish downloading
    await Future.wait(futures);

    Logger.print('All chunks downloaded, file path: $filePath');
    final path = await mergeChunks(filePath); // Merge chunks into a single file

    return path;
  }

  // Get the file size, including handling redirection
  Future<int?> _getFileSize() async {
    try {
      _realUrl = await fetchRedirectedUrl(url: url);
      Logger.print('get file read url: url $_realUrl');

      if (length != null) {
        return length;
      }

      final response = await dio.head(
        _realUrl!,
      );

      // Get file size from headers
      final contentLength = response.headers.value(Headers.contentLengthHeader);
      return contentLength != null ? int.tryParse(contentLength) : null;
    } catch (e) {
      Logger.print('Failed to get file size: $e');
      return null;
    }
  }

  // Download a chunk of the file
  Future<File> _downloadChunk(int start, int end, int threadIndex, String filePath) async {
    // Create a temporary file to store the chunk
    String tempFilePath = '$filePath.part$threadIndex';

    Logger.print('Thread $threadIndex downloading range: $start-$end');

    // Make a request with Range header to download the specific byte range
    try {
      final response = await dio.download(
        _realUrl!,
        tempFilePath,
        options: Options(
          headers: {
            'Range': 'bytes=$start-$end',
          },
        ),
        cancelToken: _cancelToken,
        onReceiveProgress: (received, total) {
          final p = received / total.toDouble();
          Logger.print(
              'Thread $threadIndex download progress: ${(p * 100).toStringAsFixed(2)}%, received: $received, total: $total');
          _updateProgress(received, threadIndex);
        },
      );
      Logger.print('Thread $threadIndex download completed: ${response.statusCode}');
      return File(tempFilePath);
    } catch (e) {
      Logger.print('Thread $threadIndex download failed: $e');
      rethrow;
    }
  }

  // Update overall download progress
  void _updateProgress(int receivedBytes, int threadIndex) {
    int newBytes = receivedBytes - _lastReceived[threadIndex];
    _lastReceived[threadIndex] = receivedBytes;

    // Accumulate the number of bytes received
    _downloadedBytes += newBytes;

    // Calculate overall progress percentage
    double progress = _downloadedBytes / _fileSize;

    // Print or display download progress
    Logger.print(
      'Total download progress: ${(progress * 100).toStringAsFixed(2)}%, received: $_downloadedBytes',
    );

    _onProgress?.call(progress);
  }

  // Merge chunks into a single file
  Future<String> mergeChunks(String filePath) async {
    // Open target file for merging
    File file = File(filePath);
    IOSink fileSink = file.openWrite();

    try {
      // Read each chunk file and write to the target file
      for (int i = 0; i < threads; i++) {
        File chunkFile = File('$filePath.part$i');
        List<int> chunkBytes = await chunkFile.readAsBytes();
        fileSink.add(chunkBytes);
        await chunkFile.delete(); // Delete temporary chunk file after merging
      }
    } finally {
      await fileSink.close();
    }

    Logger.print('File merge completed: $filePath');
    return filePath;
  }

  Future<String> fetchRedirectedUrl({required String url}) async {
    final myRequest = await HttpClient().getUrl(Uri.parse(url));
    myRequest.followRedirects = false;
    final myResponse = await myRequest.close();
    final location = myResponse.headers.value(HttpHeaders.locationHeader);

    return location == null ? url : location.toString();
  }

  void cancel() {
    _cancelToken.cancel('Download cancelled');
    Logger.print('Download cancelled');
  }
}
