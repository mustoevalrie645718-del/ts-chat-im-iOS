import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';

import '../../../core/cache/friend_cache.dart';

class BlacklistLogic extends GetxController {
  final friendCache = Get.find<FriendCache>();

  List<BlacklistInfo> get blacklist => friendCache.blacklist;

  remove(BlacklistInfo info) async {
    await OpenIM.iMManager.friendshipManager.removeBlacklist(
      userID: info.userID!,
    );
  }
}
