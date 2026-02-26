import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

class TitleBar extends StatelessWidget implements PreferredSizeWidget {
  const TitleBar({
    Key? key,
    this.height,
    this.left,
    this.center,
    this.right,
    this.backgroundColor,
    this.showUnderline = false,
  }) : super(key: key);
  final double? height;
  final Widget? left;
  final Widget? center;
  final Widget? right;
  final Color? backgroundColor;
  final bool showUnderline;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Container(
        color: backgroundColor ?? Styles.c_FFFFFF,
        padding: EdgeInsets.only(top: mq.padding.top),
        child: Container(
          height: height,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: showUnderline
              ? BoxDecoration(
                  border: BorderDirectional(
                    bottom: BorderSide(color: Styles.c_E8EAEF, width: .5),
                  ),
                )
              : null,
          child: Row(
            children: [
              if (null != left) left!,
              if (null != center) center!,
              if (null != right) right!,
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height ?? 44.h);

  TitleBar.conversation(
      {super.key,
      String? statusStr,
      bool isFailed = false,
      Function()? onClickCallBtn,
      Function()? onScan,
      Function()? onAddFriend,
      Function()? onAddGroup,
      Function()? onCreateGroup,
      Function()? onVideoMeeting,
      CustomPopupMenuController? popCtrl,
      this.left})
      : backgroundColor = null,
        height = 62.h,
        showUnderline = false,
        center = null,
        right = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: onClickCallBtn,
              child: Icon(
                CupertinoIcons.phone,
                size: 28.w,
                color: Styles.c_0C1C33,
              ),
            ),
            16.horizontalSpace,
            PopButton(
              popCtrl: popCtrl,
              menus: [
                PopMenuInfo(
                  text: StrRes.scan,
                  icon: ImageRes.popMenuScan,
                  onTap: onScan,
                ),
                PopMenuInfo(
                  text: StrRes.addFriend,
                  icon: ImageRes.popMenuAddFriend,
                  onTap: onAddFriend,
                ),
                PopMenuInfo(
                  text: StrRes.addGroup,
                  icon: ImageRes.popMenuAddGroup,
                  onTap: onAddGroup,
                ),
                PopMenuInfo(
                  text: StrRes.createGroup,
                  icon: ImageRes.popMenuCreateGroup,
                  onTap: onCreateGroup,
                ),
                if (onVideoMeeting != null)
                  PopMenuInfo(
                    text: StrRes.videoMeeting,
                    icon: ImageRes.popMenuVideoMeeting,
                    onTap: onVideoMeeting,
                  ),
              ],
              child: Icon(
                CupertinoIcons.add,
                size: 28.w,
                color: Styles.c_0C1C33,
              ),
            ),
          ],
        );

