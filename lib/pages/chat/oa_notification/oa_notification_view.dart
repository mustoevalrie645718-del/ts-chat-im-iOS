import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:pull_to_refresh_new/pull_to_refresh.dart';
import 'package:url_launcher/url_launcher.dart';

import 'oa_notification_logic.dart';

class LivOANotificationPage extends StatelessWidget {
  final logic = Get.find<OANotificationLogic>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleBar.back(
        title: logic.info.showName,
      ),
      backgroundColor: Styles.c_F8F9FA,
      body: Obx(() => SmartRefresher(
            controller: logic.refreshController,
            header: IMViews.buildHeader(),
            footer: IMViews.buildFooter(),
            enablePullDown: false,
            enablePullUp: true,
            onLoading: () => logic.loadNotification(),
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 22.w),
              itemCount: logic.messageList.length,
              shrinkWrap: true,
              itemBuilder: (_, index) {
                final message = logic.messageList.reversed.elementAt(index);
                return _buildItemView(index, message, logic.parse(message));
              },
            ),
          )),
    );
  }

  Widget _buildItemView(int index, Message message, OANotification oa) => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 15.h,
          ),
          Text(
            IMUtils.getChatTimeline(message.sendTime!),
            style: Styles.ts_8E9AB0_10sp,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AvatarView(
                url: oa.notificationFaceURL,
                text: oa.notificationName,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(oa.notificationName!, style: Styles.ts_0C1C33_14sp),
                    GestureDetector(
                      onTap: oa.externalUrl == null
                          ? null
                          : () async {
                              String url = oa.externalUrl!;

                              if (!url.contains('://')) {
                                url = 'https://$url';
                              }
                              final uri = Uri.parse(url);
                              final canLunch = await canLaunchUrl(uri);

                              if (canLunch) {
                                launchUrl(uri);
                              }
                            },
                      behavior: HitTestBehavior.translucent,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: 100.h),
                        child: Container(
                          margin: EdgeInsets.only(top: 8.h),
                          width: locationWidth,
                          decoration: BoxDecoration(
                            color: Styles.c_FFFFFF,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                oa.notificationName!,
                                style: Styles.ts_8E9AB0_14sp,
                              ),
                              const SizedBox(height: 4),
                              Divider(
                                height: 1,
                                color: Styles.c_E8EAEF,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                oa.text!,
                                style: Styles.ts_8E9AB0_12sp,
                              ),
                              if (oa.mixType == 1 || oa.mixType == 2 || oa.mixType == 3)
                                Container(
                                  margin: EdgeInsets.only(top: 12.h),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (oa.mixType == 1) _buildPictureView(message, oa, index),
                                      if (oa.mixType == 2) _buildVideoerView(message, oa, index),
                                      if (oa.mixType == 3) _buildFileView(message, oa, index),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ],
      );

  Widget _buildPictureView(Message message, OANotification oa, int index) => ChatPictureView(
        message: message..pictureElem = oa.pictureElem,
        isISend: false,
      );

  Widget _buildVideoerView(Message message, OANotification oa, int index) => GestureDetector(
        onTap: () {
          IMUtils.previewMediaFile(
            context: Get.context!,
            currentIndex: 0,
            mediaMessages: [message],
            onAutoPlay: (p0) => true,
            onlySave: true,
          );
        },
        child: ChatVideoView(
          message: message..videoElem = oa.videoElem,
          isISend: false,
        ),
      );

  Widget _buildFileView(Message message, OANotification oa, int index) => GestureDetector(
        onTap: () {
          IMUtils.previewFile(message);
        },
        child: ChatFileView(
          message: message..fileElem = oa.fileElem,
          isISend: false,
        ),
      );
}
