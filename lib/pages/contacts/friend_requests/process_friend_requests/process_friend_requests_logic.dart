import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

import '../../../../core/cache/friend_applications_cache.dart';
import '../friend_requests_logic.dart';

class ProcessFriendRequestsLogic extends GetxController {
  final cache = Get.find<FriendApplicationsCache>();
  final friendRequestsLogic = Get.find<FriendRequestsLogic>();
  late FriendApplicationInfo applicationInfo;

  @override
  void onInit() {
    applicationInfo = Get.arguments['applicationInfo'];
    DataSp.putHaveReadUnHandleFriendApplicationTime();
    super.onInit();
  }

  /// 接受好友申请
  void acceptFriendApplication() async {
    LoadingView.singleton
        .wrap(
            asyncFunction: () =>
                OpenIM.iMManager.friendshipManager.acceptFriendApplication(userID: applicationInfo.fromUserID!))
        .then(_addSuccessfully)
        .catchError((_) => IMViews.showToast(StrRes.addFailed));
  }

  /// 拒绝好友申请
  void refuseFriendApplication() async {
    LoadingView.singleton
        .wrap(
            asyncFunction: () =>
                OpenIM.iMManager.friendshipManager.refuseFriendApplication(userID: applicationInfo.fromUserID!))
        .then(_rejectSuccessfully)
        .catchError((_) => IMViews.showToast(StrRes.rejectFailed));
  }

  _addSuccessfully(_) async {
    IMViews.showToast(StrRes.addSuccessfully);
    // Refresh cache after successful acceptance
    await cache.refreshData();
    // Update list from cache
    friendRequestsLogic.onRefresh();
    Get.back(result: 1);
    return _;
  }

  _rejectSuccessfully(_) async {
    IMViews.showToast(StrRes.rejectSuccessfully);
    // Refresh cache after successful rejection
    await cache.refreshData();
    // Update list from cache
    friendRequestsLogic.onRefresh();
    Get.back(result: -1);
    return _;
  }
}
