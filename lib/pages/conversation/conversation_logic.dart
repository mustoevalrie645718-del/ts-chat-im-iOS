import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:pull_to_refresh_new/pull_to_refresh.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:uuid/uuid.dart';

import '../../core/controller/app_controller.dart';
import '../../core/controller/im_controller.dart';
import '../../core/im_callback.dart';
import '../../routes/app_navigator.dart';
import '../contacts/add_by_search/add_by_search_logic.dart';
import '../home/home_logic.dart';

class ConversationLogic extends GetxController with WidgetsBindingObserver {
  final popCtrl = CustomPopupMenuController();
  final list = <ConversationInfo>[].obs;
  final imLogic = Get.find<IMController>();
  final homeLogic = Get.find<HomeLogic>();
  final appLogic = Get.find<AppController>();
  final refreshController = RefreshController();
  final tempDraftText = <String, String>{};
  final pageSize = 50;
  int offset = 0;

  final imStatus = IMSdkStatus.connectionSucceeded.obs;

  // For monitoring change rate
  DateTime? _lastChangeTime;
  final _changeIntervals = <double>[];

  // For periodic refresh optimization (works for both stress test and real high-frequency updates)
  Timer? _periodicRefreshTimer; // Periodic refresh for high-frequency updates
  final _pendingUpdates = <String, ConversationInfo>{}; // Use Map to keep only latest update per conversation
  static const _periodicRefreshInterval = Duration(milliseconds: 500); // Refresh every 1 second

  // Page visibility tracking
  bool _isAppInForeground = true; // Track if app is in foreground
  bool _isPageVisible = true; // Track if page is on top of navigation stack

  bool reInstall = false;

  // Stress test simulation
  Timer? _stressTestTimer;
  Timer? _stressTestUIRefreshTimer; // Separate timer for UI refresh
  final isStressTestRunning = false.obs;
  int _stressTestCounter = 0;

  late AutoScrollController scrollController;
  int scrollIndex = -1;

  final globalKey = GlobalKey();

  @override
  void onInit() {
    scrollController = AutoScrollController(axis: Axis.vertical);

    // Register lifecycle observer
    WidgetsBinding.instance.addObserver(this);

    // Initialize app state based on current lifecycle
    final currentState = WidgetsBinding.instance.lifecycleState;
    _isAppInForeground = currentState == AppLifecycleState.resumed;

    // Start periodic refresh timer for handling high-frequency updates
    _periodicRefreshTimer = Timer.periodic(_periodicRefreshInterval, (timer) {
      // Only process updates when app is in foreground AND page is visible
      if (_pendingUpdates.isNotEmpty && _isAppInForeground && _isPageVisible) {
        _processPendingUpdates();
      } else if (_pendingUpdates.isNotEmpty) {
        Logger.print(
            '[Periodic Refresh] Page not visible (app: $_isAppInForeground, page: $_isPageVisible), skipping UI refresh (${_pendingUpdates.length} pending)');
      }
    });

    imLogic.conversationAddedSubject.listen((value) {
      offset++;
      onChanged(value);
    });
    imLogic.conversationChangedSubject.listen(onChanged);
    homeLogic.onScrollToUnreadMessage = scrollTo;
    imLogic.imSdkStatusSubject.listen((value) async {
      final status = value.status;
      final appReInstall = value.reInstall;
      final progress = value.progress;
      imStatus.value = status;

      if (status == IMSdkStatus.syncStart) {
        reInstall = appReInstall;
        if (reInstall) {
          EasyLoading.showProgress(0, status: StrRes.synchronizing);
        }
      }

      Logger.print('IM SDK Status: $status, reinstall: $reInstall, progress: $progress');

      if (status == IMSdkStatus.syncProgress && reInstall) {
        final p = (progress!).toDouble() / 100.0;

        EasyLoading.showProgress(p, status: '${StrRes.synchronizing}(${(p * 100.0).truncate()}%)');
      } else if (status == IMSdkStatus.syncEnded || status == IMSdkStatus.syncFailed) {
        EasyLoading.dismiss();
        if (reInstall) {
          onRefresh();
          reInstall = false;
        }
      }
    });
    super.onInit();
  }

