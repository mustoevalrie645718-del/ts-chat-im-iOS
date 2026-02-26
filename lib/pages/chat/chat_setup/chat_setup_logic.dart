import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:openim/pages/chat/chat_setup/search_chat_history/multimedia/multimedia_logic.dart';
import 'package:openim_common/openim_common.dart';
import 'package:sprintf/sprintf.dart';

import '../../../core/controller/app_controller.dart';
import '../../../core/controller/im_controller.dart';
import '../../../routes/app_navigator.dart';
import '../chat_logic.dart';

class ChatSetupLogic extends GetxController {
  // final chatLogic = Get.find<ChatLogic>();
  final chatLogic = Get.find<ChatLogic>(tag: GetTags.chat);
  final appLogic = Get.find<AppController>();
  final imLogic = Get.find<IMController>();
  late Rx<ConversationInfo> conversationInfo;
  late StreamSubscription ccSub;
  late StreamSubscription fcSub;

  String get conversationID => conversationInfo.value.conversationID;

  bool get isPinned => conversationInfo.value.isPinned == true;

  bool get isBurnAfterReading => conversationInfo.value.isPrivateChat == true;

  bool get isMsgDestruct => conversationInfo.value.isMsgDestruct == true;

  bool get isNotDisturb => conversationInfo.value.recvMsgOpt != 0;

  int get burnDuration => conversationInfo.value.burnDuration ?? 30;

  int get destructDuration =>
      conversationInfo.value.msgDestructTime ?? 7 * 24 * 60 * 60;

  String get getBurnAfterReadingDurationStr {
    int day = 1 * 24 * 60 * 60;
    int hour = 1 * 60 * 60;
    int fiveMinutes = 5 * 60;
    if (burnDuration == day) {
      return StrRes.oneDay;
    } else if (burnDuration == hour) {
      return StrRes.oneHour;
    } else if (burnDuration == fiveMinutes) {
      return StrRes.fiveMinutes;
    } else {
      return StrRes.thirtySeconds;
    }
  }

  String get getDestructDurationStr {
    int day = 1 * 24 * 60 * 60;
    int week = 7 * day;
    int month = 1 * 30 * day;
    if (destructDuration % month == 0) {
      return sprintf(StrRes.nMonth, [destructDuration ~/ month]);
    } else if (destructDuration % week == 0) {
      return sprintf(StrRes.nWeek, [destructDuration ~/ week]);
    } else {
      return sprintf(StrRes.nDay, [destructDuration ~/ day]);
    }
  }

  @override
  void onClose() {
    ccSub.cancel();
    fcSub.cancel();
    super.onClose();
  }

  @override
  void onInit() {
    conversationInfo = Rx(Get.arguments['conversationInfo']);
    final sourceID =
        conversationInfo.value.conversationType == ConversationType.single
            ? conversationInfo.value.userID
            : conversationInfo.value.groupID;
    OpenIM.iMManager.conversationManager
        .getOneConversation(
            sourceID: sourceID!,
            sessionType: conversationInfo.value.conversationType!)
        .then((value) {
      conversationInfo.value = value;
    });

    ccSub = imLogic.conversationChangedSubject.listen((newList) {
      for (var newValue in newList) {
        if (newValue.conversationID == conversationID) {
          conversationInfo.update((val) {
            val?.burnDuration = newValue.burnDuration ?? 30;
            val?.isPrivateChat = newValue.isPrivateChat;
            val?.isPinned = newValue.isPinned;
            // 免打扰 0：正常；1：不接受消息；2：接受在线消息不接受离线消息；
            val?.recvMsgOpt = newValue.recvMsgOpt;
            val?.isMsgDestruct = newValue.isMsgDestruct;
            val?.msgDestructTime = newValue.msgDestructTime;
            val?.showName = newValue.showName;
          });
          break;
        }
      }
    });
    // 好友信息变化
    fcSub = imLogic.friendInfoChangedSubject.listen((value) {
      if (conversationInfo.value.userID == value.userID) {
        conversationInfo.update((val) {
          val?.showName = value.getShowName();
          val?.faceURL = value.faceURL;
        });
      }
    });
    super.onInit();
  }

  void toggleTopContacts() async {
    await LoadingView.singleton.wrap(
      asyncFunction: () => OpenIM.iMManager.conversationManager.pinConversation(
        conversationID: conversationID,
        isPinned: !isPinned,
      ),
    );
  }

  /// 消息免打扰 0：正常；1：不接受消息；2：接受在线消息不接受离线消息；
  void toggleNotDisturb() {
    LoadingView.singleton.wrap(
        asyncFunction: () =>
            OpenIM.iMManager.conversationManager.setConversationRecvMessageOpt(
              conversationID: conversationID,
              status: !isNotDisturb ? 2 : 0,
            ));
  }
  
  void clearChatHistory() async {
    var confirm = await Get.dialog(CustomDialog(
      title: StrRes.confirmClearChatHistory,
      rightText: StrRes.confirm,
    ));
    if (confirm == true) {
      await LoadingView.singleton.wrap(
        asyncFunction: () => OpenIM.iMManager.conversationManager
            .clearConversationAndDeleteAllMsg(
          conversationID: conversationID,
        ),
      );
      chatLogic.clearAllMessage();
      IMViews.showToast(StrRes.clearSuccessfully);
    }
  }

  void createGroup() => AppNavigator.startCreateGroup(defaultCheckedList: [
        UserInfo(
          userID: conversationInfo.value.userID,
          faceURL: conversationInfo.value.faceURL,
          nickname: conversationInfo.value.showName,
        ),
        OpenIM.iMManager.userInfo,
      ]);

  void setFontSize() => AppNavigator.startSetFontSize();

  void setBackgroundImage() => AppNavigator.startSetBackgroundImage();

  void searchChatHistory() => AppNavigator.startSearchChatHistory(
        conversationInfo: conversationInfo.value,
      );

  void searchChatHistoryPicture() =>
      AppNavigator.startSearchChatHistoryMultimedia(
        conversationInfo: conversationInfo.value,
      );

  void searchChatHistoryVideo() =>
      AppNavigator.startSearchChatHistoryMultimedia(
        conversationInfo: conversationInfo.value,
        multimediaType: MultimediaType.video,
      );

  void searchChatHistoryFile() => AppNavigator.startSearchChatHistoryFile(
        conversationInfo: conversationInfo.value,
      );

  void viewUserInfo() => AppNavigator.startUserProfilePane(
        userID: conversationInfo.value.userID!,
        nickname: conversationInfo.value.showName,
        faceURL: conversationInfo.value.faceURL,
      );
}
