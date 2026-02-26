import 'dart:math';

import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

/// Cache service for friend applications
class FriendApplicationsCache extends GetxService {
  final applicationList = <FriendApplicationInfo>[].obs;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  int recipientOffset = 0;
  int applicantOffset = 0;
  final int count = 100;

  /// Preload friend applications data
  Future<void> preloadData() async {
    if (_isInitialized) {
      return;
    }

    try {
      await _loadApplicationList();
      _isInitialized = true;

      Logger.print('FriendApplicationsCache: Preload completed');
    } catch (e, s) {
      Logger.print('FriendApplicationsCache: Preload failed - $e\n$s');
    }
  }

  /// Load application list
  Future<void> _loadApplicationList() async {
    recipientOffset = 0;
    applicantOffset = 0;

    final list = await Future.wait([
      OpenIM.iMManager.friendshipManager.getFriendApplicationListAsRecipient(
        req: GetFriendApplicationListAsRecipientReq(offset: recipientOffset, count: count),
      ),
      OpenIM.iMManager.friendshipManager.getFriendApplicationListAsApplicant(
        req: GetFriendApplicationListAsApplicantReq(offset: applicantOffset, count: count),
      ),
    ]);

    recipientOffset += min(count, list[0].length);
    applicantOffset += min(count, list[1].length);

    final allList = <FriendApplicationInfo>[];
    allList
      ..addAll(list[0])
      ..addAll(list[1]);

    // Sort by createTime
    allList.sort((a, b) {
      if (a.createTime! > b.createTime!) {
        return -1;
      } else if (a.createTime! < b.createTime!) {
        return 1;
      }

      return 0;
    });

    // Mark as read
    var haveReadList = DataSp.getHaveReadUnHandleFriendApplication();
    haveReadList ??= <String>[];

    for (var e in list[0]) {
      var id = IMUtils.buildFriendApplicationID(e);

      if (!haveReadList.contains(id)) {
        haveReadList.add(id);
      }
    }
    DataSp.putHaveReadUnHandleFriendApplication(haveReadList);

    applicationList.assignAll(allList);
  }

  /// Refresh data (when application changed)
  Future<void> refreshData() async {
    try {
      await _loadApplicationList();

      Logger.print('FriendApplicationsCache: Refresh completed');
    } catch (e, s) {
      Logger.print('FriendApplicationsCache: Refresh failed - $e\n$s');
    }
  }

  /// Clear cache
  void clearCache() {
    applicationList.clear();
    recipientOffset = 0;
    applicantOffset = 0;
    _isInitialized = false;
  }
}
