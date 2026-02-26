import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:common_utils/common_utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mime/mime.dart';
import 'package:openim_common/openim_common.dart';
import 'package:openim_live/openim_live.dart';
import 'package:pull_to_refresh_new/pull_to_refresh.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sprintf/sprintf.dart';
import 'package:synchronized/synchronized.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';

import '../../core/controller/app_controller.dart';
import '../../core/controller/im_controller.dart';
import '../../core/im_callback.dart';
import '../../routes/app_navigator.dart';
import '../../widgets/simple_confirmation_dialog.dart';
import '../contacts/select_contacts/select_contacts_logic.dart';
import '../conversation/conversation_logic.dart';
import 'widget/chat_unread_tip_view.dart';
import 'widget/fullscreen_view.dart';
import 'group_setup/group_member_list/group_member_list_logic.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

import '../../core/controller/chat_outbox_service.dart';

import 'message_cache.dart';

class ChatLogic extends SuperController {
  final imLogic = Get.find<IMController>();
  final appLogic = Get.find<AppController>();
  final conversationLogic = Get.find<ConversationLogic>();
  final cacheLogic = Get.find<CacheController>();
  final downloadLogic = Get.find<DownloadController>();

  final inputCtrl = TextEditingController();
  final focusNode = FocusNode();
  final refreshController = RefreshController();
  bool playOnce = false; // 点击的当前视频只能播放一次
  // final clickSubject = PublishSubject<Message>();
  final forceCloseToolbox = PublishSubject<bool>();
  final forceCloseMenuSub = PublishSubject<bool>();
  final sendStatusSub = PublishSubject<MsgStreamEv<int>>();
  final sendProgressSub = BehaviorSubject<MsgStreamEv<int>>();
  final downloadProgressSub = PublishSubject<MsgStreamEv<double>>();

  final scrollController = ScrollController();
  late ListObserverController observerController;
  late ChatScrollObserver chatObserver;
  final unreadMsgCount = 0.obs;
  bool needIncrementUnreadMsgCount = false;
  final showUnreadTip = false.obs;
  late MessageCache messageCache;
  final _pageSize = 50;
  bool _isLocateQuoteMsg = false;
  double? cacheExtentWhenLocateQuoteMsg;
  final _messagesBeforeLocate = <Message>[];

  late StreamSubscription<int>? unreadMsgCountEventSubscription;
  final totalUnreadMsgCount = 0.obs;

  late ConversationInfo conversationInfo;
  Message? searchMessage;
  bool isRobot = false;
  bool isPreviewChat = false;
  final nickname = ''.obs;
  final faceUrl = ''.obs;
  Timer? typingTimer;
  final typing = false.obs;
  Timer? _debounce;
  Message? quoteMsg;
  final messageList = <Message>[].obs;
  bool _isProcessing = false;
  final quoteContent = "".obs;
  final editContent = ''.obs;
  final multiSelMode = false.obs;
  final multiSelList = <Message>[].obs;
  final atUserNameMappingMap = <String, String>{};
  final atUserInfoMappingMap = <String, UserInfo>{};
  final curMsgAtUser = <String>[];
  var _lastCursorIndex = -1;
  final onlineStatus = false.obs;
  final onlineStatusDesc = ''.obs;
  Timer? onlineStatusTimer;
  final favoriteList = <String>[].obs;
  final scaleFactor = Config.textScaleFactor.obs;
  final background = "".obs;
  final memberUpdateInfoMap = <String, GroupMembersInfo>{};
  final groupMessageReadMembers = <String, List<String>>{};
  final groupMutedStatus = 0.obs;
  final groupMemberRoleLevel = 1.obs;
  final muteEndTime = 0.obs;

  // Lock for message list operations to prevent race conditions
  final _messageListLock = Lock();
  // Set to track message IDs for fast duplicate checking
  final _messageIds = <String>{};

  GroupInfo? groupInfo;
  GroupMembersInfo? groupMembersInfo;
  List<GroupMembersInfo> ownerAndAdmin = [];

  // sdk的isNotInGroup不能用
  final isInGroup = true.obs;
  final memberCount = 0.obs;
  final privateMessageList = <Message>[];
  final isInBlacklist = false.obs;
  final _audioPlayer = AudioPlayer();
  final currentPlayClientMsgID = "".obs;
  final isShowPopMenu = false.obs;
  final timelineUpdateSymbol = 0.obs;
  Timer? _timelineTimer;

  // final _showMenuCacheMessageList = <Message>[];
  // final scrollingCacheMessageList = <Message>[];
  late StreamSubscription conversationSub;
  late StreamSubscription memberAddSub;
  late StreamSubscription memberDelSub;
  late StreamSubscription joinedGroupAddedSub;
  late StreamSubscription joinedGroupDeletedSub;
  late StreamSubscription memberInfoChangedSub;
  late StreamSubscription groupInfoUpdatedSub;
  late StreamSubscription friendInfoChangedSub;
  StreamSubscription? userStatusChangedSub;
  StreamSubscription? selfInfoUpdatedSub;
  late StreamSubscription _newMessageSubscription;

  late StreamSubscription connectionSub;
  final syncStatus = IMSdkStatus.syncEnded.obs;

  // late StreamSubscription signalingMessageSub;

  /// super group
  final showCallingMember = false.obs;
  final participants = <Participant>[].obs;
  RoomCallingInfo? roomCallingInfo;

  /// 同步中收到了新消息
  bool _isReceivedMessageWhenSyncing = false;
  bool _isStartSyncing = false;

  final copyTextMap = <String?, String?>{};
  final revokedTextMessage = <String, String>{};

  String? groupOwnerID;

  MeetingBridge? get meetingBridge => PackageBridge.meetingBridge;

  RTCBridge? get rtcBridge => PackageBridge.rtcBridge;

  late StreamSubscription isInGroupSub;

  bool get rtcIsBusy => meetingBridge?.hasConnection == true || rtcBridge?.hasConnection == true;

  String? get userID => conversationInfo.userID;

  String? get groupID => conversationInfo.groupID;

  bool get isSingleChat => null != userID && userID!.trim().isNotEmpty;

  bool get isGroupChat => null != groupID && groupID!.trim().isNotEmpty;

  String get memberStr => isSingleChat ? "" : "($memberCount)";

  String? get senderName =>
      isSingleChat ? OpenIM.iMManager.userInfo.nickname : groupMembersInfo?.nickname;

  bool get isAdminOrOwner =>
      groupMemberRoleLevel.value == GroupRoleLevel.admin ||
      groupMemberRoleLevel.value == GroupRoleLevel.owner;

  final directionalUsers = <GroupMembersInfo>[].obs;

  final pinnedMsgs = <Message>[].obs;

  /// 是当前聊天窗口
  bool isCurrentChat(Message message) {
    var senderId = message.sendID;
    var receiverId = message.recvID;
    var groupId = message.groupID;
    // var sessionType = message.sessionType;
    var isCurSingleChat = message.isSingleChat &&
        isSingleChat &&
        (senderId == userID ||
            // 其他端当前登录用户向uid发送的消息
            senderId == OpenIM.iMManager.userID && receiverId == userID);
    var isCurGroupChat = message.isGroupChat && isGroupChat && groupID == groupId;
    return isCurSingleChat || isCurGroupChat;
  }

