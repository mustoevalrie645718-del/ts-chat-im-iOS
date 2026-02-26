import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:openim_common/openim_common.dart';

import 'package:wakelock_plus/wakelock_plus.dart';

import 'model/call_event.dart';

import 'pages/group/room.dart';
import 'pages/single/room.dart';
import 'services/livekit_service.dart';

export 'model/call_event.dart';

class OpenIMLiveClient implements RTCBridge {
  OpenIMLiveClient._();

  static final OpenIMLiveClient singleton = OpenIMLiveClient._();

  factory OpenIMLiveClient() {
    PackageBridge.rtcBridge ??= singleton;
    return singleton;
  }

  @override
  bool get hasConnection {
    Logger.print('live_client has Connection: $isBusy');
    return isBusy;
  }

  @override
  void dismiss() {
    close();
  }

  static OverlayEntry? _holder;

  bool isBusy = false;

  static const Duration _callCooldown = Duration(seconds: 2);
  DateTime? _lastCallClosedAt;

  bool get isInCallCooldown =>
      _lastCallClosedAt != null && DateTime.now().difference(_lastCallClosedAt!) < _callCooldown;

  String? currentRoomID;

  AnimationController? _animationController;

  List<String> get remoteParticipantIDs =>
      LiveKitService().room?.remoteParticipants.values.map((e) => e.identity).toList() ?? [];

  void close() {
    Logger.print(
      'calling remove overlay',
      fileName: 'live_client.dart',
      functionName: 'close',
    );
    _lastCallClosedAt = DateTime.now();
    if (_holder != null) {
      Future.delayed(const Duration(milliseconds: 500), () async {
        await _animationController?.reverse();
        _holder?.remove();
        _holder = null;
        _animationController = null;
        WakelockPlus.disable();
        isBusy = false;
        currentRoomID = null;
      });
    }
  }

  // start method as described
  void start(
    BuildContext ctx, {
    String? roomID,
    CallState initState = CallState.call,
    CallType callType = CallType.video,
    CallObj callObj = CallObj.single,
    required String inviterUserID,
    required List<String> inviteeUserIDList,
    String? groupID,
    Future<UserInfo?> Function(String userID)? onSyncUserInfo,
    Future<GroupInfo?> Function(String groupID)? onSyncGroupInfo,
    Future<List<GroupMembersInfo>> Function(String groupID, List<String> memberIDList)? onSyncGroupMemberInfo,
    bool autoPickup = false,
    Function(dynamic error, dynamic stack)? onError,
    void Function()? onClose,
  }) {
    if (isBusy) return;
    isBusy = true;
    currentRoomID = roomID;

    FocusScope.of(ctx).requestFocus(FocusNode());

    // Choose the overlay widget based on CallObj type
    if (callObj == CallObj.single) {
      _holder = OverlayEntry(
        builder: (context) => SlideInSlideOutWidget(
          contentBuilder: (controller) {
            _animationController = controller;
            return SingleRoomView(
              callType: callType,
              userID: initState == CallState.call ? inviteeUserIDList.first : inviterUserID,
              onSyncUserInfo: onSyncUserInfo,
              autoPickup: autoPickup,
              onError: (error, stack) {
                onError?.call(error, stack);
                Logger.print(
                  'calling dismiss from onError',
                  fileName: 'live_client.dart',
                  functionName: 'start',
                );
                dismiss();
              },
              onClose: () {
                Logger.print(
                  'calling dismiss from onClose',
                  fileName: 'live_client.dart',
                  functionName: 'start',
                );
                onClose?.call();
                dismiss();
              },
            );
          },
        ),
      );
    } else {
      _holder = OverlayEntry(
        builder: (context) => SlideInSlideOutWidget(
          contentBuilder: (controller) {
            _animationController = controller;
            return GroupRoomView(
              callType: callType,
              roomID: roomID,
              inviterUserID: inviterUserID,
              inviteeUserIDList: inviteeUserIDList,
              groupID: groupID!,
              onSyncGroupInfo: onSyncGroupInfo,
              onSyncGroupMemberInfo: onSyncGroupMemberInfo,
              autoPickup: autoPickup,
              onError: (error, stack) {
                onError?.call(error, stack);
                Logger.print(
                  'calling dismiss from onError',
                  fileName: 'live_client.dart',
                  functionName: 'start',
                );
                dismiss();
              },
              onClose: () {
                Logger.print(
                  'calling dismiss from onClose',
                  fileName: 'live_client.dart',
                  functionName: 'start',
                );
                onClose?.call();
                dismiss();
              },
            );
          },
        ),
      );
    }

    Overlay.of(ctx).insert(_holder!);

    // Enable screen wake lock
    WakelockPlus.enable();
  }
}

// FadeInFadeOutWidget is used to wrap the content with an animation
class SlideInSlideOutWidget extends StatefulWidget {
  final Widget Function(AnimationController) contentBuilder;

  const SlideInSlideOutWidget({super.key, required this.contentBuilder});

  @override
  State<SlideInSlideOutWidget> createState() => _SlideInSlideOutWidgetState();
}

class _SlideInSlideOutWidgetState extends State<SlideInSlideOutWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: widget.contentBuilder(_controller),
    );
  }
}