  /// 会话列表通过回调更新
  void onChanged(List<ConversationInfo> newList) {
    final now = DateTime.now();

    // Track timing between changes
    if (_lastChangeTime != null) {
      final interval = now.difference(_lastChangeTime!).inMilliseconds / 1000.0;
      _changeIntervals.add(interval);

      // Log statistics every 10 changes
      if (_changeIntervals.length >= 10) {
        final totalTime = _changeIntervals.reduce((a, b) => a + b);
        final avgInterval = totalTime / _changeIntervals.length;
        final minInterval = _changeIntervals.reduce((a, b) => a < b ? a : b);
        final maxInterval = _changeIntervals.reduce((a, b) => a > b ? a : b);

        Logger.print(
            '[conversation rate] Last ${_changeIntervals.length} changes -\n'
            '  Avg interval: ${avgInterval.toStringAsFixed(3)}s\n'
            '  Min interval: ${minInterval.toStringAsFixed(3)}s\n'
            '  Max interval: ${maxInterval.toStringAsFixed(3)}s\n'
            '  Changes/sec: ${(_changeIntervals.length / totalTime).toStringAsFixed(2)}',
            onlyConsole: true);

        // Reset for next window
        _changeIntervals.clear();
      }
    }
    _lastChangeTime = now;

    // Add to pending updates - use conversationID as key to keep only latest update
    for (var item in newList) {
      _pendingUpdates[item.conversationID] = item;
    }
  }

  /// Process all pending updates in a single batch
  void _processPendingUpdates() {
    if (_pendingUpdates.isEmpty) {
      return;
    }

    final now = DateTime.now();
    final processingCount = _pendingUpdates.length;
    final pendingList = _pendingUpdates.values.toList();

    final updatedList = List<ConversationInfo>.from(list);

    if (updatedList.isNotEmpty) {
      final msg = updatedList.last;
      final timeDiff = (now.millisecondsSinceEpoch - msg.latestMsgSendTime!) / 1000.0;
      Logger.print(
          '[conversation changed] Current time: ${now.toLocal()}, Time difference: ${timeDiff.toStringAsFixed(3)}s',
          onlyConsole: true);
    }

    // Remove old items from pending updates
    for (var newValue in pendingList) {
      updatedList.remove(newValue);
    }

    // Only play sound for the first conversation (most recent update)
    // to avoid triggering multiple concurrent audio requests
    if (pendingList.isNotEmpty) {
      // promptSoundOrNotification(pendingList.first);
    }

    // Insert new items at the beginning
    updatedList.insertAll(0, pendingList);

    // Remove duplicates using Map (more efficient than toSet for custom objects)
    // Use conversationID as key to ensure uniqueness
    final uniqueMap = <String, ConversationInfo>{};
    for (var item in updatedList) {
      uniqueMap[item.conversationID] = item; // Later items override earlier ones
    }
    final uniqueList = uniqueMap.values.toList();
    OpenIM.iMManager.conversationManager.simpleSort(uniqueList);

    // Single assignment to trigger only one UI refresh
    list.assignAll(uniqueList);

    // Clear pending updates
    _pendingUpdates.clear();
  }

  @override
  void onReady() {
    onRefresh();
    super.onReady();
  }

  String getConversationID(ConversationInfo info) {
    return info.conversationID;
  }

  /// 标记会话已读
  void markMessageHasRead(ConversationInfo info) {
    _markMessageHasRead(conversationID: info.conversationID);
  }

  /// 置顶会话
  void pinConversation(ConversationInfo info) async {
    OpenIM.iMManager.conversationManager.pinConversation(
      conversationID: info.conversationID,
      isPinned: !info.isPinned!,
    );
  }

  /// 删除会话
  void deleteConversation(ConversationInfo info) async {
    await OpenIM.iMManager.conversationManager.deleteConversationAndDeleteAllMsg(
      conversationID: info.conversationID,
    );
    list.remove(info);
    offset -= 1;
  }

  /// 根据id移除会话
  void removeConversation(String id) {
    list.removeWhere((e) => e.conversationID == id);
  }

  /// 设置草稿
  void setConversationDraft({required String cid, required String draftText}) {
    OpenIM.iMManager.conversationManager.setConversationDraft(
      conversationID: cid,
      draftText: draftText,
    );
  }

