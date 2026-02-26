import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:openim_live/openim_live.dart';
import 'package:permission_handler/permission_handler.dart';

import '../cache/friend_cache.dart';
import '../cache/friend_applications_cache.dart';
import '../cache/group_applications_cache.dart';
import '../im_callback.dart';

class IMController extends GetxController with IMCallback, OpenIMLive {
  late Rx<UserFullInfo> userInfo;
  late String atAllTag;
  late GroupApplicationsCache groupApplicationsCache;
  late FriendApplicationsCache friendApplicationsCache;
  late FriendCache friendCache;

  // Initialization state flags to prevent redundant SDK initialization
  bool _isInitializing = false;
  bool _isInitialized = false;

  @override
  void onClose() {
    super.close();
    onCloseLive();
    super.onClose();
  }

  @override
  void onInit() async {
    super.onInit();
    onInitLive();
    // Initialize caches
    groupApplicationsCache = Get.put(GroupApplicationsCache());
    friendApplicationsCache = Get.put(FriendApplicationsCache());
    friendCache = Get.put(FriendCache());
    // Initialize SDK
    WidgetsBinding.instance.addPostFrameCallback((_) => initOpenIM());
  }

  void initOpenIM({bool resetStatus = false}) async {
    if (resetStatus) {
      _isInitializing = false;
      _isInitialized = false;
    }
    // Prevent concurrent or redundant initialization
    if (_isInitializing || _isInitialized) {
      Logger.print('SDK already initializing or initialized, skipping...');
      return;
    }

    _isInitializing = true;

    try {
      final initialized = await OpenIM.iMManager.initSDK(
        platformID: await IMUtils.getPlatform(),
        apiAddr: Config.imApiUrl,
        wsAddr: Config.imWsUrl,
        dataDir: Config.cachePath,
        logLevel: Config.logLevel,
        logFilePath: Config.cachePath,
        listener: OnConnectListener(
          onConnecting: () {
            imSdkStatus(IMSdkStatus.connecting);
          },
          onConnectFailed: (code, error) {
            imSdkStatus(IMSdkStatus.connectionFailed);
          },
          onConnectSuccess: () {
            imSdkStatus(IMSdkStatus.connectionSucceeded);
          },
          onKickedOffline: kickedOffline,
          onUserTokenExpired: userTokenExpired,
          onUserTokenInvalid: userTokenInvalid,
        ),
      );
      // Set listener
      OpenIM.iMManager
        ..setUploadLogsListener(OnUploadLogsListener(onUploadProgress: uploadLogsProgress))
        //
        ..userManager.setUserListener(OnUserListener(
            onSelfInfoUpdated: (u) {
              selfInfoUpdated(u);

              userInfo.update((val) {
                val?.nickname = u.nickname;
                val?.faceURL = u.faceURL;
                val?.remark = u.remark;
                val?.ex = u.ex;
                val?.globalRecvMsgOpt = u.globalRecvMsgOpt;
              });
              // _queryMyFullInfo();
            },
            onUserStatusChanged: userStausChanged))
        // Add message listener (remove when not in use)
        ..messageManager.setAdvancedMsgListener(OnAdvancedMsgListener(
          onRecvC2CReadReceipt: recvC2CMessageReadReceipt,
          onRecvNewMessage: recvNewMessage,
          onNewRecvMessageRevoked: recvMessageRevoked,
          onRecvOfflineNewMessage: recvOfflineMessage,
          onMsgDeleted: messageDeleted,
        ))

        // Set up message sending progress listener
        ..messageManager.setMsgSendProgressListener(OnMsgSendProgressListener(
          onProgress: progressCallback,
        ))
        // Set up friend relationship listener
        ..friendshipManager.setFriendshipListener(OnFriendshipListener(
          onBlackAdded: blacklistAdded,
          onBlackDeleted: blacklistDeleted,
          onFriendApplicationAccepted: friendApplicationAccepted,
          onFriendApplicationAdded: friendApplicationAdded,
          onFriendApplicationDeleted: friendApplicationDeleted,
          onFriendApplicationRejected: friendApplicationRejected,
          onFriendInfoChanged: friendInfoChanged,
          onFriendAdded: friendAdded,
          onFriendDeleted: friendDeleted,
        ))

        // Set up conversation listener
        ..conversationManager.setConversationListener(OnConversationListener(
            onConversationChanged: conversationChanged,
            onNewConversation: newConversation,
            onTotalUnreadMessageCountChanged: totalUnreadMsgCountChanged,
            onInputStatusChanged: inputStateChanged,
            onSyncServerFailed: (reInstall) {
              imSdkStatus(IMSdkStatus.syncFailed, reInstall: reInstall ?? false);
            },
            onSyncServerFinish: (reInstall) {
              imSdkStatus(IMSdkStatus.syncEnded, reInstall: reInstall ?? false);
              if (Platform.isAndroid) {
                Permissions.request([Permission.systemAlertWindow]);
              }
            },
            onSyncServerStart: (reInstall) {
              imSdkStatus(IMSdkStatus.syncStart, reInstall: reInstall ?? false);
            },
            onSyncServerProgress: (progress) {
              imSdkStatus(IMSdkStatus.syncProgress, progress: progress);
            }))

        // Set up group listener
        ..groupManager.setGroupListener(OnGroupListener(
          onGroupApplicationAccepted: groupApplicationAccepted,
          onGroupApplicationAdded: groupApplicationAdded,
          onGroupApplicationDeleted: groupApplicationDeleted,
          onGroupApplicationRejected: groupApplicationRejected,
          onGroupInfoChanged: groupInfoChanged,
          onGroupMemberAdded: groupMemberAdded,
          onGroupMemberDeleted: groupMemberDeleted,
          onGroupMemberInfoChanged: groupMemberInfoChanged,
          onJoinedGroupAdded: joinedGroupAdded,
          onJoinedGroupDeleted: joinedGroupDeleted,
        ))
        // Set up signaling listener
        ..signalingManager.setSignalingListener(OnSignalingListener(
          onInvitationCancelled: invitationCancelled,
          onInvitationTimeout: invitationTimeout,
          onInviteeAccepted: inviteeAccepted,
          onInviteeRejected: inviteeRejected,
          onReceiveNewInvitation: receiveNewInvitation,
          onInviteeAcceptedByOtherDevice: inviteeAcceptedByOtherDevice,
          onInviteeRejectedByOtherDevice: inviteeRejectedByOtherDevice,
          onHangup: beHangup,
          onRoomParticipantConnected: roomParticipantConnected,
          onRoomParticipantDisconnected: roomParticipantDisconnected,
        ));

      _isInitialized = initialized;
      Logger().sdkIsInitialized = initialized;
      initializedSubject.sink.add(initialized);
    } finally {
      _isInitializing = false;
    }
  }

