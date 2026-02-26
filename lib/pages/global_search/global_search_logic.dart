import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim/core/cache/friend_cache.dart';
import 'package:openim/routes/app_navigator.dart';
import 'package:openim_common/openim_common.dart';
import 'package:pull_to_refresh_new/pull_to_refresh.dart';

import '../conversation/conversation_logic.dart';

class GlobalSearchLogic extends CommonSearchLogic {
  final conversationLogic = Get.find<ConversationLogic>();
  final textMessageRefreshCtrl = RefreshController();
  final fileMessageRefreshCtrl = RefreshController();
  final contactsList = <dynamic>[].obs;
  final groupList = <GroupInfo>[].obs;
  final textSearchResultItems = <SearchResultItems>[].obs;

  // final fileSearchResultItems = <SearchResultItems>[].obs;
  final fileMessageList = <Message>[].obs;
  final index = 0.obs;
  final tabs = [
    StrRes.globalSearchAll,
    StrRes.globalSearchContacts,
    StrRes.globalSearchGroup,
    StrRes.globalSearchChatHistory,
    StrRes.globalSearchChatFile,
  ];

  int textMessagePageIndex = 1;
  int fileMessagePageIndex = 1;
  int count = 20;

  switchTab(int index) {
    this.index.value = index;
  }

  @override
  void clearList() {
    contactsList.clear();
    groupList.clear();
    textSearchResultItems.clear();
    fileMessageList.clear();
  }

  bool get isSearchNotResult =>
      searchKey.isNotEmpty &&
      contactsList.isEmpty &&
      groupList.isEmpty &&
      textSearchResultItems.isEmpty &&
      fileMessageList.isEmpty;

  search() async {
    final result = await LoadingView.singleton.wrap(
        asyncFunction: () => Future.wait([
              searchFriend(),
              searchGroup(),
              searchTextMessage(
                pageIndex: textMessagePageIndex = 1,
                count: count,
              ),
              searchFileMessage(
                pageIndex: fileMessagePageIndex = 1,
                count: count,
              ),
            ]));

    final friendList = (result[0] as List<FriendInfo>)
        .map((e) => UserInfo(userID: e.userID, nickname: e.nickname, faceURL: e.faceURL, remark: e.remark));
    final gList = result[1] as List<GroupInfo>;
    final textMessageResult = (result[2] as SearchResult).searchResultItems;
    final fileMessageResult = (result[3] as SearchResult).searchResultItems;
    clearList();

    contactsList.assignAll(friendList);
    groupList.assignAll(gList);
    textSearchResultItems.assignAll(textMessageResult ?? []);
    fileMessageList.clear();
    if (null != fileMessageResult && fileMessageResult.isNotEmpty) {
      for (var element in fileMessageResult) {
        fileMessageList.addAll(element.messageList!);
      }
    }
    if ((textMessageResult ?? []).length < count) {
      textMessageRefreshCtrl.loadNoData();
    } else {
      textMessageRefreshCtrl.loadComplete();
    }
    if ((fileMessageResult ?? []).length < count) {
      fileMessageRefreshCtrl.loadNoData();
    } else {
      fileMessageRefreshCtrl.loadComplete();
    }
  }

  void loadTextMessage() async {
    final result = await searchTextMessage(pageIndex: ++textMessagePageIndex, count: count);
    final textMessageResult = result.searchResultItems;
    textSearchResultItems.addAll(textMessageResult ?? []);
    if ((textMessageResult ?? []).length < count) {
      textMessageRefreshCtrl.loadNoData();
    } else {
      textMessageRefreshCtrl.loadComplete();
    }
  }

  void loadFileMessage() async {
    final result = await searchFileMessage(pageIndex: ++fileMessagePageIndex, count: count);
    final fileMessageResult = result.searchResultItems;
    if (null != fileMessageResult && fileMessageResult.isNotEmpty) {
      for (var element in fileMessageResult) {
        fileMessageList.addAll(element.messageList!);
      }
    }
    if ((fileMessageResult ?? []).length < count) {
      fileMessageRefreshCtrl.loadNoData();
    } else {
      fileMessageRefreshCtrl.loadComplete();
    }
  }

  /// 最多显示2条
  List<T> subList<T>(List<T> list) => list.sublist(0, list.length > 2 ? 2 : list.length).toList();

  String calContent(Message message) => IMUtils.calContent(
        content: IMUtils.parseMsg(message, replaceIdToNickname: true),
        key: searchKey,
        style: Styles.ts_8E9AB0_14sp,
        usedWidth: 80.w + 26.w,
      );

  void viewUserProfile(UserInfo info) => AppNavigator.startUserProfilePane(
        userID: info.userID!,
        nickname: info.nickname,
        faceURL: info.faceURL,
      );

  void viewFile(Message message) => IMUtils.previewFile(message);