  /// 会话前缀标签
  String? getPrefixTag(ConversationInfo info) {
    String? prefix;
    try {
      // 草稿
      if (null != info.draftText && '' != info.draftText) {
        var map = json.decode(info.draftText!);
        String text = map['text'];
        if (text.isNotEmpty) {
          prefix = '[${StrRes.draftText}]';
        }
      } else {
        switch (info.groupAtType) {
          case GroupAtType.atAll:
            prefix = '[@${StrRes.everyone}]';
            break;
          case GroupAtType.atAllAtMe:
            prefix = '[@${StrRes.everyone} @${StrRes.you}]';
            break;
          case GroupAtType.atMe:
            prefix = '[@${StrRes.you}]';
            break;
          case GroupAtType.atNormal:
            break;
          case GroupAtType.groupNotification:
            prefix = '[${StrRes.groupAc}]';
            break;
        }
      }
    } catch (e, s) {
      Logger.print('e: $e  s: $s');
    }

    return prefix;
  }

  /// 解析消息内容
  String getContent(ConversationInfo info) {
    try {
      if (null != info.draftText && '' != info.draftText) {
        var map = json.decode(info.draftText!);
        String text = map['text'];
        if (text.isNotEmpty) {
          return text;
        }
      }

      if (null == info.latestMsg) return "";

      final text = IMUtils.parseNtf(info.latestMsg!, isConversation: true);
      if (text != null) return text;
      if (info.isSingleChat || info.latestMsg!.sendID == OpenIM.iMManager.userID) {
        return IMUtils.parseMsg(info.latestMsg!, isConversation: true);
      }

      return "${info.latestMsg!.senderNickname}: ${IMUtils.parseMsg(info.latestMsg!, isConversation: true)} ";
    } catch (e, s) {
      Logger.print('------e:$e s:$s');
    }
    return '[${StrRes.unsupportedMessage}]';
  }

  Map<String, String> getAtUserMap(ConversationInfo info) {
    if (null != info.draftText && '' != info.draftText!.trim()) {
      var map = json.decode(info.draftText!);
      var atMap = map['at'];
      if (atMap.isNotEmpty && atMap is Map) {
        var v = <String, String>{};
        atMap.forEach((key, value) {
          v.addAll({'$key': "$value"});
        });
        return v;
      }
    }
    if (info.isGroupChat) {
      final map = <String, String>{};
      var message = info.latestMsg;
      if (message?.contentType == MessageType.atText) {
        var list = message!.atTextElem!.atUsersInfo;
        list?.forEach((e) {
          map[e.atUserID!] = e.groupNickname ?? e.atUserID!;
        });
      }
      return map;
    }
    return {};
  }

  /// 头像
  String? getAvatar(ConversationInfo info) {
    return info.faceURL;
  }

  bool isGroupChat(ConversationInfo info) {
    return info.isGroupChat;
  }

  /// 显示名
  String getShowName(ConversationInfo info) {
    if (info.showName == null || info.showName.isBlank!) {
      return info.userID!;
    }
    return info.showName!;
  }

  /// 时间
  String getTime(ConversationInfo info) {
    // During stress test, show detailed time (HH:mm:ss.SSS) for debugging
    if (isStressTestRunning.value) {
      final time = DateTime.fromMillisecondsSinceEpoch(info.latestMsgSendTime!);
      return '${time.hour.toString().padLeft(2, '0')}:'
          '${time.minute.toString().padLeft(2, '0')}:'
          '${time.second.toString().padLeft(2, '0')}.'
          '${time.millisecond.toString().padLeft(3, '0')}';
    }
    return IMUtils.getChatTimeline(info.latestMsgSendTime!);
  }

  /// 未读数
  int getUnreadCount(ConversationInfo info) {
    return info.unreadCount;
  }

  bool existUnreadMsg(ConversationInfo info) {
    return getUnreadCount(info) > 0;
  }

  /// 判断置顶
  bool isPinned(ConversationInfo info) {
    return info.isPinned!;
  }

  bool isNotDisturb(ConversationInfo info) {
    return info.recvMsgOpt != 0;
  }

  bool isUserGroup(int index) => list.elementAt(index).isGroupChat;

  /// 草稿
  /// 聊天页调用，不通过onWillPop事件返回，因为该事件会拦截ios的左滑返回上一页。
  void updateDartText({
    String? conversationID,
    required String text,
  }) {
    if (null != conversationID) tempDraftText[conversationID] = text;
  }

  /// 清空未读消息数
  void _markMessageHasRead({
    String? conversationID,
  }) {
    OpenIM.iMManager.conversationManager.markConversationMessageAsRead(
      conversationID: conversationID!,
    );
  }

