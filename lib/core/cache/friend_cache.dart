import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

/// Cache service for friends and blacklist
class FriendCache extends GetxService {
  final friends = <FriendInfo>[].obs;
  final blacklist = <BlacklistInfo>[].obs;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Preload friends and blacklist
  Future<void> preloadData() async {
    if (_isInitialized) return;

    try {
      await Future.wait([
        _loadFriends(),
        _loadBlacklist(),
      ]);
      _isInitialized = true;
      Logger.print('FriendCache: Preload completed');
    } catch (e, s) {
      Logger.print('FriendCache: Preload failed - $e\n$s');
    }
  }

  Future<void> _loadFriends() async {
    try {
      final list = await OpenIM.iMManager.friendshipManager.getFriendList();
      friends.assignAll(list);
    } catch (e, s) {
      Logger.print('FriendCache: Load friends failed - $e\n$s');
    }
  }

  Future<void> refreshFriends() async {
    await _loadFriends();
  }

  Future<void> _loadBlacklist() async {
    try {
      final list = await OpenIM.iMManager.friendshipManager.getBlacklist();
      blacklist.assignAll(list);
    } catch (e, s) {
      Logger.print('FriendCache: Load blacklist failed - $e\n$s');
    }
  }

  void blacklistAdded(BlacklistInfo u) {
    final exists = blacklist.any((e) => e.userID == u.userID || e.blockUserID == u.blockUserID);
    if (!exists) {
      blacklist.add(u);
    }
  }

  void blacklistDeleted(BlacklistInfo u) {
    blacklist.removeWhere((e) => e.userID == u.userID || e.blockUserID == u.blockUserID);
  }

  bool isBlacklist(String userID) {
    return blacklist.any((element) => element.userID == userID || element.blockUserID == userID);
  }

  void friendAdded(FriendInfo info) {
    final id = info.userID ?? info.friendUserID;
    if (id == null) return;
    final exists = friends.any((e) => e.userID == id || e.friendUserID == id);
    if (!exists) {
      friends.add(info);
    }
  }

  void friendDeleted(FriendInfo info) {
    final id = info.userID ?? info.friendUserID;
    if (id == null) return;
    friends.removeWhere((e) => e.userID == id || e.friendUserID == id);
  }

  void clearCache() {
    friends.clear();
    blacklist.clear();
    _isInitialized = false;
  }
}
