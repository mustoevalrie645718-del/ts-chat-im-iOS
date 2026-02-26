import 'dart:io';

import 'package:common_utils/common_utils.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:sprintf/sprintf.dart';
import 'package:url_launcher/url_launcher.dart';

import 'edit_announcement_logic.dart';

class GetViewEditGroupAnnouncementPage extends StatelessWidget {
  final logic = Get.find<EditGroupAnnouncementLogic>();

  GetViewEditGroupAnnouncementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => TouchCloseSoftKeyboard(
          child: Scaffold(
            appBar: TitleBar.back(
              title: StrRes.groupAc,
              right: logic.hasEditPermissions.value
                  ? ((logic.onlyRead.value ? StrRes.edit : StrRes.publish).toText
                    ..style = Styles.ts_0C1C33_17sp
                    ..onTap = (logic.onlyRead.value ? logic.editing : logic.publish))
                  : null,
            ),
            backgroundColor: Styles.c_F8F9FA,
            body: Container(
              margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              decoration: BoxDecoration(
                color: Styles.c_FFFFFF,
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if ((logic.updateMember.value.nickname)?.isNotEmpty == true)
                    Row(
                      children: [
                        AvatarView(
                          url: logic.updateMember.value.faceURL,
                          text: logic.updateMember.value.nickname,
                        ),
                        10.horizontalSpace,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            (logic.updateMember.value.nickname ?? '').toText,
                            sprintf(StrRes.updateOn, [
                              DateUtil.formatDateMs(
                                logic.groupInfo.value.notificationUpdateTime ?? 0,
                                format: Get.locale?.languageCode.toLowerCase() == 'zh'
                                    ? DateFormats.zh_mo_d_h_m
                                    : DateFormats.mo_d_h_m,
                              )
                            ]).toText
                              ..style = Styles.ts_8E9AB0_12sp,
                          ],
                        ),
                      ],
                    ),
                  Expanded(
                    child: logic.onlyRead.value
                        ? Padding(
                            padding: EdgeInsets.only(top: 10.h),
                            child: logic.inputCtrl.text.isEmpty && !logic.isLoading.value
                                ? Center(
                                    child: StrRes.noGroupAcYet.toText..style = Styles.ts_8E9AB0_17sp,
                                  )
                                : SelectableText.rich(
                                    _buildRichText(logic.inputCtrl.text),
                                    style: Styles.ts_0C1C33_17sp,
                                  ),
                          )
                        : TextField(
                            controller: logic.inputCtrl,
                            focusNode: logic.focusNode,
                            style: Styles.ts_0C1C33_17sp,
                            enabled: !logic.onlyRead.value,
                            expands: true,
                            maxLines: null,
                            minLines: null,
                            maxLength: 250,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: StrRes.plsEnterGroupAc,
                              hintStyle: Styles.ts_8E9AB0_17sp,
                              isDense: true,
                            ),
                          ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 30.w,
                        height: 1.h,
                        margin: EdgeInsets.only(right: 8.w),
                        color: Styles.c_E8EAEF,
                      ),
                      StrRes.groupAcPermissionTips.toText..style = Styles.ts_8E9AB0_12sp,
                      Container(
                        width: 30.w,
                        height: 1.h,
                        margin: EdgeInsets.only(left: 8.w),
                        color: Styles.c_E8EAEF,
                      ),
                    ],
                  ),
                  51.verticalSpace,
                ],
              ),
            ),
          ),
        ));
  }

  final RegExp _linkRegExp = RegExp(
    r"(https?://[a-zA-Z0-9-._~:/?#[\]@!$&\'()*+,;=]+)|(www\.[a-zA-Z0-9-._~:/?#[\]@!$&\'()*+,;=]+)|(\d+\.\d+\.\d+\.\d+)",
    caseSensitive: false,
  );

  TextSpan _buildRichText(String text) {
    final matches = _linkRegExp.allMatches(text);
    final List<TextSpan> spans = [];
    int lastEnd = 0;

    for (final match in matches) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, match.start)));
      }
      final link = match.group(0)!;
      String url = link;
      if (!link.startsWith('http')) {
        url = 'http://$link';
      }
      spans.add(TextSpan(
        text: link,
        style: const TextStyle(
          color: Colors.blue,
          decoration: TextDecoration.underline,
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () async {
            final uri = Uri.parse(url);

            if (await canLaunchUrl(uri)) {
              await launchUrl(uri);
            } else {
              print('Could not launch $url');
            }
          },
      ));
      lastEnd = match.end;
    }
    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd)));
    }
    return TextSpan(children: spans);
  }
}
