import 'dart:math';

import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

/// Cache service for group applications
class GroupApplicationsCache extends GetxService {
  final list = <GroupApplicationInfo>[].obs;
  final groupList = <String, GroupInfo>{}.obs;
  final memberList = <GroupMembersInfo>[].obs;
  final userInfoList = <UserInfo>[].obs;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  int recipientOffset = 0;
  int applicantOffset = 0;
  final int count = 100;

  /// Preload group applications data
  Future<void> preloadData() async {
    if (_isInitialized) {
      return;
    }

    try {
      await _loadApplicationList();
      await _loadJoinedGroups();
      _isInitialized = true;

      Logger.print('GroupApplicationsCache: Preload completed');
    } catch (e, s) {
      Logger.print('GroupApplicationsCache: Preload failed - $e\n$s');
    }
  }

  /// Load application list
  Future<void> _loadApplicationList() async {
    recipientOffset = 0;
    applicantOffset = 0;

    final apiList = await Future.wait([
      OpenIM.iMManager.groupManager.getGroupApplicationListAsRecipient(
        req: GetGroupApplicationListAsRecipientReq(offset: recipientOffset, count: count),
      ),
      OpenIM.iMManager.groupManager.getGroupApplicationListAsApplicant(
        req: GetGroupApplicationListAsApplicantReq(offset: applicantOffset, count: count),
      ),
    ]);

    recipientOffset += min(count, apiList[0].length);
    applicantOffset += min(count, apiList[1].length);

    final allList = <GroupApplicationInfo>[];
    allList
      ..addAll(apiList[0])
      ..addAll(apiList[1]);

    // Sort by reqTime
    allList.sort((a, b) {
      if (a.reqTime! > b.reqTime!) {
        return -1;
      } else if (a.reqTime! < b.reqTime!) {
        return 1;
      }

      return 0;
    });

    var map = <String, List<String>>{};
    var inviterList = <String>[];

    // Mark as read
    var haveReadList = DataSp.getHaveReadUnHandleGroupApplication();
    haveReadList ??= <String>[];

    for (var a in apiList[0]) {
      var id = IMUtils.buildGroupApplicationID(a);

      if (!haveReadList.contains(id)) {
        haveReadList.add(id);
      }
    }
    DataSp.putHaveReadUnHandleGroupApplication(haveReadList);

    // Record inviter IDs
    for (var a in allList) {
      if (_isInvite(a)) {
        if (!map.containsKey(a.groupID)) {
          map[a.groupID!] = [a.inviterUserID!];
        } else {
          if (!map[a.groupID!]!.contains(a.inviterUserID!)) {
            map[a.groupID!]!.add(a.inviterUserID!);
          }
        }

        if (!inviterList.contains(a.inviterUserID!)) {
          inviterList.add(a.inviterUserID!);
        }
      }
    }

    // Query inviter's group member info
    if (map.isNotEmpty) {
      final memberLists = await Future.wait(
        map.entries.map(
          (e) => OpenIM.iMManager.groupManager
              .getGroupMembersInfo(groupID: e.key, userIDList: e.value),
        ),
      );

      for (var members in memberLists) {
        memberList.addAll(members);
      }
    }

    // Query inviter's user info
    if (inviterList.isNotEmpty) {
      final users = await OpenIM.iMManager.userManager.getUsersInfo(userIDList: inviterList);
      userInfoList.assignAll(users.map((e) => e.simpleUserInfo).toList());
    }

    list.assignAll(allList);
  }

  /// Load joined groups
  Future<void> _loadJoinedGroups() async {
    final groups = await OpenIM.iMManager.groupManager.getJoinedGroupList();
    var map = <String, GroupInfo>{};

    for (var e in groups) {
      map[e.groupID] = e;
    }

    groupList.assignAll(map);
  }

  /// Refresh data (when application changed)
  Future<void> refreshData() async {
    try {
      await _loadApplicationList();

      Logger.print('GroupApplicationsCache: Refresh completed');
    } catch (e, s) {
      Logger.print('GroupApplicationsCache: Refresh failed - $e\n$s');
    }
  }

  /// Clear cache
  void clearCache() {
    list.clear();
    groupList.clear();
    memberList.clear();
    userInfoList.clear();
    recipientOffset = 0;
    applicantOffset = 0;
    _isInitialized = false;
  }

  bool _isInvite(GroupApplicationInfo info) {
    if (info.joinSource == 2) {
      return info.inviterUserID != null && info.inviterUserID!.isNotEmpty;
    }

    return false;
  }
}
