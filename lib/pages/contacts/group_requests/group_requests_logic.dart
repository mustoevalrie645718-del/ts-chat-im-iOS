import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:openim/routes/app_navigator.dart';
import 'package:openim_common/openim_common.dart';
import 'package:pull_to_refresh_new/pull_to_refresh.dart';
import 'package:sprintf/sprintf.dart';

import '../../../core/cache/group_applications_cache.dart';
import '../../../core/controller/im_controller.dart';
import '../../home/home_logic.dart';

class GroupRequestsLogic extends GetxController {
  final imLogic = Get.find<IMController>();
  final homeLogic = Get.find<HomeLogic>();
  final cache = Get.find<GroupApplicationsCache>();
  final list = <GroupApplicationInfo>[].obs;
  final groupList = <String, GroupInfo>{}.obs;
  final memberList = <GroupMembersInfo>[].obs;
  final userInfoList = <UserInfo>[].obs;

  int recipientOffset = 0;
  int applicantOffset = 0;
  int count = 100;

  final refreshController = RefreshController();

  @override
  void onReady() {
    // Load from cache first if available
    if (cache.isInitialized) {
      _loadFromCache();
    }

    // Then refresh data in background
    getApplicationList();
    getJoinedGroup();
    super.onReady();
  }

  @override
  void onInit() {
    imLogic.groupApplicationChangedSubject.listen((info) {
      // Load from cache when application changes
      _loadFromCache();
    });
    super.onInit();
  }

  @override
  void onClose() {
    homeLogic.getUnhandledGroupApplicationCount();
    super.onClose();
  }

  bool isInvite(GroupApplicationInfo info) {
    if (info.joinSource == 2) {
      return info.inviterUserID != null && info.inviterUserID!.isNotEmpty;
    }
    return false;
  }

  Future getApplicationListHelper() async {
    final list = await Future.wait([
      OpenIM.iMManager.groupManager.getGroupApplicationListAsRecipient(
        req: GetGroupApplicationListAsRecipientReq(offset: recipientOffset, count: count),
      ),
      OpenIM.iMManager.groupManager.getGroupApplicationListAsApplicant(
        req: GetGroupApplicationListAsApplicantReq(offset: applicantOffset, count: count),
      ),
    ]);

    recipientOffset += min(count, list[0].length);
    applicantOffset += min(count, list[1].length);

    if (refreshController.isRefresh) {
      refreshController.refreshCompleted();
    }
    if (list[0].length < count && list[1].length < count) {
      refreshController.loadNoData();
    } else {
      refreshController.loadComplete();
    }

    final allList = <GroupApplicationInfo>[];
    allList
      ..addAll(list[0])
      ..addAll(list[1]);

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
    // 统计未查看的群申请数量
    var haveReadList = DataSp.getHaveReadUnHandleGroupApplication();
    haveReadList ??= <String>[];
    for (var a in list[0]) {
      var id = IMUtils.buildGroupApplicationID(a);
      if (!haveReadList.contains(id)) {
        haveReadList.add(id);
      }
    }
    DataSp.putHaveReadUnHandleGroupApplication(haveReadList);

    // 记录邀请者id
    for (var a in allList) {
      if (isInvite(a)) {
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

    // 查询邀请者的群成员信息
    if (map.isNotEmpty) {
      await Future.wait(map.entries.map((e) => OpenIM.iMManager.groupManager
          .getGroupMembersInfo(groupID: e.key, userIDList: e.value)
          .then((list) => memberList.assignAll(list))));
      // await Future.forEach<MapEntry>(map.entries, (element) {
      //   OpenIM.iMManager.groupManager
      //       .getGroupMembersInfo(groupId: element.key, uidList: element.value)
      //       .then((list) => memberList.assignAll(list));
      // });
    }

    // 查询邀请者的用户信息
    if (inviterList.isNotEmpty) {
      await OpenIM.iMManager.userManager
          .getUsersInfo(userIDList: inviterList)
          .then((list) => userInfoList.assignAll(list.map((e) => e.simpleUserInfo).toList()));
    }

    return allList;
  }

  Future<void> getApplicationList({bool withLoading = true}) async {
    final list = await getApplicationListHelper();

    // list.sort((a, b) {
    //   if (a.createTime! > b.createTime!) {
    //     return -1;
    //   } else if (a.createTime! < b.createTime!) {
    //     return 1;
    //   }
    //   return 0;
    // });
    this.list.assignAll(list);
  }

  void onRefresh() {
    recipientOffset = 0;
    applicantOffset = 0;
    getApplicationList();
  }

  void onLoadMore() {
    getApplicationList();
  }

  void getJoinedGroup() {
    OpenIM.iMManager.groupManager.getJoinedGroupList().then((list) {
      var map = <String, GroupInfo>{};
      for (var e in list) {
        map[e.groupID] = e;
      }
      groupList.addAll(map);
    });
  }

  String getGroupName(GroupApplicationInfo info) => info.groupName ?? groupList[info.groupID]?.groupName ?? '';

  String getInviterNickname(GroupApplicationInfo info) =>
      (getMemberInfo(info.inviterUserID!)?.nickname) ?? (getUserInfo(info.inviterUserID!)?.nickname) ?? '-';

  GroupMembersInfo? getMemberInfo(inviterUserID) => memberList.firstWhereOrNull((e) => e.userID == inviterUserID);

  UserInfo? getUserInfo(inviterUserID) => userInfoList.firstWhereOrNull((e) => e.userID == inviterUserID);

  void handle(GroupApplicationInfo info) async {
    var result = await AppNavigator.startProcessGroupRequests(applicationInfo: info);
    if (result is int) {
      info.handleResult = result;
      list.refresh();
    }
    // var result = await AppNavigator.startHandleGroupApplication(
    //   groupList[info.groupID]!,
    //   info,
    // );
    // if (result is int) {
    //   info.handleResult = result;
    //   list.refresh();
    // }
  }

  /// Load data from cache
  void _loadFromCache() {
    list.assignAll(cache.list);
    groupList.assignAll(cache.groupList);
    memberList.assignAll(cache.memberList);
    userInfoList.assignAll(cache.userInfoList);
  }
}