  void viewGroup(GroupInfo groupInfo) {
    conversationLogic.toChat(
      groupID: groupInfo.groupID,
      nickname: groupInfo.groupName,
      faceURL: groupInfo.faceURL,
      sessionType: groupInfo.sessionType,
    );
  }

  void viewMessage(SearchResultItems item) {
    if (item.messageCount! > 1) {
      AppNavigator.startExpandChatHistory(
        searchResultItems: item,
        defaultSearchKey: searchKey,
      );
    } else {
      AppNavigator.startPreviewChatHistory(
        conversationInfo: ConversationInfo(
          conversationID: item.conversationID!,
          showName: item.showName,
          faceURL: item.faceURL,
        ),
        message: item.messageList!.first,
      );
    }
  }
}

abstract class CommonSearchLogic extends GetxController {
  final searchCtrl = TextEditingController();
  final focusNode = FocusNode();
  final FriendCache friendCache = Get.find<FriendCache>();

  void clearList();

  @override
  void onInit() {
    searchCtrl.addListener(_clearInput);
    super.onInit();
  }

  @override
  void onClose() {
    focusNode.dispose();
    searchCtrl.dispose();
    super.onClose();
  }

  _clearInput() {
    if (searchKey.isEmpty) {
      clearList();
    }
  }

  String get searchKey => searchCtrl.text.trim();

  Future<List<FriendInfo>> searchFriend() async {
    try {
      final results = await Future.wait([
        Apis.searchFriendInfo(searchCtrl.text.trim(), showNumber: 100000, showErrorToast: false)
            .then((list) => list.map((e) => FriendInfo.fromJson(e.toJson())).toList()),
        OpenIM.iMManager.friendshipManager.searchFriends(
          keywordList: [searchCtrl.text.trim()],
          isSearchNickname: true,
          isSearchRemark: true,
        ).then((imFriends) =>
            imFriends.where((e) => e.relationship == 1).map((e) => FriendInfo.fromJson(e.toJson())).toList()),
      ]);

      // Use results[1] (SDK searchFriends) as the base since it filters blacklisted users
      // Only include friends that exist in results[1]
      final imFriendsIds = results[1].map((e) => e.userID).whereType<String>().toSet();
      final allFriends = <String, FriendInfo>{};

      // Add API results only if they exist in imFriends (not blacklisted)
      for (final friend in results[0]) {
        if (friend.userID != null && imFriendsIds.contains(friend.userID)) {
          allFriends[friend.userID!] = friend;
        }
      }

      // Overwrite with imFriends results (which have remark info)
      for (final friend in results[1]) {
        if (friend.userID != null) {
          allFriends[friend.userID!] = friend;
        }
      }

      return allFriends.values.toList();
    } catch (e) {
      final imFriends = await OpenIM.iMManager.friendshipManager.searchFriends(
        keywordList: [searchCtrl.text.trim()],
        isSearchNickname: true,
        isSearchRemark: true,
      ).then((imFriends) => imFriends.map((e) => FriendInfo.fromJson(e.toJson())).toList());

      return imFriends;
    }
  }

  Future<List<GroupInfo>> searchGroup() => OpenIM.iMManager.groupManager
      .searchGroups(keywordList: [searchCtrl.text.trim()], isSearchGroupName: true, isSearchGroupID: true);

  Future<SearchResult> searchTextMessage({
   int pageIndex = 1,
    int count = 20,
  }) =>
      OpenIM.iMManager.messageManager.searchLocalMessages(
        keywordList: [searchKey],
        messageTypeList: [MessageType.text, MessageType.atText],
        pageIndex: pageIndex,
        count: count,
      );

  Future<SearchResult> searchFileMessage({
    int pageIndex = 1,
    int count = 20,
  }) =>
      OpenIM.iMManager.messageManager.searchLocalMessages(
        keywordList: [searchKey],
        messageTypeList: [MessageType.file],
        pageIndex: pageIndex,
        count: count,
      );

  String? parseID(e) {
    if (e is ConversationInfo) {
      return e.isSingleChat ? e.userID : e.groupID;
    } else if (e is GroupInfo) {
      return e.groupID;
    } else if (e is UserInfo) {
      return e.userID;
    } else if (e is FriendInfo) {
      return e.userID;
    } else {
      return null;
    }
  }

  String? parseNickname(e) {
    if (e is ConversationInfo) {
      return e.showName;
    } else if (e is GroupInfo) {
      return e.groupName;
    } else if (e is UserInfo) {
      return e.nickname;
    } else if (e is FriendInfo) {
      return e.nickname;
    } else {
      return null;
    }
  }

  String? parseFaceURL(e) {
    if (e is ConversationInfo) {
      return e.faceURL;
    } else if (e is GroupInfo) {
      return e.faceURL;
    } else if (e is UserInfo) {
      return e.faceURL;
    } else if (e is FriendInfo) {
      return e.faceURL;
    } else {
      return null;
    }
  }

  String? parseDeptDetailInfo(info) {
    return null;
  }

  String? parsePosition(info) {
    return null;
  }
}
