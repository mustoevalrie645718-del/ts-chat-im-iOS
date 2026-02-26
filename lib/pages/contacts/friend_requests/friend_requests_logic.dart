import 'dart:async';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:openim/routes/app_navigator.dart';
import 'package:openim_common/openim_common.dart';
import 'package:pull_to_refresh_new/pull_to_refresh.dart';
import 'package:sprintf/sprintf.dart';

import '../../../core/cache/friend_applications_cache.dart';
import '../../../core/controller/im_controller.dart';
import '../../home/home_logic.dart';

class FriendRequestsLogic extends GetxController {
  final imLogic = Get.find<IMController>();
  final homeLogic = Get.find<HomeLogic>();
  final cache = Get.find<FriendApplicationsCache>();
  final applicationList = <FriendApplicationInfo>[].obs;
  late StreamSubscription faSub;

  int recipientOffset = 0;
  int applicantOffset = 0;
  int count = 100;

  final refreshController = RefreshController();

  @override
  void onInit() {
    faSub = imLogic.friendApplicationChangedSubject.listen((value) {
      // Load from cache when application changes
      _loadFromCache();
    });
    super.onInit();
  }

  @override
  void onReady() {
    // Load from cache first if available
    if (cache.isInitialized) {
      _loadFromCache();
    }

    // Then refresh data in background
    onRefresh();
    super.onReady();
  }

  @override
  void onClose() {
    faSub.cancel();
    homeLogic.getUnhandledFriendApplicationCount();
    super.onClose();
  }

  /// 获取好友申请列表
  Future<void> _getFriendRequestsList() async {
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

    if (list.length < count * 2) {
      refreshController.loadNoData();
    } else {
      (recipientOffset == 0 && applicantOffset == 0)
          ? refreshController.refreshCompleted()
          : refreshController.loadComplete();
    }

    final allList = <FriendApplicationInfo>[];
    allList
      ..addAll(list[0])
      ..addAll(list[1]);

    allList.sort((a, b) {
      if (a.createTime! > b.createTime!) {
        return -1;
      } else if (a.createTime! < b.createTime!) {
        return 1;
      }
      return 0;
    });

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

  void onRefresh() {
    recipientOffset = 0;
    applicantOffset = 0;
    _getFriendRequestsList();
  }

  void onLoadMore() {
    _getFriendRequestsList();
  }

  /// Load data from cache
  void _loadFromCache() {
    applicationList.assignAll(cache.applicationList);
  }

  bool isISendRequest(FriendApplicationInfo info) => info.fromUserID == OpenIM.iMManager.userID;

  /// 接受好友申请
  void acceptFriendApplication(FriendApplicationInfo info) => AppNavigator.startProcessFriendRequests(
        applicationInfo: info,
      );

  /// 拒绝好友申请
  void refuseFriendApplication(FriendApplicationInfo info) async {}

  void toChat(String userID) {
    OpenIM.iMManager.conversationManager
        .getOneConversation(sourceID: userID, sessionType: ConversationType.single)
        .then((value) {
      AppNavigator.startChat(
        offUntilHome: false,
        conversationInfo: value,
      );
    });
  }
}
