import 'dart:convert';

import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:openim_common/openim_common.dart';
import 'package:uuid/uuid.dart';

/// flutter packages pub run build_runner build
/// flutter packages pub run build_runner build --delete-conflicting-outputs
///
class CacheController extends GetxController {
  final favoriteList = <EmojiInfo>[].obs;
  final callRecordList = <CallRecords>[].obs;
  Box? favoriteBox;
  Box? callRecordBox;
  bool _isInitFavoriteList = false;
  bool _isInitCallRecords = false;

  String get userID => DataSp.getLoginCertificate()!.userID;

  void addFavoriteFromUrl(String path, String? url, int? width, int? height) {
    var emoji = EmojiInfo(path: path, url: url, width: width, height: height);
    favoriteList.insert(0, emoji);
    final list = favoriteList.value;
    favoriteBox?.put(userID, list);
  }

  Future addFavoriteFromPath(String path, int width, int height) async {
    if (favoriteList.any((element) => element.path == path)) {
      throw Exception({'code': -1, 'message': 'Favorite already exists'});
    }
    var result = await LoadingView.singleton.wrap(
      asyncFunction: () => OpenIM.iMManager.uploadFile(
        id: const Uuid().v4(),
        filePath: path,
        fileName: path,
      ),
    );
    if (result is String) {
      final url = jsonDecode(result)['url'];
      Logger.print('url:$url');
      var emoji = EmojiInfo(path: path, url: url, width: width, height: height);
      Logger.print('addFavoriteFromPath :$url');
      favoriteList.insert(0, emoji);
      favoriteBox?.put(userID, favoriteList.value);
    }
  }

  void delFavorite(String url) {
    favoriteList.removeWhere((element) => element.url == url);
    favoriteBox?.put(userID, favoriteList.value);
  }

  void delFavoriteList(List<String> urlList) {
    for (final url in urlList) {
      favoriteList.removeWhere((element) => element.url == url);
    }
    favoriteBox?.put(userID, favoriteList.value);
  }

  initFavoriteEmoji() {
    if (!_isInitFavoriteList) {
      _isInitFavoriteList = true;
      var list = favoriteBox?.get(userID, defaultValue: <EmojiInfo>[]);
      if (list != null) {
        favoriteList.assignAll((list as List).cast());
      }
    }
  }

  List<String> get urlList => favoriteList.map((e) => e.url!).toList();

  initCallRecords() {
    if (!_isInitCallRecords) {
      _isInitCallRecords = true;
      var list = callRecordBox?.get(userID, defaultValue: <CallRecords>[]);
      if (list != null) {
        callRecordList.assignAll((list as List).cast());
      }
    }
  }

  void resetCache() {
    if (_isInitCallRecords) {
      callRecordList.value = [];
      final list = callRecordBox?.get(userID, defaultValue: <CallRecords>[]);

      if (list != null) {
        callRecordList.assignAll((list as List).cast());
      }
    }

    if (_isInitFavoriteList) {
      favoriteList.value = [];
      final list = favoriteBox?.get(userID, defaultValue: <CallRecords>[]);

      if (list != null) {
        favoriteList.assignAll((list as List).cast());
      }
    }
  }

  addCallRecords(CallRecords records) {
    callRecordList.insert(0, records);
    callRecordBox?.put(userID, callRecordList.value);
  }

  deleteCallRecords(CallRecords records) async {
    callRecordList.removeWhere((element) => element.userID == records.userID && element.date == records.date);
    await callRecordBox?.put(userID, callRecordList.value);
  }

  bool isEmojiExist(String url) {
    return favoriteList.any((element) => element.url == url);
  }

  @override
  void onClose() {
    _isInitFavoriteList = false;
    _isInitCallRecords = false;
    Hive.close();
    super.onClose();
  }

  @override
  void onInit() async {
    // Register Adapter
    Hive.registerAdapter(EmojiInfoAdapter());
    Hive.registerAdapter(CallRecordsAdapter());
    // open
    favoriteBox = await Hive.openBox<List>('favoriteEmoji');
    callRecordBox = await Hive.openBox<List>('callRecords');
    super.onInit();
  }
}
