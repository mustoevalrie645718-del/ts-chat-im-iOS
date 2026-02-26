import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

import 'set_font_size_logic.dart';

class SetKkxFontSizePage extends StatelessWidget {
  final logic = Get.find<SetFontSizeLogic>();

  SetKkxFontSizePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleBar.back(
        title: StrRes.fontSize,
        right: StrRes.save.toText
          ..onTap = () async {
            await logic.saveFactor();
            Get.back();
          },
      ),
      backgroundColor: Styles.c_F8F9FA,
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 22.w, vertical: 42.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    '16:09'.toText..style = Styles.ts_8E9AB0_12sp,
                    ChatBubble(
                      bubbleType: BubbleType.send,
                      alignment: null,
                      constraints: BoxConstraints(maxWidth: maxWidth),
                      child: Obx(() => StrRes.previewFontSizeHint.toText
                        ..style = Styles.ts_0C1C33_17sp
                        ..textScaleFactor = logic.factor.value),
                    )
                  ],
                ),
                10.horizontalSpace,
                AvatarView(
                  text: logic.userInfo.nickname,
                  url: logic.userInfo.faceURL,
                ),
              ],
            ),
          ),
          const Spacer(),
          Obx(() => FontSizeSlider(
                value: logic.factor.value,
                onChanged: logic.changed,
              )),
        ],
      ),
    );
  }
}