  /// 设置草稿
  void _setupDraftText({
    required String conversationID,
    required String oldDraftText,
    required String newDraftText,
  }) {
    if (oldDraftText.isEmpty && newDraftText.isEmpty) {
      return;
    }

    /// 保存草稿
    Logger.print('draftText:$newDraftText');
    OpenIM.iMManager.conversationManager.setConversationDraft(
      conversationID: conversationID,
      draftText: newDraftText,
    );
  }

  String? get imSdkStatus {
    switch (imStatus.value) {
      case IMSdkStatus.syncStart:
      case IMSdkStatus.synchronizing:
      case IMSdkStatus.syncProgress:
        return StrRes.synchronizing;
      case IMSdkStatus.syncFailed:
        return StrRes.syncFailed;
      case IMSdkStatus.connecting:
        return StrRes.connecting;
      case IMSdkStatus.connectionFailed:
        return StrRes.connectionFailed;
      case IMSdkStatus.connectionSucceeded:
      case IMSdkStatus.syncEnded:
        return null;
    }
  }

  bool get isFailedSdkStatus =>
      imStatus.value == IMSdkStatus.connectionFailed || imStatus.value == IMSdkStatus.syncFailed;

  void onRefresh() async {
    offset = 0;
    final temp = await _getConversations(offset: offset, count: pageSize);
    list.assignAll(temp);
    offset += list.length;

    refreshController.refreshCompleted();
    refreshController.resetNoData();
  }

  void onLoadMore() async {
    final temp = await _getConversations(offset: offset, count: pageSize);
    list.addAll(temp);
    offset += min(list.length, pageSize);

    if (temp.length < pageSize) {
      refreshController.loadNoData();
    } else {
      refreshController.loadComplete();
    }
  }

  Future<List<ConversationInfo>> _getConversations({int offset = 0, int count = 100}) {
    return OpenIM.iMManager.conversationManager.getConversationListSplit(offset: offset, count: count);
  }

  static Future<List<ConversationInfo>> getConversationFirstPage() async {
    return OpenIM.iMManager.conversationManager.getConversationListSplit(offset: 0, count: 50);
  }

  bool isValidConversation(ConversationInfo info) {
    return info.isValid;
  }

  // use this if total item count is known
  int scrollListenerWithItemCount() {
    int itemCount = list.length;
    double scrollOffset = scrollController.position.pixels;
    double viewportHeight = scrollController.position.viewportDimension;
    double scrollRange = scrollController.position.maxScrollExtent - scrollController.position.minScrollExtent;
    int firstVisibleItemIndex = (scrollOffset / (scrollRange + viewportHeight) * itemCount).floor();
    return firstVisibleItemIndex;
  }

  void scrollTo() {
    if (list.isEmpty) return;
    // int first = scrollListenerWithItemCount();
    // int min = visibilityIndex.minOrNull ?? 0;
    // int start = max(first, min);
    int start = scrollListenerWithItemCount();
    if (start < scrollIndex) {
      start = scrollIndex;
    }
    if (scrollIndex == start) {
      start++;
    }
    if (scrollController.offset >= scrollController.position.maxScrollExtent) {
      start = 0;
    }

    if (start > list.length - 1) return;
    final unreadItem = list.sublist(start).firstWhereOrNull((e) => e.unreadCount > 0);
    if (null == unreadItem) {
      if (start > 0) {
        scrollController.scrollToIndex(
          scrollIndex = 0,
          preferPosition: AutoScrollPosition.begin,
        );
      }
      return;
    }
    final index = list.indexOf(unreadItem);
    scrollController.scrollToIndex(
      scrollIndex = index,
      preferPosition: AutoScrollPosition.begin,
    );
  }

  static Future<ConversationInfo> _createConversation({
    required String sourceID,
    required int sessionType,
  }) =>
      LoadingView.singleton.wrap(
          asyncFunction: () => OpenIM.iMManager.conversationManager.getOneConversation(
                sourceID: sourceID,
                sessionType: sessionType,
              ));

  /// 打开系统通知页面
  Future<bool> _jumpOANtf(ConversationInfo info) async {
    if (info.conversationType == ConversationType.notification) {
      // 系统通知
      await AppNavigator.startOANtfList(info: info);
      // 标记已读
      _markMessageHasRead(conversationID: info.conversationID);
      return true;
    }
    return false;
  }

