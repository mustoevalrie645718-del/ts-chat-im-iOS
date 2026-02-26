import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_download_manager/flutter_download_manager.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:mime/mime.dart';
import 'package:openim_common/openim_common.dart';
import 'package:flutter_media_store/flutter_media_store.dart';

class DownloadController extends GetxController {
  final downloadManager = DownloadManager();
  String? savedDir;
  final downloadTaskList = <String?, DownloadTask>{}.obs;

  @override
  void onInit() {
    _initDir();
    super.onInit();
  }

  _initDir() async {
    savedDir ??= await IMUtils.getDownloadFileDir();
  }

  DownloadTask? getTask(String url) {
    return downloadManager.getDownload(url);
  }

  bool isExistTask(String url) {
    return null != downloadTaskList[url];
  }

  bool isExistMessageTask(Message message) =>
      message.isFileType && null != message.fileElem?.sourceUrl && isExistTask(message.fileElem!.sourceUrl!);

  ValueNotifier<DownloadStatus> getStatus(Message message) => downloadTaskList[message.fileElem!.sourceUrl!]!.status;

  ValueNotifier<double> getProgress(Message message) => downloadTaskList[message.fileElem!.sourceUrl!]!.progress;

  void addDownload(String url, {String? path, Function(String sandboxPath, String externalPath)? onCompleted}) {
    Permissions.storage(() async {
      await _initDir();
      var fileName = path?.isNotEmpty == true ? path!.split('/').last : downloadManager.getFileNameFromUrl(url);
      path ??= "$savedDir/$fileName";
      DownloadTask? task = await downloadManager.addDownload(url, path!);
      if (null != task) downloadTaskList[url] = task;

      task?.status.addListener(() async {
        if (task.status.value == DownloadStatus.completed) {
          if (Platform.isIOS) {
            onCompleted?.call(path!, path!);

            return;
          }
          final packgInfo = await DeviceInfoPlugin().androidInfo;
          late String externalStorageDirPath;

          if (packgInfo.version.sdkInt <= 29) {
            externalStorageDirPath = '/storage/emulated/0/Download/IM/file';
            Directory(externalStorageDirPath).createSync(recursive: true);
            final desPath = '$externalStorageDirPath/$fileName';
            File(path!).copySync(desPath);

            onCompleted?.call(path!, desPath);
          } else {
            final fileData = File(path!).readAsBytesSync();
            final mimeType = lookupMimeType(path!) ?? (IMUtils.getMediaType(path!) ?? url.split('.').last);
            const rootFolderName = 'IM';
            const folderName = 'file';

            FlutterMediaStore().saveFile(
                fileData: fileData,
                mimeType: mimeType,
                rootFolderName: rootFolderName,
                folderName: folderName,
                fileName: fileName,
                onSuccess: (uri, filePath) {
                  onCompleted?.call(path!, filePath);
                },
                onError: (errorMessage) {
                  Logger.print('Flutter MediaStore saveFile error: $errorMessage');
                });
          }
        }
      });
    });
  }

  void addDownloadForMessage(Message message, {String? path}) {
    if (message.isFileType) {
      final url = message.fileElem?.sourceUrl;
      if (null != url) {
        Permissions.storage(() async {
          await _initDir();
          path ??= "$savedDir/${downloadManager.getFileNameFromUrl(url)}";
          DownloadTask? task = await downloadManager.addDownload(url, path!);
          if (null != task) downloadTaskList[url] = task;
        });
      }
    }
  }

  void clickFileMessage(String url, String path,
      {Function(String sandboxPath, String externalPath)? onCompleted}) async {
    var task = getTask(url);
    Logger.print(
        'clickFileMessage 当前状态： ${task?.status.value}  进度：${task?.progress.value} 完成：${task?.status.value.isCompleted}  $url  $path');
    if (task != null && !task.status.value.isCompleted) {
      // downloadManager.cancelDownload(url);
      switch (task.status.value) {
        case DownloadStatus.downloading:
          downloadManager.pauseDownload(url);
          break;
        case DownloadStatus.paused:
          downloadManager.resumeDownload(url);
          break;
        case DownloadStatus.queued:
          // addDownload(url, path: path);
          break;
        case DownloadStatus.completed:
          // downloadManager.removeDownload(url);
          break;
        case DownloadStatus.failed:
          await downloadManager.removeDownload(url);
          addDownload(url, path: path);
          break;
        case DownloadStatus.canceled:
          addDownload(url, path: path);
          break;
      }
    } else {
      addDownload(url, path: path, onCompleted: onCompleted);
    }
  }
}