  TitleBar.chat({
    super.key,
    String? title,
    String? member,
    String? subTitle,
    bool showOnlineStatus = false,
    bool isOnline = false,
    bool isMultiModel = false,
    bool showCallBtn = true,
    bool isMuted = false,
    int unreadMsgCount = 0,
    Function()? onClickCallBtn,
    Function()? onClickMoreBtn,
    Function()? onCloseMultiModel,
  })  : backgroundColor = null,
        height = 48.h,
        showUnderline = true,
        // Left button - fixed width to ensure full visibility
        left = SizedBox(
            child: isMultiModel
                ? (StrRes.cancel.toText
                  ..style = Styles.ts_0C1C33_17sp
                  ..onTap = onCloseMultiModel)
                : GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () => Get.back(),
                    child: unreadMsgCount > 0
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                CupertinoIcons.back,
                                size: 24.w,
                                color: Styles.c_0C1C33,
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 4.w),
                                decoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  color: CupertinoColors.systemGrey3,
                                  borderRadius: BorderRadius.circular(12.w),
                                ),
                                child: (unreadMsgCount > 99 ? '99+' : unreadMsgCount.toString()).toText
                                  ..style = Styles.ts_0C1C33_12sp_medium,
                              ),
                            ],
                          )
                        : Icon(
                            CupertinoIcons.back,
                            size: 24.w,
                            color: Styles.c_0C1C33,
                          ),
                  )),
        // Center content - takes remaining space with constraints
        center = Expanded(
            child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (null != title)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                        child: title.trim().toText
                          ..style = Styles.ts_0C1C33_17sp_semibold
                          ..maxLines = 1
                          ..overflow = TextOverflow.ellipsis
                          ..textAlign = TextAlign.center),
                    if (null != member)
                      Padding(
                        padding: EdgeInsets.only(left: 4.w),
                        child: member.toText
                          ..style = Styles.ts_0C1C33_17sp_semibold
                          ..maxLines = 1,
                      )
                  ],
                ),
              if (subTitle?.isNotEmpty == true)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (showOnlineStatus)
                      Container(
                        width: 6.w,
                        height: 6.h,
                        margin: EdgeInsets.only(right: 4.w),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isOnline ? Styles.c_18E875 : Styles.c_8E9AB0,
                        ),
                      ),
                    Flexible(
                      child: subTitle!.toText
                        ..style = Styles.ts_8E9AB0_10sp
                        ..maxLines = 1
                        ..overflow = TextOverflow.ellipsis,
                    ),
                  ],
                ),
            ],
          ),
        )),
        // Right buttons - fixed width to ensure full visibility
        right = SizedBox(
            width: 16.w + (showCallBtn ? 56.w : 28.w),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (showCallBtn)
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: isMuted ? null : onClickCallBtn,
                    child: Icon(
                      CupertinoIcons.phone,
                      size: 28.w,
                      color: Styles.c_0C1C33.withOpacity(isMuted ? 0.4 : 1),
                    ),
                  ),
                16.horizontalSpace,
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: onClickMoreBtn,
                  child: Icon(
                    CupertinoIcons.ellipsis,
                    size: 28.w,
                    color: Styles.c_0C1C33,
                  ),
                ),
              ],
            ));

  TitleBar.back({
    super.key,
    String? title,
    String? leftTitle,
    TextStyle? titleStyle,
    TextStyle? leftTitleStyle,
    String? result,
    Color? backgroundColor,
    Color? backIconColor,
    this.right,
    this.showUnderline = false,
    Function()? onTap,
  })  : height = 44.h,
        backgroundColor = backgroundColor ?? Styles.c_FFFFFF,
        center = Expanded(
            child: (title ?? '').toText
              ..style = (titleStyle ?? Styles.ts_0C1C33_15sp_semibold)
              ..textAlign = TextAlign.center
              ..maxLines = 2
              ..overflow = TextOverflow.ellipsis),
        left = GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: onTap ?? (() => Get.back(result: result)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                CupertinoIcons.back,
                size: 24.w,
                color: backIconColor ?? Styles.c_0C1C33,
              ),
              if (null != leftTitle) leftTitle.toText..style = (leftTitleStyle ?? Styles.ts_0C1C33_17sp_semibold),
            ],
          ),
        );

  TitleBar.contacts({
    super.key,
    this.showUnderline = false,
    Function()? onClickSearch,
    Function()? onClickAddContacts,
  })  : height = 44.h,
        backgroundColor = Styles.c_FFFFFF,
        center = Spacer(),
        left = StrRes.contacts.toText..style = Styles.ts_0C1C33_20sp_semibold,
        right = Row(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: onClickSearch,
              child: Icon(
                CupertinoIcons.search,
                size: 28.w,
                color: Styles.c_0C1C33,
              ),
            ),
            16.horizontalSpace,
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: onClickAddContacts,
              child: Icon(
                CupertinoIcons.person_add,
                size: 28.w,
                color: Styles.c_0C1C33,
              ),
            ),
          ],
        );

  TitleBar.workbench({
    super.key,
    this.showUnderline = false,
  })  : height = 44.h,
        backgroundColor = Styles.c_FFFFFF,
        center = null,
        left = StrRes.workbench.toText..style = Styles.ts_0C1C33_20sp_semibold,
        right = null;

  TitleBar.search({
    super.key,
    String? hintText,
    TextEditingController? controller,
    FocusNode? focusNode,
    bool autofocus = true,
    Function(String)? onSubmitted,
    Function()? onCleared,
    ValueChanged<String>? onChanged,
  })  : height = 44.h,
        backgroundColor = Styles.c_FFFFFF,
        center = Expanded(
          child: Container(
              child: SearchBox(
            enabled: true,
            autofocus: autofocus,
            hintText: hintText,
            controller: controller,
            focusNode: focusNode,
            onSubmitted: onSubmitted,
            onCleared: onCleared,
            onChanged: onChanged,
          )),
        ),
        showUnderline = true,
        right = null,
        left = GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => Get.back(),
          child: Icon(
            CupertinoIcons.back,
            size: 24.w,
            color: Styles.c_0C1C33,
          ),
        );
}