  Future login(String userID, String token) async {
    try {
      var user = await OpenIM.iMManager.login(
        userID: userID,
        token: token,
        defaultValue: () async => UserInfo(userID: userID),
      );
      ApiService().setToken(token);
      userInfo = UserFullInfo.fromJson(user.toJson()).obs;
      _queryMyFullInfo();
      _queryAtAllTag();
      _preloadApplications();
    } catch (e, s) {
      Logger.print('e: $e  s:$s');
      await _handleLoginRepeatError(e);
      // rethrow;
      return Future.error(e, s);
    }
  }

  Future logout() {
    // Reset initialization flag to allow re-initialization after logout
    _isInitialized = false;
    return OpenIM.iMManager.logout();
  }

  /// @所有人ID
  void _queryAtAllTag() async {
    atAllTag = OpenIM.iMManager.conversationManager.atAllTag;
    // atAllTag = await OpenIM.iMManager.conversationManager.getAtAllTag();
  }

  void _queryMyFullInfo() async {
    final data = await Apis.queryMyFullInfo();
    if (data is UserFullInfo) {
      userInfo.update((val) {
        val?.allowAddFriend = data.allowAddFriend;
        val?.allowBeep = data.allowBeep;
        val?.allowVibration = data.allowVibration;
        val?.nickname = data.nickname;
        val?.faceURL = data.faceURL;
        val?.phoneNumber = data.phoneNumber;
        val?.email = data.email;
        val?.birth = data.birth;
        val?.gender = data.gender;
      });
    }
  }

  _handleLoginRepeatError(e) async {
    if (e is PlatformException && (e.code == "13002" || e.code == '1507')) {
      await logout();
      await DataSp.removeLoginCertificate();
    }
  }

  /// Preload applications in background
  void _preloadApplications() {
    Future.delayed(const Duration(seconds: 2), () {
      groupApplicationsCache.preloadData();
      friendApplicationsCache.preloadData();
      friendCache.preloadData();
    });
  }

  @override
  void blacklistAdded(BlacklistInfo u) {
    super.blacklistAdded(u);
    friendCache.blacklistAdded(u);
  }

  @override
  void blacklistDeleted(BlacklistInfo u) {
    super.blacklistDeleted(u);
    friendCache.blacklistDeleted(u);
  }

  @override
  void friendAdded(FriendInfo u) {
    super.friendAdded(u);
    friendCache.friendAdded(u);
  }

  @override
  void friendDeleted(FriendInfo u) {
    super.friendDeleted(u);
    friendCache.friendDeleted(u);
  }

  @override
  void groupApplicationAccepted(GroupApplicationInfo info) {
    super.groupApplicationAccepted(info);
    // Refresh cache when application changes
    groupApplicationsCache.refreshData();
  }

  @override
  void groupApplicationAdded(GroupApplicationInfo info) {
    super.groupApplicationAdded(info);
    // Refresh cache when application changes
    groupApplicationsCache.refreshData();
  }

  @override
  void groupApplicationDeleted(GroupApplicationInfo info) {
    super.groupApplicationDeleted(info);
    // Refresh cache when application changes
    groupApplicationsCache.refreshData();
  }

  @override
  void groupApplicationRejected(GroupApplicationInfo info) {
    super.groupApplicationRejected(info);
    // Refresh cache when application changes
    groupApplicationsCache.refreshData();
  }

  @override
  void friendApplicationAccepted(FriendApplicationInfo u) {
    super.friendApplicationAccepted(u);
    // Refresh cache when application changes
    friendApplicationsCache.refreshData();
  }

  @override
  void friendApplicationAdded(FriendApplicationInfo u) {
    super.friendApplicationAdded(u);
    // Refresh cache when application changes
    friendApplicationsCache.refreshData();
  }

  @override
  void friendApplicationDeleted(FriendApplicationInfo u) {
    super.friendApplicationDeleted(u);
    // Refresh cache when application changes
    friendApplicationsCache.refreshData();
  }

  @override
  void friendApplicationRejected(FriendApplicationInfo u) {
    super.friendApplicationRejected(u);
    // Refresh cache when application changes
    friendApplicationsCache.refreshData();
  }
}
