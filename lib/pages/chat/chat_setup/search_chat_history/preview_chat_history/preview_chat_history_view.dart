import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

import 'preview_chat_history_logic.dart';

class PreviewChatHistoryPage extends StatelessWidget {
  final logic = Get.find<PreviewChatHistoryLogic>();

  PreviewChatHistoryPage({super.key});

  void handleUserProfileTap(
      ({String userID, String name, String? faceURL, String? groupID}) userProfile) {}

  Widget _buildItemView(Message message) => ChatItemView(
        // isBubbleMsg: logic.showBubbleBg(message),
        message: message,
        highlightColor: message == logic.searchMessage ? Styles.c_8E9AB0_opacity13 : null,
        timelineStr: logic.getShowTime(message),
        enabledReadStatus: false,
        rightNickname: OpenIM.iMManager.userInfo.nickname,
        rightFaceUrl: OpenIM.iMManager.userInfo.faceURL,
        enabledCopyMenu: message.contentType == MessageType.text ||
            message.contentType == MessageType.atText ||
            message.contentType == MessageType.quote,
        enabledRevokeMenu: false,
        enabledReplyMenu: false,
        enabledMultiMenu: false,
        enabledForwardMenu: false,
        enabledDelMenu: false,
        enabledAddEmojiMenu: false,
        onClickItemView: () => logic.parseClickEvent(message),
        onTapCopyMenu: () => logic.copy(message),
        onTapQuoteMessage: (Message message) {
          logic.onTapQuoteMsg(message);
        },
        onTapLeftAvatar: () => logic.onTapLeftAvatar(message),
        onTapRightAvatar: () => logic.onTapRightAvatar(),
        onVisibleTrulyText: (text) {
          logic.copyTextMap[message.clientMsgID] = text;
        },
        customTypeBuilder: _buildCustomTypeItemView,
        patterns: <MatchPattern>[
          MatchPattern(
            type: PatternType.at,
          ),
          MatchPattern(
            type: PatternType.email,
          ),
          MatchPattern(
            type: PatternType.url,
          ),
          MatchPattern(
            type: PatternType.mobile,
          ),
          MatchPattern(
            type: PatternType.tel,
          ),
        ],
        onTapUserProfile: handleUserProfileTap,
      );

  CustomTypeInfo? _buildCustomTypeItemView(_, Message message) {
    final data = IMUtils.parseCustomMessage(message);
    if (null != data) {
      final viewType = data['viewType'];
      if (viewType == CustomMessageType.deletedByFriend ||
          viewType == CustomMessageType.blockedByFriend) {
        final view = ChatFriendRelationshipAbnormalHintView(
          name: logic.conversationInfo.showName ?? '',
          blockedByFriend: viewType == CustomMessageType.blockedByFriend,
          deletedByFriend: viewType == CustomMessageType.deletedByFriend,
        );
        return CustomTypeInfo(view, false, false);
      } else if (viewType == CustomMessageType.removedFromGroup) {
        return CustomTypeInfo(
          StrRes.removedFromGroupHint.toText..style = Styles.ts_8E9AB0_12sp,
          false,
          false,
        );
      } else if (viewType == CustomMessageType.groupDisbanded) {
        return CustomTypeInfo(
          StrRes.groupDisbanded.toText..style = Styles.ts_8E9AB0_12sp,
          false,
          false,
        );
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleBar.back(title: logic.conversationInfo.showName),
      body: CustomChatListView(
        scrollController: logic.scrollController,
        onScrollToTopLoad: logic.scrollToTopLoad,
        onScrollToBottomLoad: logic.scrollToBottomLoad,
        enabledBottomLoad: true,
        enabledTopLoad: true,
        itemBuilder: (BuildContext context, int index, int position, data) {
          return Padding(
            padding: EdgeInsets.only(top: 10.h),
            child: _buildItemView(data),
          );
        },
        controller: logic.controller,
      ),
    );
  }
}
