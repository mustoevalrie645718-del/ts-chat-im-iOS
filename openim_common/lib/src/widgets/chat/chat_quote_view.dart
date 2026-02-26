import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:openim_common/openim_common.dart';

class ChatQuoteView extends StatelessWidget {
  const ChatQuoteView({
    Key? key,
    required this.quoteMsg,
    this.onTap,
    this.onTapLocate,
    this.popupMenuController,
  }) : super(key: key);
  final Message quoteMsg;
  final Function(Message message)? onTap;
  final Function(Message message)? onTapLocate;
  final CustomPopupMenuController? popupMenuController;

  @override
  Widget build(BuildContext context) => CopyCustomPopupMenu(
        controller: popupMenuController,
        menuBuilder: () => ChatLongPressMenu(
          popupMenuController: popupMenuController,
          adjustWidth: true,
          menus: [
            MenuInfo(
              text: StrRes.locateToOriginal,
              onTap: () => onTapLocate?.call(quoteMsg),
            ),
          ],
        ),
        pressType: PressType.longPress,
        arrowColor: Styles.c_0C1C33_opacity85,
        barrierColor: Colors.transparent,
        verticalMargin: 0,
        child: _ChatQuoteContentView(message: quoteMsg),
        onTap: () => onTap?.call(quoteMsg),
      );
}

class _ChatQuoteContentView extends StatelessWidget {
  const _ChatQuoteContentView({Key? key, required this.message}) : super(key: key);
  final Message message;

  final _decoder = const JsonDecoder();

  @override
  Widget build(BuildContext context) {
    String name = message.senderNickname ?? '';
    String? content;
    final atMap = <String, String>{};
    Widget? child;
    try {
      final textElem = message.textElem;
      if (message.isTextType) {
        content = textElem!.content;
      } else if (message.isAtTextType) {
        content = message.atTextElem?.text;
        message.atTextElem?.atUsersInfo?.forEach((element) {
          content = content?.replaceFirst(element.atUserID ?? "", element.groupNickname ?? "");
        });
      } else if (message.isPictureType) {
        final picture = message.pictureElem;
        if (null != picture && textElem == null) {
          final url1 = picture.snapshotPicture?.url;
          final url2 = picture.sourcePicture?.url;
          final url = url1 ?? url2;
          if (IMUtils.isUrlValid(url)) {
            child = ImageUtil.networkImage(
              url: url!,
              width: 32.w,
              height: 32.h,
              fit: BoxFit.cover,
              borderRadius: BorderRadius.circular(6.r),
            );
          }
        }
      } else if (message.isVideoType) {
        final video = message.videoElem;
        if (null != video && textElem == null) {
          child = Stack(
            alignment: Alignment.center,
            children: [
              ImageUtil.networkImage(
                url: video.snapshotUrl!,
                width: 32.w,
                height: 32.h,
                fit: BoxFit.cover,
                borderRadius: BorderRadius.circular(6.r),
              ),
              ImageRes.videoPause.toImage
                ..width = 12.w
                ..height = 12.h,
            ],
          );
        }
      } else if (message.isVoiceType) {
        content = '[${StrRes.voice}]';
      } else if (message.isCardType) {
        String name = message.cardElem!.nickname!;
        content = '[${StrRes.carte}]$name';
      } else if (message.isFileType) {
        final file = message.fileElem;
        if (null != file && textElem == null) {
          final name = file.fileName ?? '';
          final size = IMUtils.formatBytes(file.fileSize ?? 0);
          content = '$name($size)';
          child = IMUtils.fileIcon(name).toImage
            ..width = 26.w
            ..height = 30.h;
        }
      } else if (message.isLocationType) {
        final location = message.locationElem;
        if (null != location && textElem == null) {
          final map = _decoder.convert(location.description!);
          final url = map['url'];
          final name = map['name'];
          final addr = map['addr'];
          content = '[${StrRes.location}]$name($addr)';
          child = Stack(
            alignment: Alignment.center,
            children: [
              ImageUtil.networkImage(
                url: url!,
                width: 32.w,
                height: 32.h,
                fit: BoxFit.cover,
                borderRadius: BorderRadius.circular(6.r),
              ),
              FaIcon(
                FontAwesomeIcons.locationDot,
                size: 12.w,
                color: Styles.c_0089FF,
              ),
            ],
          );
        }
      } else if (message.isQuoteType) {
      } else if (message.isMergerType) {
        content = '[${StrRes.chatRecord}]';
      } else if (message.isCustomFaceType) {
        final face = message.faceElem;
        if (null != face && textElem == null) {
          final data = face.data;
          final map = jsonDecode(data!);
          final url = map['url'];
          final path = map['path'];

          if (path != null && File(path).existsSync()) {
            child = ImageUtil.fileImage(
              file: File(path),
              width: 32.w,
              height: 32.h,
              fit: BoxFit.cover,
              borderRadius: BorderRadius.circular(6.r),
            );
          } else if (IMUtils.isUrlValid(url)) {
            child = ImageUtil.networkImage(
              url: url!,
              width: 32.w,
              height: 32.h,
              fit: BoxFit.cover,
              borderRadius: BorderRadius.circular(6.r),
            );
          } else {
            content = '[${StrRes.emoji}]';
          }
        } else {
          content = '[${StrRes.emoji}]';
        }
      } else if (message.isCustomType) {
      } else if (message.isRevokeType) {
        content = StrRes.quoteContentBeRevoked;
      } else if (message.isNotificationType) {}

      if (textElem != null) {
        content = textElem.content;
      }
    } catch (e, s) {
      Logger.print('$e   $s');
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      margin: EdgeInsets.only(top: 4.h),
      constraints: BoxConstraints(maxWidth: maxWidth),
      decoration: BoxDecoration(
        color: Styles.c_F4F5F7,
        borderRadius: BorderRadius.circular(3.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth - 70.w),
            child: ChatText(
              text: '$name：${content ?? ''}'.fixAutoLines(),
              allAtMap: atMap,
              textStyle: Styles.ts_8E9AB0_14sp,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              patterns: [
                MatchPattern(
                  type: PatternType.at,
                  style: Styles.ts_8E9AB0_14sp,
                )
              ],
            ),
          ),
          if (null != child) child
        ],
      ),
    );
  }
}