  /// 进入聊天页面
  void toChat({
    bool offUntilHome = true,
    String? userID,
    String? groupID,
    String? nickname,
    String? faceURL,
    int? sessionType,
    ConversationInfo? conversationInfo,
    Message? searchMessage,
    bool isRobot = false,
  }) async {
    // 获取会话信息，若不存在则创建
    conversationInfo ??= await _createConversation(
      sourceID: userID ?? groupID!,
      sessionType: userID == null ? sessionType! : ConversationType.single,
    );

    // 标记已读
    // _markMessageHasRead(conversationID: conversationInfo.conversationID);

    // 如果是系统通知
    if (await _jumpOANtf(conversationInfo)) return;

    // 保存旧草稿
    updateDartText(
      conversationID: conversationInfo.conversationID,
      text: conversationInfo.draftText ?? '',
    );

    // 打开聊天窗口，关闭返回草稿
    /*var newDraftText = */
    await AppNavigator.startChat(
      offUntilHome: offUntilHome,
      draftText: conversationInfo.draftText,
      conversationInfo: conversationInfo,
      searchMessage: searchMessage,
    );

    // 读取草稿
    var newDraftText = tempDraftText[conversationInfo.conversationID];

    // 标记已读
    _markMessageHasRead(conversationID: conversationInfo.conversationID);

    // 记录草稿
    _setupDraftText(
      conversationID: conversationInfo.conversationID,
      oldDraftText: conversationInfo.draftText ?? '',
      newDraftText: newDraftText!,
    );

    // 回到会话列表
    // homeLogic.switchTab(0);

    bool equal(e) => e.conversationID == conversationInfo?.conversationID;
    // 删除所有@标识/公告标识
    var groupAtType = list.firstWhereOrNull(equal)?.groupAtType;
    if (groupAtType != GroupAtType.atNormal) {
      OpenIM.iMManager.conversationManager.resetConversationGroupAtType(
        conversationID: conversationInfo.conversationID,
      );
    }
  }

  scan() => AppNavigator.startScan();

  addFriend() => AppNavigator.startAddContactsBySearch(searchType: SearchType.user);

  createGroup() => AppNavigator.startCreateGroup(defaultCheckedList: [OpenIM.iMManager.userInfo]);

  addGroup() => AppNavigator.startAddContactsBySearch(searchType: SearchType.group);

  void videoMeeting() {}

  void viewCallRecords() => AppNavigator.startCallRecords();

  void globalSearch() => AppNavigator.startGlobalSearch();