  void scrollBottom() {
    _resetAboutLocateMessage();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      scrollController.jumpTo(0);
    });
  }

  // Query multimedia messages and prepare for large image browsing.
  Future<List<Message>> searchMediaMessage() async {
    final messageList = await OpenIM.iMManager.messageManager.searchLocalMessages(
        conversationID: conversationInfo.conversationID,
        messageTypeList: [MessageType.picture, MessageType.video],
        count: 500);
    return messageList.searchResultItems?.first.messageList?.reversed.toList() ?? [];
  }

  @override
  void onReady() {
    _readDraftText();
    _queryUserOnlineStatus();
    _resetGroupAtType();
    _getInputState();
    _clearUnreadCount();
    onScrollToBottomLoad();
    scrollController.addListener(() {
      focusNode.unfocus();
    });
    super.onReady();
  }

  void _startTimelineTimer() {
    _timelineTimer ??= Timer.periodic(const Duration(minutes: 1), (timer) {
      timelineUpdateSymbol.value++;
    });
  }

  void _stopTimelineTimer() {
    _timelineTimer?.cancel();
    _timelineTimer = null;
  }

  @override
  void onInit() {
    // timeDilation = 10.0;
    var arguments = Get.arguments;
    conversationInfo = arguments['conversationInfo'];
    searchMessage = arguments['searchMessage'];
    isRobot = false;
    nickname.value = conversationInfo.showName ?? '';
    faceUrl.value = conversationInfo.faceURL ?? '';
    isPreviewChat = false;
    messageCache = MessageCache(conversationInfo.conversationID);
    _initChatConfig();
    _initPlayListener();
    _setSdkSyncDataListener();

    conversationSub = imLogic.conversationChangedSubject.listen((value) {
      final obj =
          value.firstWhereOrNull((e) => e.conversationID == conversationInfo.conversationID);

      if (obj != null) {
        conversationInfo = obj;
      }
    });

    _newMessageSubscription = imLogic.recvNewMessageSubject.listen((Message message) async {
      if (isCurrentChat(message)) {
        if (message.contentType == MessageType.typing) {
        } else {
          // if (!messageList.contains(message) && !scrollingCacheMessageList.contains(message)) {
          if (!messageList.contains(message)) {
            _isReceivedMessageWhenSyncing = true;
            _parseAnnouncement(message);
            if (isShowPopMenu.value ||
                (scrollController.hasClients &&
                    scrollController.positions.length == 1 &&
                    scrollController.offset != 0)) {
              // scrollingCacheMessageList.add(message);
              needIncrementUnreadMsgCount = true;
              _addMessage(message);
            } else {
              final exist = messageList.indexWhere((e) => e.clientMsgID == message.clientMsgID);
              if (exist != -1) {
                Logger.print('onRecvNewMessage: message exist ${message.toJson()}');
                messageList[exist] = message; // 更新已存在的消息
                messageCache.updateMessage(message); // 更新缓存
              } else {
                needIncrementUnreadMsgCount = true;
                _addMessage(message);
              }
              scrollBottom();
            }
          }
        }
      }
    });

    // 已被撤回消息监听（新版本）
    imLogic.onRecvMessageRevoked = (RevokedInfo info) {
      var message = messageList.firstWhereOrNull((e) => e.clientMsgID == info.clientMsgID);
      message?.notificationElem = NotificationElem(detail: jsonEncode(info));
      message?.contentType = MessageType.revokeMessageNotification;
      // message?.content = jsonEncode(info);
      // message?.contentType = MessageType.advancedRevoke;
      formatQuoteMessage(info.clientMsgID!);

      if (info.clientMsgID == quoteMsg?.clientMsgID) {
        quoteMsg = null;
        quoteContent.value = '';

        IMViews.showToast(StrRes.quoteContentBeRevoked);
      }

      if (null != message) {
        messageList.refresh();
      }
    };
    // 消息已读回执监听
    imLogic.onRecvC2CReadReceipt = (List<ReadReceiptInfo> list) {
      try {
        for (var readInfo in list) {
          if (readInfo.userID == userID) {
            for (var e in messageList) {
              if (readInfo.msgIDList?.contains(e.clientMsgID) == true) {
                e.isRead = true;
                e.hasReadTime = _timestamp;
              }
            }
          }
        }
        messageList.refresh();
      } catch (e) {}
    };

    // 消息发送进度
    imLogic.onMsgSendProgress = (String msgId, int progress) {
      Logger.print('onMsgSendProgress: $msgId $progress');
      sendProgressSub.addSafely(
        MsgStreamEv<int>(id: msgId, value: progress),
      );
    };

    joinedGroupAddedSub = imLogic.joinedGroupAddedSubject.listen((event) {
      if (event.groupID == groupID) {
        isInGroup.value = true;
        _queryGroupInfo();
      }
    });

    joinedGroupDeletedSub = imLogic.joinedGroupDeletedSubject.listen((event) {
      if (event.groupID == groupID) {
        isInGroup.value = false;
        inputCtrl.clear();
      }
    });

    // 有新成员进入
    memberAddSub = imLogic.memberAddedSubject.listen((info) {
      var groupId = info.groupID;
      if (groupId == groupID) {
        _putMemberInfo([info]);
      }
    });

    memberDelSub = imLogic.memberDeletedSubject.listen((info) {
      if (info.groupID == groupID && info.userID == OpenIM.iMManager.userID) {
        isInGroup.value = false;
        inputCtrl.clear();
      }
    });

    // 成员信息改变
    memberInfoChangedSub = imLogic.memberInfoChangedSubject.listen((info) {
      if (info.groupID == groupID) {
        if (info.userID == OpenIM.iMManager.userID) {
          muteEndTime.value = info.muteEndTime ?? 0;
          groupMemberRoleLevel.value = info.roleLevel ?? GroupRoleLevel.member;
          groupMembersInfo = info;
          _mutedClearAllInput();
        }
        _putMemberInfo([info]);

        final index = ownerAndAdmin.indexWhere((element) => element.userID == info.userID);
        if (info.roleLevel == GroupRoleLevel.member) {
          if (index > -1) {
            ownerAndAdmin.removeAt(index);
          }
        } else if (info.roleLevel == GroupRoleLevel.admin ||
            info.roleLevel == GroupRoleLevel.owner) {
          if (index == -1) {
            ownerAndAdmin.add(info);
          } else {
            ownerAndAdmin[index] = info;
          }
        }

        for (var msg in messageList) {
          if (msg.sendID == info.userID) {
            if (msg.isNotificationType) {
              final map = json.decode(msg.notificationElem!.detail!);
              final ntf = GroupNotification.fromJson(map);
              ntf.opUser?.nickname = info.nickname;
              ntf.opUser?.faceURL = info.faceURL;
              msg.notificationElem?.detail = jsonEncode(ntf);
            } else {
              msg.senderFaceUrl = info.faceURL;
              msg.senderNickname = info.nickname;
            }
          }
        }

        messageList.refresh();
      }
    });

    // 群信息变化
    groupInfoUpdatedSub = imLogic.groupInfoUpdatedSubject.listen((value) {
      if (groupID == value.groupID) {
        groupInfo = value;
        nickname.value = value.groupName ?? '';
        faceUrl.value = value.faceURL ?? '';
        groupMutedStatus.value = value.status ?? 0;
        memberCount.value = value.memberCount ?? 0;
        _mutedClearAllInput();
      }
    });

    // 好友信息变化
    friendInfoChangedSub = imLogic.friendInfoChangedSubject.listen((value) {
      if (userID == value.userID) {
        nickname.value = value.getShowName();
        faceUrl.value = value.faceURL ?? '';

        for (var msg in messageList) {
          if (msg.sendID == value.userID) {
            msg.senderFaceUrl = value.faceURL;
            msg.senderNickname = value.nickname;
          }

          messageCache.updateMessage(msg);
        }

        messageList.refresh();
      }
    });

    selfInfoUpdatedSub = imLogic.selfInfoUpdatedSubject.listen((value) {
      Logger.print('======selfInfoUpdated: $value');
      for (var msg in messageList) {
        if (msg.sendID == value.userID) {
          msg.senderFaceUrl = value.faceURL;
          msg.senderNickname = value.nickname;
        }

        messageCache.updateMessage(msg);
      }

      messageList.refresh();
    });

    // Subscribe to blacklist events (do not overwrite global callbacks)
    imLogic.blacklistAddedSubject.listen((value) {
      if (value.userID == userID) {
        isInBlacklist.value = true;
      }
    });

    imLogic.blacklistDeletedSubject.listen((value) {
      if (value.userID == userID) {
        isInBlacklist.value = false;
      }
    });
    // 自定义消息点击事件
    // clickSubject.listen((Message message) {
    //   parseClickEvent(message);
    // });

    // 输入框监听
    inputCtrl.addListener(() {
      sendTypingMsg(focus: true);
      if (_debounce?.isActive ?? false) _debounce?.cancel();

      _debounce = Timer(1.seconds, () {
        sendTypingMsg(focus: false);
      });
      _updateDartText(createDraftText());
      clearCurAtMap();
    });

    // 输入框聚焦
    focusNode.addListener(() {
      _lastCursorIndex = inputCtrl.selection.start;
      focusNodeChanged(focusNode.hasFocus);
    });

    imLogic.inputStateChangedSubject.listen((value) {
      if (value.conversationID == conversationInfo.conversationID && value.userID == userID) {
        typing.value = value.platformIDs?.isNotEmpty == true;
      }
    });
    // signalingMessageSub = imLogic.signalingMessageSubject.listen((value) {
    //   print('====value.userID:${value.userID}===uid: $uid == gid:$gid');
    //   if (value.isSingleChat && value.userID == uid ||
    //       value.isGroupChat && value.groupID == gid) {
    //     messageList.add(value.message);
    //     scrollBottom();
    //   }
    // });

    // imLogic.conversationChangedSubject.listen((newList) {
    //   for (var newValue in newList) {
    //     if (newValue.conversationID == info?.conversationID) {
    //       burnAfterReading.value = newValue.isPrivateChat!;
    //       break;
    //     }
    //   }
    // });
    imLogic.onMessageDeleted = (msg) {
      if (msg.groupID == groupID || msg.sendID == userID) {
        final msgId = msg.clientMsgID;
        messageList.removeWhere((element) => element.clientMsgID == msgId);
        if (msgId != null) {
          _messageIds.remove(msgId);
          _formatQuoteRevokeMessage(messageList);
        }
      }
    };

    _setupTotalUnreadMsgCount();
    _setupScrollObserver();

    Future.delayed(const Duration(seconds: 1), () {
      showUnreadTip.value = true;
    });

    ever(messageList, (callback) {
      IMUtils.calChatTimeInterval(messageList.reversed.toList());
    });

    // Register ChatOutboxService callbacks for this chat
    final outboxService = Get.find<ChatOutboxService>();
    outboxService.onTempMessageRemoved = (clientMsgID) {
      messageList.removeWhere((e) => e.clientMsgID == clientMsgID);
      _messageIds.remove(clientMsgID);
    };
    outboxService.onNewMessageAdded = (message) {
      // Check if this message belongs to this conversation
      final belongsToThisChat =
          (isSingleChat && message.recvID == userID) || (!isSingleChat && message.groupID == groupID);
      if (belongsToThisChat) {
        _addMessage(message);
        scrollBottom();
      }
    };

    super.onInit();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    // Update shrinkWrap in real time as the keyboard pops up or closes.
    chatObserver.observeSwitchShrinkWrap();
  }

  void _setupTotalUnreadMsgCount() async {
    totalUnreadMsgCount.value = int.parse(await OpenIM.iMManager.conversationManager.getTotalUnreadMsgCount());

    unreadMsgCountEventSubscription = imLogic.unreadMsgCountEventSubject.listen((count) {
      totalUnreadMsgCount.value = count;
    });
  }

  void _setupScrollObserver() {
    WidgetsBinding.instance.addObserver(this);
    scrollController.addListener(scrollControllerListener);
    observerController = ListObserverController(controller: scrollController)
      ..cacheJumpIndexOffset = false;

    chatObserver = ChatScrollObserver(observerController)
      ..fixedPositionOffset = 5
      ..toRebuildScrollViewCallback = () {
        print('toRebuildScrollViewCallback');
        messageList.refresh();
      }
      ..onHandlePositionResultCallback = (result) {
        if (!needIncrementUnreadMsgCount) return;
        switch (result.type) {
          case ChatScrollObserverHandlePositionType.keepPosition:
            updateUnreadMsgCount(changeCount: result.changeCount);
            break;
          case ChatScrollObserverHandlePositionType.none:
            updateUnreadMsgCount(isReset: true);
            break;
        }
      };
  }

  Widget buildUnreadTipView() {
    return Obx(() => ChatUnreadTipView(
          unreadMsgCount: unreadMsgCount.value,
          onTap: () {
            _resetAboutLocateMessage();
            scrollController.jumpTo(0);
            updateUnreadMsgCount(isReset: true);
          },
        ));
  }

  void updateUnreadMsgCount({
    bool isReset = false,
    int changeCount = 1,
  }) {
    needIncrementUnreadMsgCount = false;
    if (isReset) {
      unreadMsgCount.value = 0;
    } else {
      unreadMsgCount.value += changeCount;
    }
  }

  void scrollControllerListener() {
    const threshold = 2.0;
    if (scrollController.hasClients &&
        scrollController.positions.length == 1 &&
        (scrollController.offset >= scrollController.position.maxScrollExtent - threshold)) {
      _loadMoreHistory();
    } else if (_isLocateQuoteMsg &&
        scrollController.hasClients &&
        scrollController.positions.length == 1 &&
        scrollController.offset < 50) {
      _loadNewestHistory().then((count) {
        if (count == 0) {
          _resetAboutLocateMessage(updateMsgs: false);
        }
      });
    }

    if (scrollController.hasClients &&
        scrollController.positions.length == 1 &&
        scrollController.offset < 50 &&
        !_isLocateQuoteMsg) {
      updateUnreadMsgCount(isReset: true);
    }
  }

  void _disposeObserver() {
    WidgetsBinding.instance.removeObserver(this);
    observerController.controller?.dispose();
  }

  void _resetAboutLocateMessage({bool updateMsgs = true}) {
    if (!_isLocateQuoteMsg) {
      return;
    }

    cacheExtentWhenLocateQuoteMsg = null;
    _isLocateQuoteMsg = false;

    if (!updateMsgs) {
      return;
    }

    bool isAllIncluded = _messagesBeforeLocate.every((m) => messageList.value.contains(m));

    if (!isAllIncluded) {
      messageCache.assignMessages(_messagesBeforeLocate);
      chatObserver.standby(changeCount: _messagesBeforeLocate.length);
      messageList.assignAll(_messagesBeforeLocate);
    }
  }

  void formatQuoteMessage(String focusClientMsgID) {
    var quotes = messageList
        .where((element) =>
            element.contentType == MessageType.quote &&
            element.quoteMessage?.clientMsgID == focusClientMsgID)
        .toList();
    quotes.forEach((element) {
      final textEelemt = element.quoteMessage?.textElem ?? TextElem();
      textEelemt.content = StrRes.quoteContentBeRevoked;
      element.quoteMessage?.textElem = textEelemt;
      element.quoteMessage?.contentType = MessageType.revokeMessageNotification;
    });
  }

  Future chatSetup() => isSingleChat
      ? AppNavigator.startChatSetup(conversationInfo: conversationInfo)
      : AppNavigator.startGroupChatSetup(conversationInfo: conversationInfo);

  void clearCurAtMap() {
    // curMsgAtUser.removeWhere((uid) => !inputCtrl.text.contains('@$uid '));
  }

  /// 记录群成员信息
  void _putMemberInfo(List<GroupMembersInfo>? list) {
    list?.forEach((member) {
      _setAtMapping(
        userID: member.userID!,
        nickname: member.nickname!,
        faceURL: member.faceURL,
      );
      memberUpdateInfoMap[member.userID!] = member;
    });
    // 更新群成员信息
    messageList.refresh();
    atUserNameMappingMap[OpenIM.iMManager.userID] = StrRes.you;
    atUserInfoMappingMap[OpenIM.iMManager.userID] = OpenIM.iMManager.userInfo;

    // DataSp.putAtUserMap(groupID!, atUserNameMappingMap);
  }

  void _addMessage(Message message) async {
    await _messageListLock.synchronized(() {
      // Check for duplicates using clientMsgID
      final msgId = message.clientMsgID ?? '';
      if (msgId.isEmpty || _messageIds.contains(msgId)) {
        Logger.print('_addMessage: duplicate message ignored: $msgId');
        return;
      }

      chatObserver.standby(
        mode: ChatScrollObserverHandleMode.normal,
      );

      messageList.insert(0, message);
      _messageIds.add(msgId);
      messageCache.addNewMessage(message);

      if (_isLocateQuoteMsg) {
        _messagesBeforeLocate.insert(0, message);
      }
    });
  }

  /// 发送文字内容，包含普通内容，引用回复内容，@内容
  void sendTextMsg() async {
    var content = IMUtils.safeTrim(inputCtrl.text);
    if (content.isEmpty) return;
    Message message;
    if (curMsgAtUser.isNotEmpty) {
      createAtInfoByID(id) => AtUserInfo(
            atUserID: id,
            groupNickname: atUserNameMappingMap[id],
          );

      // 发送 @ 消息
      message = await OpenIM.iMManager.messageManager.createTextAtMessage(
        text: content,
        atUserIDList: curMsgAtUser,
        atUserInfoList: curMsgAtUser.map(createAtInfoByID).toList(),
        quoteMessage: quoteMsg,
      );
    } else if (quoteMsg != null) {
      // 发送引用消息
      message = await OpenIM.iMManager.messageManager.createQuoteMessage(
        text: content,
        quoteMsg: quoteMsg!,
      );
    } else {
      // 发送普通消息
      message = await OpenIM.iMManager.messageManager.createTextMessage(
        text: content,
      );
    }
    _sendMessage(message);
  }

  /// 发送图片
  Future sendPicture({required String path, bool sendNow = true}) async {
    try {
      Logger.print('Sending picture from path: $path');

      // 检查原始文件是否存在
      final originalFile = File(path);
      if (!await originalFile.exists()) {
        Logger.print('Original image file does not exist: $path');
        IMViews.showToast('图片文件不存在');
        return;
      }

      final file = await IMUtils.compressImageAndGetFile(originalFile);

      if (file == null) {
        Logger.print('Failed to compress image, file is null');
        IMViews.showToast('图片处理失败');
        return;
      }

      final exists = await file.exists();
      Logger.print('Compressed file exists: $exists, path: ${file.path}');

      if (!exists) {
        Logger.print('Compressed file does not exist, using original file');
        // 如果压缩文件不存在，尝试使用原始文件
        if (await originalFile.exists()) {
          final message = await OpenIM.iMManager.messageManager.createImageMessageFromFullPath(
            imagePath: originalFile.path,
          );

          if (sendNow) {
            return _sendMessage(message);
          } else {
            _addMessage(message);
          }
        } else {
          IMViews.showToast('图片文件不存在');
          return;
        }
      } else {
        var message = await OpenIM.iMManager.messageManager.createImageMessageFromFullPath(
          imagePath: file.path,
        );

        if (sendNow) {
          return _sendMessage(message);
        } else {
          _addMessage(message);
        }
      }

      if (Platform.isIOS) {
        originalFile.deleteSync();
      }
    } catch (e, stackTrace) {
      Logger.print('Error sending picture: $e');
      Logger.print('StackTrace: $stackTrace');
      IMViews.showToast('发送图片失败: $e');
    }
  }

  /// 发送语音
  void sendVoice(int duration, String path) async {
    var message = await OpenIM.iMManager.messageManager.createSoundMessageFromFullPath(
      soundPath: path,
      duration: duration,
    );
    _sendMessage(message);
  }

  ///  发送视频
  Future sendVideo(
      {required String videoPath,
      required String mimeType,
      required int duration,
      required String thumbnailPath,
      bool sendNow = true}) async {
    // 插件有bug，有些视频长度*1000
    var d = duration > 1000.0 ? duration / 1000.0 : duration;
    var message = await OpenIM.iMManager.messageManager.createVideoMessageFromFullPath(
      videoPath: videoPath,
      videoType: mimeType,
      duration: d.toInt(),
      snapshotPath: thumbnailPath,
    );

    if (sendNow) {
      return _sendMessage(message);
    } else {
      _addMessage(message);
    }
  }

  /// 发送文件
  void sendFile({required String filePath, required String fileName}) async {
    var message = await OpenIM.iMManager.messageManager.createFileMessageFromFullPath(
      filePath: filePath,
      fileName: fileName,
    );
    _sendMessage(message);
  }

  /// 发送位置
  void sendLocation({
    required dynamic location,
  }) async {
    var message = await OpenIM.iMManager.messageManager.createLocationMessage(
      latitude: location['latitude'],
      longitude: location['longitude'],
      description: location['description'],
    );
    _sendMessage(message);
  }

  /// 转发内容的备注信息
  Future sendForwardRemarkMsg(
    String content, {
    String? userId,
    String? groupId,
    bool throwError = false,
  }) async {
    final message = await OpenIM.iMManager.messageManager.createTextMessage(
      text: content,
    );
    _sendMessage(message, userId: userId, groupId: groupId, throwError: throwError);
  }

  /// 转发
  Future sendForwardMsg(
    Message originalMessage, {
    String? userId,
    String? groupId,
  }) async {
    var message = await OpenIM.iMManager.messageManager.createForwardMessage(
      message: originalMessage,
    );
    _sendMessage(message, userId: userId, groupId: groupId);
  }

  /// 合并转发
  void sendMergeMsg({
    String? userId,
    String? groupId,
    List<Message>? messages,
  }) async {
    final selectedMessages = messages ?? List<Message>.from(multiSelList.value);
    if (selectedMessages.isEmpty) return;

    final result = await createSummarys(selectedMessages);
    String title;
    if (isGroupChat) {
      title = sprintf(StrRes.xChatRecord, [StrRes.groupChat]);
    } else {
      var partner1 = OpenIM.iMManager.userInfo.getShowName();
      var partner2 = await _querySenderNickname();
      title = sprintf(StrRes.xChatRecord, [
        sprintf(StrRes.aAndB, [partner1, partner2])
      ]);
    }
    var message = await OpenIM.iMManager.messageManager.createMergerMessage(
      messageList: result.messages,
      title: title,
      summaryList: result.summarys,
    );
    _sendMessage(message, userId: userId, groupId: groupId);
  }

  Future sendMessage(Message message, {String? userId, String? groupId, bool throwError = false}) {
    return _sendMessage(message, userId: userId, groupId: groupId, throwError: throwError);
  }

  Future<({List<String> summarys, List<Message> messages})> createSummarys(
    List<Message> selectedMessages,
  ) async {
    final completeMessageList = List<Message>.from(selectedMessages);
    final tempMultiSelList = selectedMessages.take(4).toList();
    var summaryList = <String>[];

    if (isSingleChat) {
      final friends =
          await OpenIM.iMManager.friendshipManager.getFriendsInfo(userIDList: [userID!]);

      if (friends.isNotEmpty) {
        summaryList = tempMultiSelList
            .map((msg) =>
                '${friends.first.nickname}：${IMUtils.parseMsg(msg, replaceIdToNickname: true)}')
            .toList();
      } else {
        final users = await OpenIM.iMManager.userManager.getUsersInfo(userIDList: [userID!]);
        summaryList = tempMultiSelList
            .map((msg) =>
                '${users.first.nickname}：${IMUtils.parseMsg(msg, replaceIdToNickname: true)}')
            .toList();
      }
    } else {
      final userIDs = tempMultiSelList.map((e) => e.sendID!).toList();
      final groupMembers = await OpenIM.iMManager.groupManager.getGroupMembersInfo(
        groupID: groupID!,
        userIDList: userIDs,
      );

      if (groupMembers.isNotEmpty) {
        summaryList = tempMultiSelList
            .map((msg) =>
                '${groupMembers.firstWhere((e) => e.userID == msg.sendID).nickname}：${IMUtils.parseMsg(msg, replaceIdToNickname: true)}')
            .toList();
      } else {
        final users = await OpenIM.iMManager.userManager.getUsersInfo(userIDList: userIDs);
        summaryList = tempMultiSelList
            .map((msg) =>
                '${users.firstWhere((e) => e.userID == msg.sendID).nickname}：${IMUtils.parseMsg(msg, replaceIdToNickname: true)}')
            .toList();
      }
    }

    return (summarys: summaryList, messages: completeMessageList);
  }

  Future<String> _querySenderNickname() async {
    if (isSingleChat) {
      final friends =
          await OpenIM.iMManager.friendshipManager.getFriendsInfo(userIDList: [userID!]);

      if (friends.isNotEmpty) {
        return friends.first.nickname ?? '';
      } else {
        final users = await OpenIM.iMManager.userManager.getUsersInfo(userIDList: [userID!]);

        return users.first.nickname ?? '';
      }
    }

    return '';
  }

  /// 提示对方正在输入
  void sendTypingMsg({bool focus = false}) async {
    if (isSingleChat) {
      OpenIM.iMManager.conversationManager
          .changeInputStates(conversationID: conversationInfo.conversationID, focus: focus);
    }
  }

  /// 发送名片
  void sendCarte({
    required String userID,
    String? nickname,
    String? faceURL,
  }) async {
    var message = await OpenIM.iMManager.messageManager.createCardMessage(
      userID: userID,
      nickname: nickname ?? '',
      faceURL: faceURL,
    );
    _sendMessage(message);
  }

  /// 发送自定义消息
  void sendCustomMsg({
    required String data,
    required String extension,
    required String description,
  }) async {
    var message = await OpenIM.iMManager.messageManager.createCustomMessage(
      data: data,
      extension: extension,
      description: description,
    );
    _sendMessage(message);
  }

  Future _sendMessage(
    Message message, {
    String? userId,
    String? groupId,
    bool addToUI = true,
    bool notOSS = false,
    bool throwError = false,
  }) {
    log('send : ${json.encode(message)}');
    userId = IMUtils.emptyStrToNull(userId);
    groupId = IMUtils.emptyStrToNull(groupId);
    if (null == userId && null == groupId ||
        userId == userID && userId != null ||
        groupId == groupID && groupId != null) {
      if (addToUI) {
        // 失败重复不需要添加到ui
        if (!messageList.any((e) => e.clientMsgID == message.clientMsgID)) {
          _addMessage(message);
        }
        scrollBottom();
      }
    }
    Logger.print('uid:$userID userId:$userId gid:$groupID groupId:$groupId');
    _reset(message);
    // 借用当前聊天窗口，给其他用户或群发送信息，如合并转发，分享名片。
    bool useOuterValue = null != userId || null != groupId;

    final recvUserID = useOuterValue ? userId : userID;
    final recvGroupID = useOuterValue ? groupId : groupID;
    message.recvID = recvUserID;
    message.groupID = recvGroupID;

    if (notOSS) {
      return OpenIM.iMManager.messageManager
          .sendMessageNotOss(
            message: message,
            userID: recvUserID,
            groupID: recvGroupID,
            offlinePushInfo: Config.offlinePushInfo,
          )
          .then((value) => _sendSucceeded(message, value))
          .catchError((error, _) {
        _senFailed(message, groupId, userId, error, _);
        if (throwError) {
          throw error;
        }
      }).whenComplete(() => _completed());
    } else {
      return OpenIM.iMManager.messageManager
          .sendMessage(
            message: message,
            userID: recvUserID,
            groupID: recvGroupID,
            offlinePushInfo: Config.offlinePushInfo,
          )
          .then((value) => _sendSucceeded(message, value))
          .catchError((error, _) {
        _senFailed(message, groupId, userId, error, _);
        if (throwError) {
          throw error;
        }
      }).whenComplete(() => _completed());
    }
  }

  ///  消息发送成功
  void _sendSucceeded(Message oldMsg, Message newMsg) {
    Logger.print('message send success----');
    // message.status = MessageStatus.succeeded;
    oldMsg.update(newMsg);
    sendStatusSub.addSafely(MsgStreamEv(
      id: oldMsg.clientMsgID!,
      value: MessageStatus.succeeded,
    ));
  }

  ///  消息发送失败
  void _senFailed(Message message, String? groupId, String? userId, error, stack) async {
    Logger.print(
        'message send failed userID: $userId groupId:$groupId, catch error :$error  $stack');

    if (error is PlatformException) {
      int code = int.tryParse(error.code) ?? 0;

      message.status = MessageStatus.failed;
      sendStatusSub.addSafely(MsgStreamEv(
        id: message.clientMsgID!,
        value: MessageStatus.failed,
      ));

      if (isSingleChat) {
        int? customType;
        if (code == SDKErrorCode.hasBeenBlocked) {
          customType = CustomMessageType.blockedByFriend;
        } else if (code == SDKErrorCode.notFriend) {
          customType = CustomMessageType.deletedByFriend;
        }
        if (null != customType) {
          final hintMessage =
              (await OpenIM.iMManager.messageManager.createFailedHintMessage(type: customType))
                ..status = 2
                ..isRead = true;
          if (userId != null) {
            if (userId == userID) {
              _addMessage(hintMessage);
            }
          } else {
            _addMessage(hintMessage);
          }
          OpenIM.iMManager.messageManager.insertSingleMessageToLocalStorage(
            message: hintMessage,
            receiverID: userId ?? userID,
            senderID: OpenIM.iMManager.userID,
          );
        }
      } else {
        if ((code == SDKErrorCode.userIsNotInGroup || code == SDKErrorCode.groupDisbanded) &&
            null == groupId) {
          final status = groupInfo?.status;
          final hintMessage = (await OpenIM.iMManager.messageManager.createFailedHintMessage(
              type: status == 2
                  ? CustomMessageType.groupDisbanded
                  : CustomMessageType.removedFromGroup))
            ..status = 2
            ..isRead = true;
          _addMessage(hintMessage);
          OpenIM.iMManager.messageManager.insertGroupMessageToLocalStorage(
            message: hintMessage,
            groupID: groupID,
            senderID: OpenIM.iMManager.userID,
          );
        }
      }
    } else {
      message.status = MessageStatus.failed;
      sendStatusSub.addSafely(MsgStreamEv(
        id: message.clientMsgID!,
        value: MessageStatus.failed,
      ));
    }
  }

  void _reset(Message message) {
    if (message.contentType == MessageType.text ||
        message.contentType == MessageType.atText ||
        message.contentType == MessageType.quote) {
      inputCtrl.clear();
      setQuoteMsg(null);
    }
    closeMultiSelMode();
  }

  /// todo
  void _completed() {
    messageList.refresh();
    // setQuoteMsg(-1);
    // closeMultiSelMode();
    // inputCtrl.clear();
  }

  void clearQuote() {
    if (quoteContent.value.isNotEmpty) {
      setQuoteMsg(null);
    } else {
    }
  }

  /// 设置被回复的消息体
  void setQuoteMsg(Message? message) {
    if (message == null) {
      quoteMsg = null;
      quoteContent.value = '';
    } else {
      quoteMsg = message;
      var name = quoteMsg!.senderNickname;
      quoteContent.value =
          "$name：${quoteMsg?.contentType == MessageType.revokeMessageNotification ? StrRes.quoteContentBeRevoked : IMUtils.parseMsg(
              quoteMsg!,
              replaceIdToNickname: true,
            )}";
      focusNode.requestFocus();
    }
  }

  /// 删除消息
  void deleteMsg(Message message) {
    if (message.isPrivateType) {
      _deleteMessages(clientMsgIDs: [message.clientMsgID!], isSync: false);
      return;
    }
    showDeleteMessagesDialog(
      context: Get.context!,
      messages: [message],
      deleteMessages: _deleteMessages,
    );
  }

  Future<void> showDeleteMessagesDialog({
    required BuildContext context,
    required List<Message> messages,
    required Future Function({
      required List<String> clientMsgIDs,
      bool isSync,
    }) deleteMessages,
  }) async {
    bool deleteForOther = false;

    final isMultiple = messages.length > 1;
    final dynamic result = await showDialog<dynamic>(
      context: context,
      useRootNavigator: true, // Use root Navigator with opaque PageRouteBuilder
      builder: (dialogContext) => CustomDialog(
        title: isMultiple ? StrRes.deleteMessagesHint : StrRes.deleteMessageHint,
        alignment: Alignment.centerLeft,
        showCheckbox: messages.every((message) => message.sendID == OpenIM.iMManager.userID),
        checkboxText: isMultiple ? StrRes.approveToOthersMultiple : StrRes.approveToOthers,
        initialCheckboxValue: deleteForOther,
      ),
    );

    if (result != null) {
      if (result is bool && result == false) {
        return;
      }
      var deleteForOther = false;

      if (result is Map) {
        if (result['confirmed'] == true) {
          deleteForOther = result['isChecked'] ?? false;
        }
      }

      final clientMsgIDs = messages
          .map((message) => message.clientMsgID)
          .where((id) => id != null)
          .cast<String>()
          .toList();

      if (clientMsgIDs.isEmpty) {
        IMViews.showToast('No valid messages to delete');

        return;
      }

      try {
        await deleteMessages(
          clientMsgIDs: clientMsgIDs,
          isSync: deleteForOther,
        );
      } catch (e) {
        IMViews.showToast('Failed to delete messages: $e');
      }
    }
  }

  /// 批量删除
  void _deleteMultiMsg() async {
    if (multiSelList.isEmpty) return;

    await showDeleteMessagesDialog(
      context: Get.context!,
      messages: multiSelList,
      deleteMessages: _deleteMessages,
    );
    closeMultiSelMode();
  }

  Future _deleteMessages({required List<String> clientMsgIDs, bool isSync = false}) async {
    for (var clientMsgID in clientMsgIDs) {
      await OpenIM.iMManager.messageManager
          .deleteMessageFromLocalAndSvr(
            conversationID: conversationInfo.conversationID,
            clientMsgID: clientMsgID,
          )
          .then((value) => privateMessageList
              .removeWhere((message) => clientMsgIDs.contains(message.clientMsgID)))
          .then((value) {
        chatObserver.standby(isRemove: true);
        messageList.removeWhere((message) => clientMsgIDs.contains(message.clientMsgID));
        messageCache.removeMessages(clientMsgIDs);
      });
    }
  }

  /// 合并转发
  // void mergeForward() async {
  //   final result = await AppNavigator.startSelectContacts(
  //     action: SelAction.forward,
  //     ex: sprintf(StrRes.mergeForwardHint, [multiSelList.length]),
  //   );
  //   if (null != result) {
  //     final customEx = result['customEx'];
  //     final checkedList = result['checkedList'];
  //     for (var info in checkedList) {
  //       final userID = IMUtils.convertCheckedToUserID(info);
  //       final groupID = IMUtils.convertCheckedToGroupID(info);
  //       if (customEx is String && customEx.isNotEmpty) {
  //         sendForwardRemarkMsg(customEx, userId: userID, groupId: groupID);
  //       }
  //       sendMergeMsg(userId: userID, groupId: groupID);
  //     }
  //   }
  // }

  /// 转发
  void forward(Message? message) async {
    // Capture current selection to avoid being cleared by _reset during send
    final selectedMessages = List<Message>.from(multiSelList.value);
    final result = await AppNavigator.startSelectContacts(
      action: SelAction.forward,
      ex: null != message ? IMUtils.parseMsg(message) : sprintf(StrRes.mergeForwardHint, [selectedMessages.length]),
    );
    if (null != result) {
      final customEx = result['customEx'];
      final checkedList = result['checkedList'];
      for (var info in checkedList) {
        final userID = IMUtils.convertCheckedToUserID(info);
        final groupID = IMUtils.convertCheckedToGroupID(info);

        if (null != message) {
          sendForwardMsg(message, userId: userID, groupId: groupID);
        } else {
          sendMergeMsg(userId: userID, groupId: groupID, messages: selectedMessages);
        }

        if (customEx is String && customEx.isNotEmpty) {
          sendForwardRemarkMsg(customEx, userId: userID, groupId: groupID);
        }
      }
    }
  }

  /// 大于1000为通知类消息
  /// 语音消息必须点击才能视为已读
  void markMessageAsRead(Message message, bool visible) async {
    // Logger.print('markMessageAsRead: ${message.textElem?.content}, $visible, clientMsgID: ${message.clientMsgID}');
    if (visible && message.contentType! < 1000 && !message.isVoiceType) {
      if (message.isVoiceType) {
        return;
      }
      _markMessageAsRead(message);
    }
  }

  /// 标记消息为已读
  _markMessageAsRead(Message message) async {
    if (!message.isRead! && message.sendID != OpenIM.iMManager.userID) {
      try {
        Logger.print('mark conversation message as read：${message.clientMsgID!} ${message.isRead}');
        await OpenIM.iMManager.conversationManager
            .markConversationMessageAsRead(conversationID: conversationInfo.conversationID);
      } catch (e) {
        Logger.print(
            'failed to send group message read receipt： ${message.clientMsgID} ${message.isRead}');
      } finally {
        message.isRead = true;
        message.hasReadTime = _timestamp;
        messageList.refresh();
        // message.attachedInfoElem!.hasReadTime = _timestamp;
      }
    }
  }

  _clearUnreadCount() {
    if (conversationInfo.unreadCount > 0) {
      OpenIM.iMManager.conversationManager
          .markConversationMessageAsRead(conversationID: conversationInfo.conversationID);
    }
  }

  void _getInputState() async {
    if (conversationInfo.isSingleChat) {
      final result = await OpenIM.iMManager.conversationManager
          .getInputStates(conversationInfo.conversationID, userID!);
      typing.value = result?.isNotEmpty == true;
    }
  }

  void _changeInputStatus(bool focus) async {
    if (isRobot) {
      return;
    }
    if (conversationInfo.isSingleChat) {
      await OpenIM.iMManager.conversationManager
          .changeInputStates(conversationID: conversationInfo.conversationID, focus: focus);
    }
  }

  /// 多选删除
  void mergeDelete() => _deleteMultiMsg();

  void multiSelMsg(Message message, bool checked) {
    if (checked) {
      // 合并最多20条限制
      if (multiSelList.length >= 20) {
        showDialog(
          context: Get.context!,
          useRootNavigator: true,
          builder: (context) => CustomDialog(title: StrRes.forwardMaxCountHint),
        );
      } else {
        multiSelList.add(message);
        multiSelList.sort((a, b) {
          if (a.createTime! > b.createTime!) {
            return 1;
          } else if (a.createTime! < b.createTime!) {
            return -1;
          } else {
            return 0;
          }
        });
      }
    } else {
      multiSelList.remove(message);
    }
  }

  void openMultiSelMode(Message message) {
    multiSelMode.value = true;
    multiSelMsg(message, true);
  }

  void closeMultiSelMode() {
    multiSelMode.value = false;
    multiSelList.clear();
  }

  /// 触摸其他地方强制关闭工具箱
  void closeToolbox() {
    forceCloseToolbox.addSafely(true);
  }

  /// 打开地图
  void onTapLocation() async {
    var location = await Get.to(
      const ChatWebViewMap(
          host: Config.locationHost, webKey: Config.webKey, webServerKey: Config.webServerKey),
      transition: Transition.cupertino,
      popGesture: true,
    );
    if (null != location) {
      Logger.print(location);
      sendLocation(location: location);
    }
  }

  /// 打开相册
  void onTapAlbum() async {
    final List<AssetEntity>? assets = await AssetPicker.pickAssets(Get.context!,
        pickerConfig: AssetPickerConfig(
            gridThumbnailSize: ThumbnailSize(160, 160),
            sortPathsByModifiedDate: true,
            filterOptions: FilterOptionGroup(
                containsPathModified: true,
                imageOption: FilterOption(
                  sizeConstraint: SizeConstraint(
                    ignoreSize: true,
                  ),
                ),
                videoOption: FilterOption(
                  sizeConstraint: SizeConstraint(
                    ignoreSize: true,
                  ),
                )),
            selectPredicate: (_, entity, isSelected) async {
              if (entity.type == AssetType.image) {
                if (await allowSendImageType(entity)) {
                  return true;
                }

                IMViews.showToast(StrRes.supportsTypeHint);

                return false;
              }
              // 视频限制5分钟的时长
              if (entity.videoDuration > const Duration(seconds: 5 * 60)) {
                IMViews.showToast(sprintf(StrRes.selectVideoLimit, [5]) + StrRes.minute);
                return false;
              }
              return true;
            }));
    if (null != assets) {
      await _addAssetsToView(assets, sendNow: true);
    }
  }

  /// 打开相机
  void onTapCamera() async {
    final AssetEntity? entity = await CameraPicker.pickFromCamera(
      Get.context!,
      locale: Get.locale,
      pickerConfig: CameraPickerConfig(
        enableAudio: true,
        enableRecording: true,
        enableScaledPreview: false,
        maximumRecordingDuration: 60.seconds,
        resolutionPreset: ResolutionPreset.high,
        lockCaptureOrientation: DeviceOrientation.portraitUp,
        onMinimumRecordDurationNotMet: () {
          IMViews.showToast(StrRes.tapTooShort);
        },
      ),
    );
    if (entity != null) {
      await _addAssetsToView([entity], sendNow: true);
    }
  }

  /// Asynchronously adds a list of assets to the view without sending them immediately.
  ///
  /// Iterates over each asset in the provided list and processes it using the
  /// `_handleAssets` function with `sendNow` set to false.
  ///
  /// This function is typically used to prepare assets for display or further action.
  ///
  /// [assets] A list of `AssetEntity` objects to be added to the view.
  Future _addAssetsToView(List<AssetEntity> assets, {bool sendNow = false}) async {
    await Future.forEach(assets, (asset) => _handleAssets(asset, sendNow: sendNow));
  }

  /// 打开系统文件浏览器
  void onTapFile() async {
    // await FilePicker.clearTemporaryFiles();
    await FilePicker.platform.clearTemporaryFiles();
    // FilePickerResult? result = await FilePicker.pickFiles(
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        // type: FileType.custom,
        // allowedExtensions: ['jpg', 'pdf', 'doc'],
        );

    if (result != null) {
      for (var file in result.files) {
        // String? mimeType = IMUtils.getMediaType(file.name);
        String? mimeType = lookupMimeType(file.name);
        if (mimeType != null) {
          if (IMUtils.allowImageType(mimeType)) {
            sendPicture(path: file.path!);
            continue;
          } else if (mimeType.contains('video/')) {
            try {
              final videoPath = file.path!;
              final mediaInfo = await IMUtils.getMediaInfo(videoPath);
              var thumbnailFile = await IMUtils.getVideoThumbnail(File(videoPath));

              sendVideo(
                videoPath: videoPath,
                mimeType: mimeType,
                duration: mediaInfo.duration!.toInt(),
                thumbnailPath: thumbnailFile.path,
              );
              continue;
            } catch (e, s) {
              Logger.print('e :$e  s:$s');
            }
          }
        }
        sendFile(filePath: file.path!, fileName: file.name);
      }
    } else {
      // User canceled the picker
    }
  }

  Future<bool> allowSendImageType(AssetEntity entity) async {
    final mimeType = await entity.mimeTypeAsync;

    return IMUtils.allowImageType(mimeType);
  }

  /// 名片
  void onTapCarte() async {
    var result = await AppNavigator.startSelectContacts(
      action: SelAction.carte,
    );
    if (result is UserInfo || result is FriendInfo) {
      sendCarte(
        userID: result.userID!,
        nickname: result.nickname,
        faceURL: result.faceURL,
      );
    }
  }

  Future _handleAssets(AssetEntity? asset, {bool sendNow = true}) async {
    if (null != asset) {
      Logger.print('--------assets type-----${asset.type} create time: ${asset.createDateTime}');
      final originalFile = await asset.file;
      final originalPath = originalFile!.path;
      var path = originalPath.toLowerCase().endsWith('.gif') ? originalPath : originalFile.path;
      Logger.print('--------assets path-----$path');
      switch (asset.type) {
        case AssetType.image:
          sendPicture(path: path, sendNow: sendNow);
          break;
        case AssetType.video:
          final thumbnailFile = await IMUtils.getVideoThumbnail(File(path));
          final duration = asset.duration;
          final mimeType = asset.mimeType ?? IMUtils.getMediaType(path)!;

          if (sendNow) {
            final d = duration > 1000.0 ? duration / 1000.0 : duration;
            var message = await OpenIM.iMManager.messageManager.createVideoMessageFromFullPath(
              videoPath: path,
              videoType: mimeType,
              duration: d.toInt(),
              snapshotPath: thumbnailFile.path,
            );

            // Insert local message
            if (isSingleChat) {
              message = await OpenIM.iMManager.messageManager.insertSingleMessageToLocalStorage(
                message: message,
                receiverID: userID!,
                senderID: OpenIM.iMManager.userID,
              );
            } else {
              message = await OpenIM.iMManager.messageManager.insertGroupMessageToLocalStorage(
                message: message,
                groupID: groupID!,
                senderID: OpenIM.iMManager.userID,
              );
              message.recvID = null;
            }

            // Mark as compressing
            message.exMap = {'isCompressing': true};

            _addMessage(message);

            // Compress and send asynchronously via global service
            Get.find<ChatOutboxService>().compressAndSendVideo(
              tempMessage: message,
              originalPath: path,
              thumbnailPath: thumbnailFile.path,
              duration: duration,
              mimeType: mimeType,
              conversationID: conversationInfo.conversationID,
            );
          } else {
            await sendVideo(
              videoPath: path,
              mimeType: mimeType,
              duration: duration,
              thumbnailPath: thumbnailFile.path,
              sendNow: false,
            );
          }
          break;
        default:
          break;
      }
    }
  }

  void onTapDirectionalMessage() async {
    if (null != groupInfo) {
      final list = await AppNavigator.startGroupMemberList(
        groupInfo: groupInfo!,
        opType: GroupMemberOpType.call,
      );
      if (list is List<GroupMembersInfo>) {
        directionalUsers.assignAll(list);
      }
    }
  }

  TextSpan? directionalText() {
    if (directionalUsers.isNotEmpty) {
      final temp = <TextSpan>[];

      for (var e in directionalUsers) {
        final r = TextSpan(
          text: '${e.nickname ?? ''} ${directionalUsers.last == e ? '' : ','} ',
          style: Styles.ts_0089FF_14sp,
        );

        temp.add(r);
      }

      return TextSpan(
        text: '${StrRes.directedTo}:',
        style: Styles.ts_8E9AB0_14sp,
        children: temp,
      );
    }

    return null;
  }

  void onClearDirectional() {
    directionalUsers.clear();
  }

  /// 处理消息点击事件
  void parseClickEvent(Message msg) async {
    Logger.print('parseClickEvent:${jsonEncode(msg)}');
    if (msg.contentType == MessageType.custom) {
      var data = msg.customElem!.data;
      var map = json.decode(data!);
      var customType = map['customType'];
      if (CustomMessageType.call == customType && !isInBlacklist.value) {
        if (rtcIsBusy) {
          IMViews.showToast(StrRes.callingBusy);
          return;
        }
        var type = map['data']['type'];
        imLogic.call(
          callObj: CallObj.single,
          callType: type == "audio" ? CallType.audio : CallType.video,
          inviteeUserIDList: [if (isSingleChat) userID!],
          groupID: groupID?.isNotEmpty == true ? groupID : null,
        );
      } else if (CustomMessageType.meeting == customType) {
        joinMeeting(msg);
      } else if (CustomMessageType.tag == customType) {
        final data = map['data'];
        if (null != data['soundElem']) {
          final soundElem = SoundElem.fromJson(data['soundElem']);
          msg.soundElem = soundElem;
          _playVoiceMessage(msg);
        }
      }
      return;
    }
    if (msg.contentType == MessageType.voice) {
      _playVoiceMessage(msg);
      // 收听则为已读
      _markMessageAsRead(msg);
      return;
    }
    if (msg.contentType == MessageType.groupInfoSetAnnouncementNotification) {
      AppNavigator.startEditGroupAnnouncement(
        groupID: groupInfo!.groupID,
      );
      return;
    }

    IMUtils.parseClickEvent(
      msg,
      messageList: messageList,
      onViewUserInfo: (userInfo) {
        viewUserInfo(userInfo, isCard: msg.isCardType);
      },
      meetingItemClick: joinMeeting,
      onForward: () => forward(msg),
      quoteItemClick: onTapQuoteMsg,
    );
  }

  /// 点击引用消息
  void onTapQuoteMsg(Message message) {
    // if (message.contentType == MessageType.quote) {
    //   parseClickEvent(message.quoteElem!.quoteMessage!);
    // } else if (message.contentType == MessageType.atText) {
    //   parseClickEvent(message.atElem!.quoteMessage!);
    // }
    if (message.isTextType || message.isAtTextType) {
      FullScreenView.show(
        context: Get.context!,
        text: message.textElem?.content ?? '',
        backgroundColor: Colors.grey.shade100,
      );
    } else {
      parseClickEvent(message);
    }
  }

  void onTapLocateQuoteMsg(Message message) {}

  /// 群聊天长按头像为@用户
  void onLongPressLeftAvatar(Message message) {
    if (isMuted || isInvalidGroup) return;
    if (isGroupChat) {
      // 不查询群成员列表
      _setAtMapping(
        userID: message.sendID!,
        nickname: message.senderNickname!,
        faceURL: message.senderFaceUrl,
      );
      var uid = message.sendID!;
      // var uname = msg.senderNickName;
      if (curMsgAtUser.contains(uid)) return;
      curMsgAtUser.add(uid);
      // 在光标出插入内容
      // 先保存光标前和后内容
      var cursor = inputCtrl.selection.base.offset;
      if (!focusNode.hasFocus) {
        focusNode.requestFocus();
        cursor = _lastCursorIndex;
      }
      if (cursor < 0) cursor = 0;
      // 光标前面的内容
      var start = inputCtrl.text.substring(0, cursor);
      // 光标后面的内容
      var end = inputCtrl.text.substring(cursor);
      var at = '@$uid ';
      inputCtrl.text = '$start$at$end';
      Logger.print('start:$start end:$end  at:$at  content:${inputCtrl.text}');
      inputCtrl.selection = TextSelection.collapsed(offset: '$start$at'.length);
      // inputCtrl.selection = TextSelection.fromPosition(TextPosition(
      //   offset: '$start$at'.length,
      // ));
      _lastCursorIndex = inputCtrl.selection.start;
    }
  }

  void onTapLeftAvatar(Message message) {
    viewUserInfo(UserInfo()
      ..userID = message.sendID
      ..nickname = message.senderNickname
      ..faceURL = message.senderFaceUrl);
  }

  void onTapRightAvatar() {
    viewUserInfo(OpenIM.iMManager.userInfo);
  }

  void clickAtText(id) async {
    var tag = await OpenIM.iMManager.conversationManager.getAtAllTag();
    if (id == tag) return;
    if (null != atUserInfoMappingMap[id]) {
      viewUserInfo(atUserInfoMappingMap[id]!);
    } else {
      viewUserInfo(UserInfo(userID: id));
    }
  }

  void viewUserInfo(UserInfo userInfo, {bool isCard = false}) {
    if (isGroupChat && !isAdminOrOwner && !isCard) {
      if (groupInfo!.lookMemberInfo != 1) {
        AppNavigator.startUserProfilePane(
          userID: userInfo.userID!,
          nickname: userInfo.nickname,
          faceURL: userInfo.faceURL,
          groupID: groupID,
          offAllWhenDelFriend: isSingleChat,
        );
      }
    } else {
      AppNavigator.startUserProfilePane(
        userID: userInfo.userID!,
        nickname: userInfo.nickname,
        faceURL: userInfo.faceURL,
        groupID: groupID,
        offAllWhenDelFriend: isSingleChat,
        forceCanAdd: isCard,
      );
    }
  }

  void clickLinkText(url, type) async {
    Logger.print('--------link  type:$type-------url: $url---');
    if (type == PatternType.at) {
      clickAtText(url);
      return;
    }
    if (await canLaunch(url)) {
      await launch(url);
    }
    // await canLaunch(url) ? await launch(url) : throw 'Could not launch $url';
  }

  /// 读取草稿
  void _readDraftText() {
    var draftText = Get.arguments['draftText'];
    Logger.print('readDraftText:$draftText');
    if (null != draftText && "" != draftText) {
      var map = json.decode(draftText!);
      String text = map['text'];
      Map<String, dynamic> atMap = map['at'];
      Logger.print('text:$text  atMap:$atMap');
      atMap.forEach((key, value) {
        if (!curMsgAtUser.contains(key)) curMsgAtUser.add(key);
        atUserNameMappingMap.putIfAbsent(key, () => value);
      });
      inputCtrl.text = text;
      inputCtrl.selection = TextSelection.fromPosition(TextPosition(
        offset: text.length,
      ));
      if (text.isNotEmpty) {
        focusNode.requestFocus();
      }
    }
  }

  /// 生成草稿draftText
  String createDraftText() {
    var atMap = <String, dynamic>{};
    for (var uid in curMsgAtUser) {
      atMap[uid] = atUserNameMappingMap[uid];
    }
    if (inputCtrl.text.isEmpty) {
      return "";
    }
    return json.encode({'text': inputCtrl.text, 'at': atMap});
  }

  /// 退出界面前处理
  exit() async {
    if (multiSelMode.value) {
      closeMultiSelMode();
      return false;
    }
    if (isShowPopMenu.value) {
      forceCloseMenuSub.add(true);
      return false;
    }
    Get.back(result: createDraftText());
    return true;
  }

  void _updateDartText(String text) {
    conversationLogic.updateDartText(
      text: text,
      conversationID: conversationInfo.conversationID,
    );
  }

  void focusNodeChanged(bool hasFocus) {
    _changeInputStatus(hasFocus);
    if (hasFocus) {
      Logger.print('focus:$hasFocus');
      scrollBottom();
    }
  }

  void copy(Message message) {
    String? content;
    final textElem = message.tagContent?.textElem;
    if (null != textElem) {
      content = textElem.content;
    } else if (message.isAtTextType) {
      content = message.atTextElem!.text;
    } else {
      content = copyTextMap[message.clientMsgID] ?? message.textElem?.content;
    }
    if (message.isNoticeType) {
      content = message.noticeContent;
    }

    if (message.isQuoteType) {
      content = message.quoteElem?.text;
    }
    if (null != content) {
      IMUtils.copy(text: content.replaceAll('\u200B', ''), showToast: false);
    }
  }

  Message indexOfMessage(int index, {bool calculate = true}) => messageList.elementAt(index);

  ValueKey itemKey(Message message) => ValueKey(message.clientMsgID!);

  @override
  void onClose() {
    messageCache.clear();
    _messageIds.clear();
    sendTypingMsg();
    _clearUnreadCount();
    // ChatGetTags.caches.removeLast();
    _unSubscribeUserOnlineStatus();
    _stopTimelineTimer();
    inputCtrl.dispose();
    focusNode.dispose();
    _audioPlayer.dispose();
    // clickSubject.close();
    forceCloseToolbox.close();
    conversationSub.cancel();
    _newMessageSubscription.cancel();
    sendStatusSub.close();
    sendProgressSub.close();
    downloadProgressSub.close();
    memberAddSub.cancel();
    memberDelSub.cancel();
    memberInfoChangedSub.cancel();
    groupInfoUpdatedSub.cancel();
    friendInfoChangedSub.cancel();
    userStatusChangedSub?.cancel();
    selfInfoUpdatedSub?.cancel();
    // signalingMessageSub?.cancel();
    forceCloseMenuSub.close();
    joinedGroupAddedSub.cancel();
    joinedGroupDeletedSub.cancel();
    connectionSub.cancel();
    // onlineStatusTimer?.cancel();
    destroyMsg();

    isInGroupSub.cancel();
    _debounce?.cancel();
    unreadMsgCountEventSubscription?.cancel();
    _disposeObserver();
    super.onClose();
  }

  String? getShowTime(Message message) {
    if (message.exMap['showTime'] == true) {
      return IMUtils.getChatTimeline(message.sendTime!);
    }
    return null;
  }

  void clearAllMessage() {
    messageList.clear();
    _messageIds.clear();
  }

  void onStartVoiceInput() {
    // SpeechToTextUtil.instance.startListening((result) {
    //   inputCtrl.text = result.recognizedWords;
    // });
  }

  void onStopVoiceInput() {
    // SpeechToTextUtil.instance.stopListening();
  }

  /// 添加表情
  void onAddEmoji(String emoji) {
    var input = inputCtrl.text;
    // 获取当前光标位置，优先使用实时的selection position
    var cursorIndex = inputCtrl.selection.baseOffset;
    // 如果selection无效，回退使用_lastCursorIndex
    if (cursorIndex < 0 || cursorIndex > input.length) {
      cursorIndex = _lastCursorIndex;
    }
    // 如果还是无效，使用文本末尾
    if (cursorIndex < 0 || cursorIndex > input.length) {
      cursorIndex = input.length;
    }

    // 在光标位置插入表情
    var part1 = input.substring(0, cursorIndex);
    var part2 = input.substring(cursorIndex);
    inputCtrl.text = '$part1$emoji$part2';

    // 更新光标位置到表情之后
    final newCursorPos = cursorIndex + emoji.length;
    _lastCursorIndex = newCursorPos;
    inputCtrl.selection = TextSelection.fromPosition(TextPosition(
      offset: newCursorPos,
    ));
  }

  /// 删除表情
  void onDeleteEmoji() {
    final input = inputCtrl.text;
    final regexEmoji =
        emojiFaces.keys.toList().join('|').replaceAll('[', '\\[').replaceAll(']', '\\]');
    final list = [regexAt, regexEmoji];
    final pattern = '(${list.toList().join('|')})';
    final atReg = RegExp(regexAt);
    final emojiReg = RegExp(regexEmoji);
    var reg = RegExp(pattern);
    var cursor = _lastCursorIndex;
    if (cursor == 0) return;
    Match? match;
    if (reg.hasMatch(input)) {
      for (var m in reg.allMatches(input)) {
        var matchText = m.group(0)!;
        var start = m.start;
        var end = start + matchText.length;
        if (end == cursor) {
          match = m;
          break;
        }
      }
    }
    var matchText = match?.group(0);
    if (matchText != null) {
      var start = match!.start;
      var end = start + matchText.length;
      if (atReg.hasMatch(matchText)) {
        String id = matchText.replaceFirst("@", "").trim();
        if (curMsgAtUser.remove(id)) {
          inputCtrl.text = input.replaceRange(start, end, '');
          cursor = start;
        } else {
          inputCtrl.text = input.replaceRange(cursor - 1, cursor, '');
          --cursor;
        }
      } else if (emojiReg.hasMatch(matchText)) {
        inputCtrl.text = input.replaceRange(start, end, "");
        cursor = start;
      } else {
        inputCtrl.text = input.replaceRange(cursor - 1, cursor, '');
        --cursor;
      }
    } else {
      inputCtrl.text = input.replaceRange(cursor - 1, cursor, '');
      --cursor;
    }
    _lastCursorIndex = cursor;
  }

  // String getSubTile() => typing.value ? StrRes.typing : onlineStatusDesc.value;
  String? get subTile => typing.value ? StrRes.typing : onlineStatusDesc.value;

  bool showOnlineStatus() => !isRobot || (!typing.value && onlineStatusDesc.isNotEmpty);

  /// 语音视频通话信息不显示读状态
  bool enabledReadStatus(Message message) {
    if (message.isNotificationType) {
      return false;
    }
    return true;
  }

  /// 处理输入框输入@字符
  String? openAtList() {
    if (groupInfo != null) {
      var cursor = inputCtrl.selection.baseOffset;
      AppNavigator.startGroupMemberList(
        groupInfo: groupInfo!,
        opType: GroupMemberOpType.at,
      )?.then((list) => _handleAtMemberList(list, cursor));
      return "@";
    }
    return null;
  }

  _handleAtMemberList(memberList, cursor) {
    if (memberList is List<GroupMembersInfo>) {
      var buffer = StringBuffer();
      for (var e in memberList) {
        _setAtMapping(
          userID: e.userID!,
          nickname: e.nickname ?? '',
          faceURL: e.faceURL,
        );
        if (!curMsgAtUser.contains(e.userID)) {
          curMsgAtUser.add(e.userID!);
          buffer.write('@${e.userID} ');
        } else {
          buffer.write('@${e.userID} ');
        }
      }
      if (cursor < 0) cursor = 0;
      // 光标前面的内容
      var start = inputCtrl.text.substring(0, cursor);
      // 光标后面的内容
      var end = inputCtrl.text.substring(cursor + 1);
      inputCtrl.text = '$start$buffer$end';
      inputCtrl.selection = TextSelection.fromPosition(TextPosition(
        offset: '$start$buffer'.length,
      ));
      _lastCursorIndex = inputCtrl.selection.start;
    } else {}
  }

  void favoriteManage() => AppNavigator.startFavoriteMange();

  void addEmoji(Message message) {
    if (message.contentType == MessageType.picture) {
      var url = message.pictureElem?.sourcePicture?.url;
      var width = message.pictureElem?.sourcePicture?.width;
      var height = message.pictureElem?.sourcePicture?.height;
      final path = message.pictureElem?.sourcePath ?? url ?? '';

      cacheLogic.addFavoriteFromUrl(path, url, width, height);
      IMViews.showToast(StrRes.addSuccessfully);
    } else if (message.contentType == MessageType.customFace) {
      var index = message.faceElem?.index;
      var data = message.faceElem?.data;
      if (-1 != index) {
      } else if (null != data) {
        var map = json.decode(data);
        var url = map['url'];
        var width = map['width'];
        var height = map['height'];
        final path = map['path'] ?? url;
        cacheLogic.addFavoriteFromUrl(path, url, width, height);
        IMViews.showToast(StrRes.addSuccessfully);
      }
    }
  }

  /// 发送自定表情
  void sendFavoritePic(int index, String url) async {
    var emoji = cacheLogic.favoriteList.elementAt(index);
    var message = await OpenIM.iMManager.messageManager.createFaceMessage(
      data: json.encode({'path': emoji.path, 'url': emoji.url, 'width': emoji.width, 'height': emoji.height}),
    );
    _sendMessage(message);
  }

  void _initChatConfig() async {
    scaleFactor.value = DataSp.getChatFontSizeFactor();
    var path = DataSp.getChatBackground(otherId) ?? '';
    if (path.isNotEmpty && (await File(path).exists())) {
      background.value = path;
    }
  }

  /// 修改聊天字体
  changeFontSize(double factor) async {
    await DataSp.putChatFontSizeFactor(factor);
    scaleFactor.value = factor;
    IMViews.showToast(StrRes.setSuccessfully);
  }

  /// 修改聊天背景
  changeBackground(String path) async {
    await DataSp.putChatBackground(otherId, path);
    background.value = path;
  }

  String get otherId => isSingleChat ? userID! : groupID!;

  /// 清除聊天背景
  clearBackground() async {
    await DataSp.clearChatBackground(otherId);
    background.value = '';
  }

  /// 拨视频或音频
  void call() {
    if (rtcIsBusy) {
      IMViews.showToast(StrRes.callingBusy);
      return;
    }

    Permissions.cameraAndMicrophone(() async {
      if (isGroupChat) {
        if (participants.isNotEmpty) {
          var confirm = await SimpleConfirmationDialog.show(
            context: Get.context!,
            content: StrRes.groupCallHint,
            confirmText: StrRes.joinIn,
          );
          if (confirm == true) {
            joinGroupCalling();
          }
          return;
        }
        IMViews.openIMGroupCallSheet(groupID!, (index) async {
          if (null != groupInfo) {
            final list = await AppNavigator.startGroupMemberList(
              groupInfo: groupInfo!,
              opType: GroupMemberOpType.call,
            );
            if (list is List<GroupMembersInfo>) {
              final uidList = list.map((e) => e.userID!).toList();
              imLogic.call(
                callObj: CallObj.group,
                callType: index == 0 ? CallType.audio : CallType.video,
                groupID: groupID?.isNotEmpty == true ? groupID : null,
                inviteeUserIDList: uidList,
              );
            }
          }
        });
      } else {
        IMViews.openIMCallSheet(nickname.value, (index) {
          imLogic.call(
            callObj: CallObj.single,
            callType: index == 0 ? CallType.audio : CallType.video,
            inviteeUserIDList: [if (isSingleChat) userID!],
          );
        });
      }
    });
  }

  /// 群消息已读预览
  void viewGroupMessageReadStatus(Message message) {
    AppNavigator.startGroupReadList(
      conversationInfo.conversationID,
      message.clientMsgID!,
    );
  }

  /// 失败重发
  void failedResend(Message message) {
    Logger.print('failedResend: ${message.clientMsgID}');
    if (message.status == MessageStatus.sending) {
      return;
    }
    sendStatusSub.addSafely(MsgStreamEv(
      id: message.clientMsgID!,
      value: MessageStatus.sending,
    ));

    Logger.print('failedResending: ${message.clientMsgID}');
    _sendMessage(message..status = MessageStatus.sending, addToUI: false);
  }

  /// 计算这条消息应该被阅读的人数
  // int getNeedReadCount(Message message) {
  //   if (isSingleChat) return 0;
  //   return groupMessageReadMembers[message.clientMsgID!]?.length ??
  //       _calNeedReadCount(message);
  // }

  /// 1，排除自己
  /// 2，获取比消息发送时间早的入群成员数
  // int _calNeedReadCount(Message message) {
  //   memberList.values.forEach((element) {
  //     if (element.userID != OpenIM.iMManager.uid) {
  //       if ((element.joinTime! * 1000) < message.sendTime!) {
  //         var list = groupMessageReadMembers[message.clientMsgID!] ?? [];
  //         if (!list.contains(element.userID)) {
  //           groupMessageReadMembers[message.clientMsgID!] = list
  //             ..add(element.userID!);
  //         }
  //       }
  //     }
  //   });
  //   return groupMessageReadMembers[message.clientMsgID!]?.length ?? 0;
  // }

  int readTime(Message message) {
    var isPrivate = message.attachedInfoElem?.isPrivateChat ?? false;
    var burnDuration = message.attachedInfoElem?.burnDuration ?? 30;
    burnDuration = burnDuration > 0 ? burnDuration : 30;
    if (isPrivate) {
      // var hasReadTime = message.attachedInfoElem!.hasReadTime ?? 0;
      var hasReadTime = message.hasReadTime ?? 0;
      if (hasReadTime > 0) {
        var end = hasReadTime + (burnDuration * 1000);

        var diff = (end - _timestamp) ~/ 1000;

        if (diff > 0) {
          privateMessageList.addIf(() => !privateMessageList.contains(message), message);
        }
        return diff < 0 ? 0 : diff;
      }
    }
    return 0;
  }

  static int get _timestamp => DateTime.now().millisecondsSinceEpoch;

  /// 退出页面即把所有当前已展示的私聊消息删除
  void destroyMsg() {
    for (var message in privateMessageList) {
      OpenIM.iMManager.messageManager.deleteMessageFromLocalAndSvr(
        conversationID: conversationInfo.conversationID,
        clientMsgID: message.clientMsgID!,
      );
    }
  }

  /// 获取个人群资料
  Future _queryMyGroupMemberInfo() async {
    if (!isGroupChat) {
      return;
    }
    var list = await OpenIM.iMManager.groupManager.getGroupMembersInfo(
      groupID: groupID!,
      userIDList: [OpenIM.iMManager.userID],
    );
    groupMembersInfo = list.firstOrNull;
    groupMemberRoleLevel.value = groupMembersInfo?.roleLevel ?? GroupRoleLevel.member;
    muteEndTime.value = groupMembersInfo?.muteEndTime ?? 0;
    if (null != groupMembersInfo) {
      memberUpdateInfoMap[OpenIM.iMManager.userID] = groupMembersInfo!;
    }
    _mutedClearAllInput();

    return;
  }

  Future _queryOwnerAndAdmin() async {
    if (isGroupChat) {
      ownerAndAdmin = await OpenIM.iMManager.groupManager
          .getGroupMemberList(groupID: groupID!, filter: 5, count: 20);
    }
    return;
  }

  void _isJoinedGroup() async {
    if (!isGroupChat) {
      return;
    }
    isInGroup.value = await OpenIM.iMManager.groupManager.isJoinedGroup(
      groupID: groupID!,
    );
    if (!isInGroup.value) {
      return;
    }
    _queryGroupInfo();
    _queryOwnerAndAdmin();
  }

  /// 获取群资料
  void _queryGroupInfo() async {
    if (!isGroupChat) {
      return;
    }
    var list = await OpenIM.iMManager.groupManager.getGroupsInfo(
      groupIDList: [groupID!],
    );
    groupInfo = list.firstOrNull;
    groupOwnerID = groupInfo?.ownerUserID;
    if (_isExitUnreadAnnouncement()) {
      final fakeMsg = fakeAnnouncementMessage(groupInfo!);
      pinnedMsgs.insert(0, fakeMsg);
    }
    groupMutedStatus.value = groupInfo?.status ?? 0;
    if (null != groupInfo?.memberCount) {
      memberCount.value = groupInfo!.memberCount!;
    }
    _queryMyGroupMemberInfo();
    _queryGroupCallingInfo();
  }

  /// 禁言权限
  /// 1普通成员, 2群主，3管理员
  bool get havePermissionMute =>
      isGroupChat &&
      (groupInfo?.ownerUserID ==
          OpenIM.iMManager.userID /*||
          groupMembersInfo?.roleLevel == 2*/
      );

  /// 通知类型消息
  bool isNotificationType(Message message) => message.contentType! >= 1000;

  Map<String, String> getAtMapping(Message message) {
    return {};
  }

  void _queryUserOnlineStatus() {
    if (isSingleChat) {
      OpenIM.iMManager.userManager.subscribeUsersStatus([userID!]).then((value) {
        final status = value.firstWhereOrNull((element) => element.userID == userID);
        _configUserStatusChanged(status);
      });
      userStatusChangedSub = imLogic.userStatusChangedSubject.listen((value) {
        if (value.userID == userID) {
          _configUserStatusChanged(value);
        }
      });
    }
  }

  void _unSubscribeUserOnlineStatus() {
    if (isSingleChat) {
      OpenIM.iMManager.userManager.unsubscribeUsersStatus([userID!]);
    }
  }

  void _configUserStatusChanged(UserStatusInfo? status) {
    if (isRobot) {
      return;
    }
    if (status != null) {
      onlineStatus.value = status.status == 1;
      onlineStatusDesc.value = status.status == 0
          ? StrRes.offline
          : _onlineStatusDes(status.platformIDs!) + StrRes.online;
    }
  }

  String _onlineStatusDes(List<int> plamtforms) {
    var des = <String>[];
    for (final platform in plamtforms) {
      switch (platform) {
        case 1:
          des.add('iOS');
          break;
        case 2:
          des.add('Android');
          break;
        case 3:
          des.add('Windows');
          break;
        case 4:
          des.add('Mac');
          break;
        case 5:
          des.add('Web');
          break;
        case 6:
          des.add('mini_web');
          break;
        case 7:
          des.add('Linux');
          break;
        case 8:
          des.add('Android_pad');
          break;
        case 9:
          des.add('iPad');
          break;
        case 10:
          des.add('Admin');
          break;
        case 11:
          des.add('HarmonyOS');
          break;
        default:
      }
    }

    return des.join('/');
  }

  /// 搜索定位消息位置
  void lockMessageLocation(Message message) {
    // var upList = list.sublist(0, 15);
    // var downList = list.sublist(15);
    // messageList.assignAll(downList);
    // WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
    //   scrollController.jumpTo(scrollController.position.maxScrollExtent - 50);
    //   messageList.insertAll(0, upList);
    // });
  }

  void _checkInBlacklist() async {
    if (userID != null) {
      var list = await OpenIM.iMManager.friendshipManager.getBlacklist();
      var user = list.firstWhereOrNull((e) => e.userID == userID);
      isInBlacklist.value = user != null;
    }
  }

  void _setAtMapping({
    required String userID,
    required String nickname,
    String? faceURL,
  }) {
    atUserNameMappingMap[userID] = nickname;
    atUserInfoMappingMap[userID] = UserInfo(
      userID: userID,
      nickname: nickname,
      faceURL: faceURL,
    );
    // DataSp.putAtUserMap(groupID!, atUserNameMappingMap);
  }

  /// 未超过24小时
  bool isExceed24H(Message message) {
    int milliseconds = message.sendTime!;
    return !DateUtil.isToday(milliseconds);
  }

  bool isPlaySound(Message message) {
    return currentPlayClientMsgID.value == message.clientMsgID!;
  }

  void _initPlayListener() {
    _audioPlayer.playerStateStream.listen((state) {
      switch (state.processingState) {
        case ProcessingState.idle:
        case ProcessingState.loading:
        case ProcessingState.buffering:
        case ProcessingState.ready:
          break;
        case ProcessingState.completed:
          currentPlayClientMsgID.value = "";
          break;
      }
    });
  }

  /// 播放语音消息
  void _playVoiceMessage(Message message) async {
    var isClickSame = currentPlayClientMsgID.value == message.clientMsgID;
    if (_audioPlayer.playerState.playing) {
      currentPlayClientMsgID.value = "";
      _audioPlayer.stop();
    }
    if (!isClickSame) {
      bool isValid = await _initVoiceSource(message);
      if (isValid) {
        _audioPlayer.setVolume(rtcIsBusy ? 0 : 1.0);
        _audioPlayer.seek(Duration.zero);
        _audioPlayer.play();
        currentPlayClientMsgID.value = message.clientMsgID!;

        // 记录语音消息点击
        if (message.clientMsgID != null) {
          IMUtils.recordVoiceMessageClick(message.clientMsgID!);
        }
      }
    }
  }

  void stopVoice() {
    if (_audioPlayer.playerState.playing) {
      currentPlayClientMsgID.value = '';
      _audioPlayer.stop();
    }
  }

  /// 语音消息资源处理
  Future<bool> _initVoiceSource(Message message) async {
    bool isReceived = message.sendID != OpenIM.iMManager.userID;
    String? path = message.soundElem?.soundPath;
    String? url = message.soundElem?.sourceUrl;
    bool isExistSource = false;
    if (isReceived) {
      if (null != url && url.trim().isNotEmpty) {
        isExistSource = true;
        _audioPlayer.setUrl(url);
      }
    } else {
      bool existFile = false;
      if (path != null && path.trim().isNotEmpty) {
        var file = File(path);
        existFile = await file.exists();
      }
      if (existFile) {
        isExistSource = true;
        _audioPlayer.setFilePath(path!);
      } else if (null != url && url.trim().isNotEmpty) {
        isExistSource = true;
        _audioPlayer.setUrl(url);
      }
    }
    return isExistSource;
  }

  /// 显示菜单屏蔽消息插入
  void onPopMenuShowChanged(show) {
    isShowPopMenu.value = show;
    // if (!show && scrollingCacheMessageList.isNotEmpty) {
    //   messageList.addAll(scrollingCacheMessageList);
    //   scrollingCacheMessageList.clear();
    // }
  }

  String? getNewestNickname(Message message) {
    if (isSingleChat) {
      return message.sendID == userID ? nickname.value : message.senderNickname;
    }
    // return memberUpdateInfoMap[message.sendID]?.nickname;
    return message.senderNickname;
  }

  String? getNewestFaceURL(Message message) {
    // if (isSingleChat) return faceUrl.value;
    // return memberUpdateInfoMap[message.sendID]?.faceURL;
    return message.senderFaceUrl;
  }

  /// 存在未读的公告
  bool _isExitUnreadAnnouncement() => conversationInfo.groupAtType == GroupAtType.groupNotification;

  /// 是公告消息
  bool isAnnouncementMessage(message) => _getAnnouncement(message) != null;

  String? _getAnnouncement(Message message) {
    if (message.contentType! == MessageType.groupInfoSetAnnouncementNotification) {
      final elem = message.notificationElem!;
      final map = json.decode(elem.detail!);
      final notification = GroupNotification.fromJson(map);
      if (notification.group?.notification != null &&
          notification.group!.notification!.isNotEmpty) {
        return notification.group!.notification!;
      }
    }
    return null;
  }

  Message fakeAnnouncementMessage(GroupInfo group) {
    final not = GroupNotification(group: group);
    final elem = NotificationElem(detail: jsonEncode(not));

    return Message(
        notificationElem: elem, contentType: MessageType.groupInfoSetAnnouncementNotification);
  }

  /// 新消息为公告
  void _parseAnnouncement(Message message) {
    var ac = _getAnnouncement(message);
    if (null != ac) {
      pinnedMsgs.insert(0, message);
      groupInfo?.notification = ac;
    }
  }

  /// 预览公告
  void previewGroupAnnouncement() async {
    if (null != groupInfo) {
      pinnedMsgs
          .removeWhere((e) => e.contentType == MessageType.groupInfoSetAnnouncementNotification);
      await AppNavigator.startEditGroupAnnouncement(groupID: groupInfo!.groupID);
    }
  }

  void closeGroupAnnouncement() {
    if (null != groupInfo) {
      pinnedMsgs
          .removeWhere((e) => e.contentType == MessageType.groupInfoSetAnnouncementNotification);
    }
  }

  bool get isInvalidGroup => !isInGroup.value && isGroupChat;

  /// 禁言条件；全员禁言，单独禁言，拉入黑名单
  bool get isMuted => isGroupMuted || isUserMuted || isInBlacklist.value;

  /// 群开启禁言，排除群组跟管理员
  bool get isGroupMuted =>
      groupMutedStatus.value == 3 && groupMemberRoleLevel.value == GroupRoleLevel.member;

  /// 单独被禁言
  bool get isUserMuted => muteEndTime.value > DateTime.now().millisecondsSinceEpoch;

  /// 禁言提示
  String? get hintText => isInBlacklist.value
      ? StrRes.otherBeAddedBlacklist
      : (isMuted ? (isGroupMuted ? StrRes.groupMuted : StrRes.youMuted) : null);

  /// 禁言后 清除所有状态
  void _mutedClearAllInput() {
    if (isMuted) {
      inputCtrl.clear();
      setQuoteMsg(null);
      closeMultiSelMode();
    }
  }

  /// 清除所有强提醒
  void _resetGroupAtType() {
    // 删除所有@标识/公告标识
    if (conversationInfo.groupAtType != GroupAtType.atNormal) {
      OpenIM.iMManager.conversationManager.resetConversationGroupAtType(
        conversationID: conversationInfo.conversationID,
      );
    }
  }

  /// 消息撤回（新版本）
  void revokeMsgV2(BuildContext context, Message message) async {
    bool canRevoke = false;
    FocusManager().primaryFocus?.unfocus();
    await Future.delayed(500.milliseconds);

    // Use simple overlay-based dialog to avoid Navigator issues
    var result = await SimpleConfirmationDialog.show(
      context: context,
      content: StrRes.revokeMessageHint,
    );
    if (result == true) {
      if (isGroupChat) {
        // 群组或管理员撤回群成员的消息
        var list = await LoadingView.singleton
            .wrap(asyncFunction: () => OpenIM.iMManager.groupManager.getGroupMemberList(groupID: groupID!, filter: 5));
        var sender = list.firstWhereOrNull((e) => e.userID == message.sendID);
        var revoker = list.firstWhereOrNull((e) => e.userID == OpenIM.iMManager.userID);

        if (message.sendID == OpenIM.iMManager.userID) {
          canRevoke = true;
        } else if (revoker != null && sender == null) {
          // 撤回者是管理员或群主 可以撤回
          canRevoke = true;
        } else if (revoker == null && sender != null) {
          // 撤回者是普通成员，但发送者是管理员或群主 不可撤回
          canRevoke = false;
        } else if (revoker != null && sender != null) {
          if (revoker.roleLevel == sender.roleLevel) {
            // 同级别 不可撤回
            canRevoke = false;
          } else if (revoker.roleLevel == GroupRoleLevel.owner) {
            // 撤回者是群主  可撤回
            canRevoke = true;
          } else {
            // 不可撤回
            canRevoke = false;
          }
        } else {
          // 都是成员 不可撤回
          canRevoke = false;
        }
      } else {
        if (message.sendID == OpenIM.iMManager.userID) {
          canRevoke = true;
        }
      }
    }

    if (canRevoke) {
      _sdkRevokeMessage(message);
    }
  }

  void _sdkRevokeMessage(Message message) async {
    try {
      if (_audioPlayer.playing) {
        _audioPlayer.stop();
      }

      await LoadingView.singleton.wrap(
        asyncFunction: () => OpenIM.iMManager.messageManager.revokeMessage(
          conversationID: conversationInfo.conversationID,
          clientMsgID: message.clientMsgID!,
        ),
      );
      message.contentType = MessageType.revokeMessageNotification;
      message.notificationElem = NotificationElem(detail: jsonEncode(_buildRevokeInfo(message)));
      formatQuoteMessage(message.clientMsgID!);
      messageList.refresh();
    } catch (e) {
      IMViews.showToast(StrRes.operateAgain);
    }
  }

  RevokedInfo _buildRevokeInfo(Message message) {
    return RevokedInfo.fromJson({
      'revokerID': OpenIM.iMManager.userInfo.userID,
      'revokerRole': 0,
      'revokerNickname': OpenIM.iMManager.userInfo.nickname,
      'clientMsgID': message.clientMsgID,
      'revokeTime': 0,
      'sourceMessageSendTime': 0,
      'sourceMessageSendID': message.sendID,
      'sourceMessageSenderNickname': message.senderNickname,
      'sessionType': message.sessionType,
    });
  }

  /// 复制菜单
  bool showCopyMenu(Message message) {
    return message.isTextType ||
        message.isAtTextType ||
        message.isTagTextType ||
        message.isNoticeType ||
        message.isQuoteType;
  }

  /// 删除菜单
  bool showDelMenu(Message message) {
    return !message.isPrivateType;
  }

  /// 转发菜单
  bool showForwardMenu(Message message) {
    if (message.status != MessageStatus.succeeded) {
      return false;
    }
    if (message.isNotificationType || message.isPrivateType || message.isTagVoiceType) {
      return false;
    }
    return true;
  }

  /// 回复菜单
  bool showReplyMenu(Message message) {
    if (message.status != MessageStatus.succeeded) {
      return false;
    }
    return message.isTextType ||
        message.isVideoType ||
        message.isPictureType ||
        message.isLocationType ||
        message.isFileType ||
        message.isQuoteType ||
        message.isCardType ||
        message.isAtTextType ||
        message.isTagTextType ||
        message.isCustomFaceType;
  }

  /// 是否显示撤回消息菜单
  bool showRevokeMenu(Message message) {
    if (message.status != MessageStatus.succeeded ||
        message.isNotificationType ||
        isExceed24H(message) && isSingleChat) {
      return false;
    }
    if (isGroupChat) {
      // for (var element in ownerAndAdmin) {
      //   printInfo(
      //       info: 'show revoke menu : ${element.nickname} - ${element.userID}');
      // }
      // 群主或管理员
      if (groupMemberRoleLevel.value == GroupRoleLevel.owner ||
          (groupMemberRoleLevel.value == GroupRoleLevel.admin &&
              ownerAndAdmin.firstWhereOrNull((element) => element.userID == message.sendID) ==
                  null)) {
        return true;
      }
    }
    if (message.sendID == OpenIM.iMManager.userID) {
      if (DateTime.now().millisecondsSinceEpoch - (message.sendTime ??= 0) < (1000 * 60 * 5)) {
        return true;
      }
    }
    return false;
  }

  /// 多选菜单
  bool showMultiMenu(Message message) {
    if (message.status != MessageStatus.succeeded || isPreviewChat) {
      return false;
    }
    if (message.isNotificationType || message.isPrivateType) {
      return false;
    }
    return true;
  }

  /// 添加表情菜单
  bool showAddEmojiMenu(Message message) {
    if (message.isPrivateType || message.status != MessageStatus.succeeded) {
      return false;
    }

    if (!message.isPictureType && !message.isCustomFaceType) {
      return false;
    }

    if (message.isPictureType && message.pictureElem?.sourcePicture?.url != null) {
      return !cacheLogic.isEmojiExist(message.pictureElem!.sourcePicture!.url!);
    }

    if (message.isCustomFaceType && message.faceElem?.data != null) {
      final map = json.decode(message.faceElem!.data!);
      final url = map['url'];

      if (url != null) {
        return !cacheLogic.isEmojiExist(url);
      }
    }

    return true;
  }

  bool showEditMessageMenu(Message message) {
    return false;
  }

  bool showCheckbox(Message message) {
    if (message.isNotificationType ||
        message.isPrivateType ||
        message.status != MessageStatus.succeeded) {
      return false;
    }
    return multiSelMode.value;
  }

  WillPopCallback? willPop() {
    return multiSelMode.value || isShowPopMenu.value ? () async => exit() : null;
  }

  void expandCallingMemberPanel() {
    showCallingMember.value = !showCallingMember.value;
  }

  void _queryGroupCallingInfo() async {}

  void joinGroupCalling() async {
    if (rtcIsBusy) {
      IMViews.showToast(StrRes.callingBusy);
      return;
    }
    final certificate = await LoadingView.singleton.wrap(
      asyncFunction: () => OpenIM.iMManager.signalingManager.signalingGetTokenByRoomID(
        roomID: roomCallingInfo!.roomID!,
      ),
    );
    final info = roomCallingInfo!.invitation!;

    imLogic.join(
      groupID: info.groupID,
      invitation: info,
      certificate: certificate,
    );
  }

  /// 当滚动位置处于底部时，将新镇的消息放入列表里
  void onScrollToTop() {
    // if (scrollingCacheMessageList.isNotEmpty) {
    //   messageList.addAll(scrollingCacheMessageList);
    //   scrollingCacheMessageList.clear();
    // }
  }

  String get markText {
    String? phoneNumber = imLogic.userInfo.value.phoneNumber;
    if (phoneNumber != null) {
      int start = phoneNumber.length > 4 ? phoneNumber.length - 4 : 0;
      final sub = phoneNumber.substring(start);
      return "${OpenIM.iMManager.userInfo.nickname!}$sub";
    }
    return OpenIM.iMManager.userInfo.nickname ?? '';
  }

  bool isFailedHintMessage(Message message) {
    if (message.contentType == MessageType.custom) {
      var data = message.customElem!.data;
      var map = json.decode(data!);
      var customType = map['customType'];
      return customType == CustomMessageType.deletedByFriend ||
          customType == CustomMessageType.blockedByFriend;
    }
    return false;
  }

  void sendFriendVerification() => AppNavigator.startSendVerificationApplication(userID: userID);

  void _setSdkSyncDataListener() {
    connectionSub = imLogic.imSdkStatusPublishSubject.listen((value) {
      syncStatus.value = value.status;
      // -1 链接失败 0 链接中 1 链接成功 2 同步开始 3 同步结束 4 同步错误
      if (value.status == IMSdkStatus.syncStart) {
        _isStartSyncing = true;
      } else if (value.status == IMSdkStatus.syncEnded) {
        if (/*_isReceivedMessageWhenSyncing &&*/ _isStartSyncing) {
          _isReceivedMessageWhenSyncing = false;
          _isStartSyncing = false;
          _loadHistoryForSyncEnd();
        }
      } else if (value.status == IMSdkStatus.syncFailed) {
        _isReceivedMessageWhenSyncing = false;
        _isStartSyncing = false;
      }
    });
  }

  bool get isSyncFailed => syncStatus.value == IMSdkStatus.syncFailed;

  String? get syncStatusStr {
    switch (syncStatus.value) {
      case IMSdkStatus.syncStart:
      case IMSdkStatus.synchronizing:
        return StrRes.synchronizing;
      case IMSdkStatus.syncFailed:
        return StrRes.syncFailed;
      default:
        return null;
    }
  }

  bool showBubbleBg(Message message) {
    return !isNotificationType(message) &&
        !isFailedHintMessage(message) &&
        !isRevokeMessage(message);
  }

  bool isRevokeMessage(Message message) {
    return message.contentType == MessageType.revokeMessageNotification;
  }

  void markRevokedMessage(Message message) {
    if (message.contentType == MessageType.text ||
        message.contentType == MessageType.atText ||
        message.isQuoteType) {
      revokedTextMessage[message.clientMsgID!] = jsonEncode(message);
    }
  }

  Future<bool> onScrollToBottomLoad() async {
    final msgs = await messageCache.fetchMessages(
      count: _pageSize,
    );

    _getGroupInfoAfterLoadMessage();

    if (msgs.isEmpty) {
      return false;
    }

    final filtered = msgs.where((msg) => !_isBeDeleteMessage(msg)).toList();
    _formatQuoteRevokeMessage(filtered);

    // Use lock to prevent concurrent modification
    await _messageListLock.synchronized(() {
      // Filter out messages that already exist in the list
      final newMessages = <Message>[];
      for (final msg in filtered) {
        final msgId = msg.clientMsgID ?? '';
        if (msgId.isNotEmpty && !_messageIds.contains(msgId)) {
          newMessages.add(msg);
          _messageIds.add(msgId);
        }
      }

      if (newMessages.isNotEmpty) {
        chatObserver.standby(changeCount: newMessages.length);
        messageList.addAll(newMessages);
      }
    });

    return messageCache.hasMore;
  }

  Future<void> _loadMoreHistory() async {
    final msgs = await messageCache.fetchMessages(
      count: _pageSize,
      fetchFromDB: _isLocateQuoteMsg,
    );

    if (msgs.isEmpty) return;

    final filtered = msgs.where((msg) => !_isBeDeleteMessage(msg)).toList();
    _formatQuoteRevokeMessage(filtered);

    // Use lock to prevent concurrent modification
    await _messageListLock.synchronized(() {
      // Filter out duplicates
      final newMessages = <Message>[];
      for (final msg in filtered) {
        final msgId = msg.clientMsgID ?? '';
        if (msgId.isNotEmpty && !_messageIds.contains(msgId)) {
          newMessages.add(msg);
          _messageIds.add(msgId);
        }
      }

      if (newMessages.isNotEmpty) {
        chatObserver.standby(changeCount: newMessages.length);
        messageList.addAll(newMessages);
      }
    });
  }

  Future<int> _loadNewestHistory() async {
    final msgs = await messageCache.fetchMessages(
      count: _pageSize,
      reverse: true,
      fetchFromDB: _isLocateQuoteMsg,
    );
    final filtered = msgs.where((msg) => !_isBeDeleteMessage(msg)).toList();
    _formatQuoteRevokeMessage(filtered);

    int addedCount = 0;

    // Use lock to prevent concurrent modification
    await _messageListLock.synchronized(() {
      // Filter out duplicates
      final newMessages = <Message>[];
      for (final msg in filtered) {
        final msgId = msg.clientMsgID ?? '';
        if (msgId.isNotEmpty && !_messageIds.contains(msgId)) {
          newMessages.add(msg);
          _messageIds.add(msgId);
        }
      }

      addedCount = newMessages.length;

      if (newMessages.isNotEmpty) {
        chatObserver.fixedPositionOffset = -1;
        chatObserver.standby(changeCount: newMessages.length);
        cacheExtentWhenLocateQuoteMsg = newMessages.length * 200 + 200;
        messageList.insertAll(0, newMessages);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      chatObserver.fixedPositionOffset = 5;
    });

    return addedCount;
  }

  Future<void> _loadHistoryForSyncEnd() async {
    if (_isLocateQuoteMsg) {
      return;
    }
    final msgs = await messageCache.fetchMessages(
      count: _pageSize,
      refresh: true,
    );

    if (msgs.isEmpty) return;

    final filtered = msgs.where((msg) => !_isBeDeleteMessage(msg)).toList();
    _formatQuoteRevokeMessage(filtered);
    final offset =
        (scrollController.hasClients && scrollController.positions.length == 1) ? scrollController.offset : 0.0;

    // Use lock to prevent concurrent modification
    await _messageListLock.synchronized(() {
      chatObserver.standby(changeCount: filtered.length);
      messageList.assignAll(filtered);

      // Rebuild the message ID set
      _messageIds.clear();
      for (final msg in filtered) {
        final msgId = msg.clientMsgID ?? '';
        if (msgId.isNotEmpty) {
          _messageIds.add(msgId);
        }
      }
    });

    if (scrollController.hasClients) {
      scrollController.jumpTo(offset);
    }
  }

  bool _isBeDeleteMessage(Message message) {
    final isPrivate = message.attachedInfoElem?.isPrivateChat ?? false;
    final hasReadTime = message.hasReadTime ?? 0;
    if (isPrivate && hasReadTime > 0) {
      return readTime(message) <= 0;
    }
    return false;
  }

  void _formatQuoteRevokeMessage(List<Message> list) {
    final msgs = list.where((msg) => msg.contentType == MessageType.quote).toList();

    for (final message in msgs) {
      final quoteMessage = message.quoteMessage;
      final isBurnAfterReadingDelete = quoteMessage?.attachedInfoElem?.isPrivateChat == true &&
          !list.any((msg) => msg.clientMsgID == quoteMessage?.clientMsgID);
      if (quoteMessage?.contentType != MessageType.revokeMessageNotification && !isBurnAfterReadingDelete) {
        continue;
      }

      final textEelemt = quoteMessage?.textElem ?? TextElem();
      textEelemt.content = isBurnAfterReadingDelete ? StrRes.quoteContentBeDeleted : StrRes.quoteContentBeRevoked;
      message.quoteMessage?.textElem = textEelemt;
      message.quoteMessage?.contentType =
          isBurnAfterReadingDelete ? MessageType.burnAfterReadingNotification : MessageType.revokeMessageNotification;
    }
  }

  void _getGroupInfoAfterLoadMessage() {
    if (isGroupChat && ownerAndAdmin.isEmpty) {
      _isJoinedGroup();
    } else {
      _checkInBlacklist();
    }
  }

  /// 推荐好友名片
  recommendFriendCarte(UserInfo userInfo) async {
    final result = await AppNavigator.startSelectContacts(
      action: SelAction.recommend,
      ex: '[${StrRes.carte}]${userInfo.nickname}',
    );
    if (null != result) {
      final customEx = result['customEx'];
      final checkedList = result['checkedList'];
      for (var info in checkedList) {
        final userID = IMUtils.convertCheckedToUserID(info);
        final groupID = IMUtils.convertCheckedToGroupID(info);
        if (customEx is String && customEx.isNotEmpty) {
          // 推荐备注消息
          _sendMessage(
            await OpenIM.iMManager.messageManager.createTextMessage(
              text: customEx,
            ),
            userId: userID,
            groupId: groupID,
          );
        }
        // 名片消息
        _sendMessage(
          await OpenIM.iMManager.messageManager.createCardMessage(
            userID: userInfo.userID!,
            nickname: userInfo.nickname ?? '',
            faceURL: userInfo.faceURL,
          ),
          userId: userID,
          groupId: groupID,
        );
      }
    }
  }

  void joinMeeting(Message msg) {}

  @override
  void onDetached() {
    // TODO: implement onDetached
  }

  @override
  void onHidden() {
    // TODO: implement onHidden
  }

  @override
  void onInactive() {
    // TODO: implement onInactive
  }

  @override
  void onPaused() {
    // TODO: implement onPaused
  }

  @override
  void onResumed() {
    _loadHistoryForSyncEnd();
  }
}
