import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:pull_to_refresh_new/pull_to_refresh.dart';
import 'package:search_keyword_text/search_keyword_text.dart';
import 'package:sprintf/sprintf.dart';

import '../../widgets/file_download_progress.dart';
import 'global_search_logic.dart';

class QuanGlobalSearchPage extends StatelessWidget {
  final logic = Get.find<GlobalSearchLogic>();

  QuanGlobalSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return TouchCloseSoftKeyboard(
      child: Scaffold(
        appBar: TitleBar.search(
          focusNode: logic.focusNode,
          controller: logic.searchCtrl,
          onSubmitted: (_) => logic.search(),
          onCleared: () => logic.focusNode.requestFocus(),
        ),
        backgroundColor: Styles.c_F8F9FA,
        // body: Obx(() => logic.isSearchNotResult ? _emptyListView : SizedBox()),
        body: Obx(() => Column(
              children: [
                _buildTabBar(),
                logic.isSearchNotResult
                    ? _emptyListView
                    : Flexible(
                        child: IndexedStack(
                          index: logic.index.value,
                          children: [
                            _buildqweAllListView(),
                            _buildContactsListerView(),
                            _buildGroupbdListView(),
                            _buildChatHistorysListView(),
                            _buildFileListsView(),
                          ],
                        ),
                      ),
              ],
            )),
      ),
    );
  }

  Widget _buildqweAllListView() => ListView(
        padding: EdgeInsets.only(top: 10.h),
        children: [
          if (logic.contactsList.isNotEmpty)
            _buildCommonContainerway(
              title: StrRes.globalSearchContacts,
              children: logic
                  .subList(logic.contactsList)
                  .map((e) => _buildteItemView(
                        nickname: e.remark?.isNotEmpty == true ? '${e.nickname} (${e.remark})' : e.nickname,
                        faceURL: e.faceURL,
                        content: logic.parseDeptDetailInfo(e),
                        onTap: () => logic.viewUserProfile(e),
                      ))
                  .toList(),
              seeMoreStr: logic.contactsList.length > 2 ? StrRes.seeMoreRelatedContacts : null,
              onSeeMore: () => logic.switchTab(1),
            ),
          if (logic.groupList.isNotEmpty)
            _buildCommonContainerway(
              title: StrRes.globalSearchGroup,
              children: logic
                  .subList(logic.groupList)
                  .map((e) => _buildteItemView(
                        nickname: e.groupName,
                        faceURL: e.faceURL,
                        isGroup: true,
                        onTap: () => logic.viewGroup(e),
                      ))
                  .toList(),
              seeMoreStr: logic.groupList.length > 2 ? StrRes.seeMoreRelatedGroup : null,
              onSeeMore: () => logic.switchTab(2),
            ),
          if (logic.textSearchResultItems.isNotEmpty)
            _buildCommonContainerway(
              title: StrRes.globalSearchChatHistory,
              children: logic.subList(logic.textSearchResultItems).map((e) {
                final message = e.messageList?.firstOrNull;
                final showName = e.showName;
                final faceURL = e.faceURL;
                final sendTime = message?.sendTime;
                final count = e.messageCount ?? 0;
                final content = count > 1 ? sprintf(StrRes.relatedChatHistory, [count]) : logic.calContent(message!);
                final time = null == sendTime ? null : IMUtils.getChatTimeline(sendTime);
                return _buildteItemView(
                  nickname: showName,
                  faceURL: faceURL,
                  time: time,
                  content: content,
                  isChatText: true,
                  isGroup: message?.isSingleChat == false,
                  onTap: () => logic.viewMessage(e),
                );
              }).toList(),
              seeMoreStr: logic.textSearchResultItems.length > 2 ? StrRes.seeMoreRelatedChatHistory : null,
              onSeeMore: () => logic.switchTab(3),
            ),
          if (logic.fileMessageList.isNotEmpty)
            _buildCommonContainerway(
              title: StrRes.globalSearchChatFile,
              children: logic
                  .subList(logic.fileMessageList)
                  .map((e) => _buildteItemView(
                        nickname: IMUtils.calContent(
                          content: e.fileElem?.fileName ?? '',
                          key: logic.searchKey,
                          style: Styles.ts_0C1C33_17sp,
                          usedWidth: 44.w + 80.w + 26.w,
                        ),
                        fileIcon: ChatFileIconView(
                          message: e,
                          downloadProgressView: FileDownloadProgressView(e),
                        ),
                        // fileIcon: IMUtils.fileIcon(
                        //         e.fileElem?.fileName ?? '')
                        //     .toImage
                        //   ..width = 38.w
                        //   ..height = 44.h,
                        content: e.senderNickname,
                        onTap: () => logic.viewFile(e),
                      ))
                  .toList(),
              seeMoreStr: logic.fileMessageList.length > 2 ? StrRes.seeMoreRelatedFile : null,
              onSeeMore: () => logic.switchTab(4),
            ),
        ],
      );

  Widget _buildContactsListerView() => logic.searchKey.isNotEmpty && logic.contactsList.isEmpty
      ? _emptyListView
      : ListView(
          padding: EdgeInsets.only(top: 10.h),
          children: logic.contactsList
              .map((e) => _buildteItemView(
                    nickname: e.remark?.isNotEmpty == true ? '${e.nickname} (${e.remark})' : e.nickname,
                    faceURL: e.faceURL,
                    content: logic.parseDeptDetailInfo(e),
                    onTap: () => logic.viewUserProfile(e),
                  ))
              .toList(),
        );

  Widget _buildGroupbdListView() => logic.searchKey.isNotEmpty && logic.groupList.isEmpty
      ? _emptyListView
      : ListView(
          padding: EdgeInsets.only(top: 10.h),
          children: logic.groupList
              .map((e) => _buildteItemView(
                    nickname: e.groupName,
                    faceURL: e.faceURL,
                    isGroup: true,
                    onTap: () => logic.viewGroup(e),
                  ))
              .toList(),
        );

  Widget _buildChatHistorysListView() => logic.searchKey.isNotEmpty && logic.textSearchResultItems.isEmpty
      ? _emptyListView
      : SmartRefresher(
          key: const ValueKey(0),
          controller: logic.textMessageRefreshCtrl,
          enablePullDown: false,
          enablePullUp: true,
          footer: IMViews.buildFooter(),
          onLoading: logic.loadTextMessage,
          child: ListView.builder(
            padding: EdgeInsets.only(top: 10.h),
            itemCount: logic.textSearchResultItems.length,
            itemBuilder: (_, index) {
              final e = logic.textSearchResultItems.elementAt(index);
              final message = e.messageList?.firstOrNull;
              final showName = e.showName;
              final faceURL = e.faceURL;
              final sendTime = message?.sendTime;
              final count = e.messageCount ?? 0;
              final content = count > 1 ? sprintf(StrRes.relatedChatHistory, [count]) : logic.calContent(message!);
              final time = null == sendTime ? null : IMUtils.getChatTimeline(sendTime);
              return _buildteItemView(
                nickname: showName,
                faceURL: faceURL,
                time: time,
                content: content,
                isChatText: true,
                isGroup: message?.isSingleChat == false,
                onTap: () => logic.viewMessage(e),
              );
            },
          ),
        );

  Widget _buildFileListsView() => logic.searchKey.isNotEmpty && logic.fileMessageList.isEmpty
      ? _emptyListView
      : SmartRefresher(
          key: const ValueKey(1),
          controller: logic.fileMessageRefreshCtrl,
          enablePullDown: false,
          enablePullUp: true,
          footer: IMViews.buildFooter(),
          onLoading: logic.loadFileMessage,
          child: ListView.builder(
            padding: EdgeInsets.only(top: 10.h),
            itemCount: logic.fileMessageList.length,
            itemBuilder: (_, index) {
              final e = logic.fileMessageList.elementAt(index);
              return _buildteItemView(
                nickname: IMUtils.calContent(
                  content: e.fileElem?.fileName ?? '',
                  key: logic.searchKey,
                  style: Styles.ts_0C1C33_17sp,
                  usedWidth: 44.w + 80.w + 26.w,
                ),
                fileIcon: ChatFileIconView(
                  message: e,
                  downloadProgressView: FileDownloadProgressView(e),
                ),
                content: e.senderNickname,
                onTap: () => logic.viewFile(e),
              );
            },
          ),
        );

  Widget _buildCommonContainerway({
    required String title,
    List<Widget> children = const [],
    String? seeMoreStr,
    Function()? onSeeMore,
  }) =>
      Container(
        margin: EdgeInsets.fromLTRB(10.w, 0, 10.w, 10.h),
        decoration: BoxDecoration(
          color: Styles.c_FFFFFF,
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 16.w, top: 6.h),
              child: title.toText..style = Styles.ts_8E9AB0_14sp,
            ),
            ...children,
            if (null != seeMoreStr)
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: onSeeMore,
                child: Container(
                  height: 48.h,
                  padding: EdgeInsets.symmetric(horizontal: 15.w),
                  decoration: BoxDecoration(
                    border: BorderDirectional(
                      top: BorderSide(
                        color: Styles.c_E8EAEF,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      seeMoreStr.toText..style = Styles.ts_0089FF_17sp,
                      const Spacer(),
                      ImageRes.rightArrow.toImage
                        ..width = 24.w
                        ..height = 24.h,
                    ],
                  ),
                ),
              ),
          ],
        ),
      );

  Widget _buildteItemView({
    Widget? fileIcon,
    String? nickname,
    String? fileName,
    String? faceURL,
    String? time,
    String? content,
    bool isGroup = false,
    bool isChatText = false,
    Function()? onTap,
  }) =>
      GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: onTap,
        child: Container(
          height: 64.h,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          color: Styles.c_FFFFFF,
          child: Row(
            children: [
              fileIcon ??
                  AvatarView(
                    text: nickname,
                    url: faceURL,
                    isGroup: isGroup,
                  ),
              10.horizontalSpace,
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Expanded(
                            child: isChatText
                                ? ((nickname ?? '').toText
                                  ..style = Styles.ts_0C1C33_17sp
                                  ..maxLines = 1
                                  ..overflow = TextOverflow.ellipsis)
                                : SearchKeywordText(
                                    text: nickname ?? fileName ?? '',
                                    keyText: logic.searchKey,
                                    style: Styles.ts_0C1C33_17sp,
                                    keyStyle: Styles.ts_0089FF_17sp,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  )),
                        if (time != null) time.toText..style = Styles.ts_8E9AB0_14sp,
                      ],
                    ),
                    if (null != content)
                      SearchKeywordText(
                        text: content,
                        keyText: logic.searchKey,
                        style: Styles.ts_8E9AB0_14sp,
                        keyStyle: Styles.ts_0089FF_14sp,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              )
            ],
          ),
        ),
      );

  Widget _buildTabBar() {
    Widget buildTabItem({
      required String label,
      required int index,
      bool isChecked = false,
    }) =>
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => logic.switchTab(index),
          child: SizedBox(
            height: 48.h,
            child: Stack(
              alignment: Alignment.center,
              children: [
                label.toText..style = (isChecked ? Styles.ts_0089FF_16sp_medium : Styles.ts_8E9AB0_16sp),
                if (isChecked)
                  Positioned(
                    bottom: 0,
                    child: Container(
                      width: 36.w,
                      height: 2.h,
                      decoration: BoxDecoration(
                        color: Styles.c_0089FF,
                        borderRadius: BorderRadius.circular(2.5.r),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
    return Container(
      color: Styles.c_FFFFFF,
      height: 48.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(
          logic.tabs.length,
          (index) => buildTabItem(
            index: index,
            label: logic.tabs.elementAt(index),
            isChecked: logic.index.value == index,
          ),
        ),
      ),
    );
  }

  Widget get _emptyListView => SizedBox(
        width: 1.sw,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 157.verticalSpace,
            // ImageRes.blacklistEmpty.toImage
            //   ..width = 120.w
            //   ..height = 120.h,
            // 22.verticalSpace,
            44.verticalSpace,
            StrRes.searchNotFound.toText..style = Styles.ts_8E9AB0_17sp,
          ],
        ),
      );
}