  /// Start stress test: trigger 50 conversation changes per second
  void startStressTest() {
    if (isStressTestRunning.value) {
      Logger.print('[Stress Test] Already running');
      return;
    }

    isStressTestRunning.value = true;
    _stressTestCounter = 0;
    Logger.print('[Stress Test] ========== STARTING - 50 changes per second ==========');

    // Start periodic UI refresh timer (every 1 second)
    _stressTestUIRefreshTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_pendingUpdates.isNotEmpty) {
        Logger.print('[Stress Test UI Refresh] Processing ${_pendingUpdates.length} pending updates');
        _processPendingUpdates();
      }
    });

    // Trigger every 20ms (50 times per second)
    _stressTestTimer = Timer.periodic(const Duration(milliseconds: 20), (timer) {
      _stressTestCounter++;

      // Log first trigger
      if (_stressTestCounter == 1) {
        Logger.print('[Stress Test] First trigger! Generating data...');
      }

      // Generate realistic fake conversation updates
      final fakeUpdates = <ConversationInfo>[];
      final now = DateTime.now().millisecondsSinceEpoch;

      // Generate 50 different conversations (one per trigger to reach 50/sec)
      final conversationIndex = _stressTestCounter % 50; // Cycle through 50 conversations
      final conversationId = 'sg_stress_test_group_$conversationIndex';
      final groupId = 'stress_test_group_$conversationIndex';
      final senderId = 'stress_test_user_$conversationIndex';
      final unreadCount = _stressTestCounter;
      final seq = _stressTestCounter * 10;

      // Create a minimal Message object for testing sound notification
      final fakeMsg = Message(
        sendID: senderId, // Different from current user to trigger notification
        senderNickname: 'Stress Test User $conversationIndex',
        seq: seq,
        sendTime: now,
        contentType: 101, // Text message
        clientMsgID: Uuid().v4(),
        serverMsgID: Uuid().v4(),
        textElem: TextElem(content: 'Stress Test Message $conversationIndex'),
      );

      final fakeConv = ConversationInfo(
        conversationID: conversationId,
        conversationType: 3, // Group chat
        userID: '',
        groupID: groupId,
        showName: 'Stress Test Group $conversationIndex',
        faceURL: '',
        recvMsgOpt: 0, // Allow notifications
        unreadCount: unreadCount,
        groupAtType: 0,
        latestMsg: fakeMsg, // Include message to test sound notification
        latestMsgSendTime: now,
        draftText: '',
        draftTextTime: 0,
        isPinned: false,
        isPrivateChat: false,
        burnDuration: 30,
        isNotInGroup: false,
      );

      fakeUpdates.add(fakeConv);

      // Trigger onChanged with fake updates
      onChanged(fakeUpdates);

      // Log every 10 triggers (more frequent for debugging)
      if (_stressTestCounter % 10 == 0) {
        Logger.print(
            '[Stress Test] Triggered ${_stressTestCounter} times, generated ${fakeUpdates.length} conversations, pending: ${_pendingUpdates.length}, UI list: ${list.length}',
            onlyConsole: true);
      }

      // Log every second
      if (_stressTestCounter % 50 == 0) {
        Logger.print('[Stress Test] === ${_stressTestCounter ~/ 50} seconds elapsed, UI list size: ${list.length} ===',
            onlyConsole: true);
      }
    });
  }

  /// Stop stress test
  void stopStressTest() {
    if (!isStressTestRunning.value) {
      return;
    }

    // Cancel both timers
    _stressTestTimer?.cancel();
    _stressTestTimer = null;
    _stressTestUIRefreshTimer?.cancel();
    _stressTestUIRefreshTimer = null;

    isStressTestRunning.value = false;

    Logger.print('[Stress Test] Stopped after ${_stressTestCounter} triggers (${_stressTestCounter ~/ 50} seconds)',
        onlyConsole: true);
    _stressTestCounter = 0;

    // Process any remaining pending updates
    if (_pendingUpdates.isNotEmpty) {
      Logger.print('[Stress Test] Processing ${_pendingUpdates.length} remaining updates');
      _processPendingUpdates();
    }
  }

  /// Toggle stress test on/off
  void toggleStressTest() {
    Logger.print('[Stress Test] Toggle called, current state: ${isStressTestRunning.value}');
    if (isStressTestRunning.value) {
      stopStressTest();
    } else {
      startStressTest();
    }
  }

  /// Called when page becomes visible in navigation stack
  void onPageVisible() {
    final wasVisible = _isPageVisible;
    _isPageVisible = true;
    Logger.print('[Route] Page became visible');

    // When page becomes visible, process any pending updates immediately
    if (!wasVisible && _isAppInForeground && _pendingUpdates.isNotEmpty) {
      Logger.print('[Route] Page visible, processing ${_pendingUpdates.length} pending updates');
      _processPendingUpdates();
    }
  }

  /// Called when page is hidden by navigation (pushed another page on top)
  void onPageInvisible() {
    _isPageVisible = false;
    Logger.print('[Route] Page became invisible (${_pendingUpdates.length} pending updates will accumulate)');
  }

  void clear() {
    list.clear();
    offset = 0;

    // Clear pending updates to prevent showing previous account's conversations
    _pendingUpdates.clear();

    // Clear draft text cache
    tempDraftText.clear();

    // Reset change tracking
    _lastChangeTime = null;
    _changeIntervals.clear();

    // Reset scroll position
    scrollIndex = -1;

    // Stop any running stress test
    if (isStressTestRunning.value) {
      stopStressTest();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    final wasInForeground = _isAppInForeground;
    _isAppInForeground = state == AppLifecycleState.resumed;

    Logger.print('[Lifecycle] App state changed: $state, isInForeground: $_isAppInForeground');

    // When app returns to foreground, process any pending updates immediately (if page is visible)
    if (_isAppInForeground && !wasInForeground && _isPageVisible && _pendingUpdates.isNotEmpty) {
      Logger.print('[Lifecycle] App resumed, processing ${_pendingUpdates.length} pending updates');
      _processPendingUpdates();
    }
  }

  @override
  void onClose() {
    // Unregister lifecycle observer
    WidgetsBinding.instance.removeObserver(this);

    // Clean up all timers
    _periodicRefreshTimer?.cancel();
    _periodicRefreshTimer = null;
    _pendingUpdates.clear();

    // Clean up stress test timers
    stopStressTest();
    _stressTestUIRefreshTimer?.cancel();
    _stressTestUIRefreshTimer = null;

    super.onClose();
  }
}
