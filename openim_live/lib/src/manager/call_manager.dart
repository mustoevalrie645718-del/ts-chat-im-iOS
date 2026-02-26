import 'dart:async';
import 'dart:io';

import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:openim_common/openim_common.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sound_mode/sound_mode.dart';
import 'package:sound_mode/utils/ringer_mode_statuses.dart';
import 'package:uuid/uuid.dart';
import 'package:vibration/vibration.dart';

import '../model/call_event.dart';
import '../services/livekit_service.dart';
import '../services/signaling_service.dart';

class CallManager {
  static final CallManager _instance = CallManager._internal();

  factory CallManager() => _instance;

  CallManager._internal() {
    _initListeners();
  }

  // Dependencies
  final SignalingService _signalingService = SignalingService();
  final LiveKitService _liveKitService = LiveKitService();

  // State
  final _callStateSubject = BehaviorSubject<CallEvent?>();
  Stream<CallEvent?> get callStateStream => _callStateSubject.stream;
  CallEvent? get currentCallEvent => _callStateSubject.valueOrNull;

  SignalingCertificate? _certificate;
  List<String> get busyLineUserIDs => _certificate?.busyLineUserIDList ?? [];
  final Set<String> _rejectedOrHungupUserIDs = {};
  final Set<String> _connectedParticipantIDs = {};

  // Internal state
  Timer? _dialTimer;
  final _waitTimeout = 60;
  final _ring = 'assets/audio/live_ring.wav';
  DateTime? _callStartTime; // Track when the call started
  final _audioPlayer = AudioPlayer();

  bool _isBusy = false;
  bool get isBusy => _isBusy;

  Function(SignalingMessageEvent)? onSignalingMessage;

  void _initListeners() {
    // Signaling Events
    _signalingService.signalingStream.listen((event) {
      _handleSignalingEvent(event);
    });

    // LiveKit participant events (remote join/leave)
    _liveKitService.roomEventsStream.listen((event) {
      _handleRoomEvent(event);
    });
  }

  void _handleSignalingEvent(CallEvent event) {
    Logger.print('CallManager handle event: ${event.state}');
    final isSingle = event.data.invitation?.sessionType == 1;

    // If we are currently in a call (busy), we must filter events
    if (_isBusy) {
      final incomingRoomID = event.data.invitation?.roomID;
      var currentRoom = _certificate?.roomID;
      if (null == currentRoom && currentCallEvent != null) {
        currentRoom = currentCallEvent?.data.invitation?.roomID;
      }
      // If event room ID doesn't match current active room ID
      if (currentRoom != null && incomingRoomID != currentRoom) {
        if (event.state == CallState.beCalled) {
          // Received a new call while busy
          Logger.print('Received call from $incomingRoomID while busy in $currentRoom');
          // TODO: Auto-reject or notify user about missed call?
          // For now, just ignore to prevent UI interference
          return;
        } else {
          // Ignore other events from different rooms
          Logger.print('Ignored event ${event.state} from other room $incomingRoomID');
          return;
        }
      }
    } else {
      if (event.state != CallState.beCalled) {
        Logger.print('Ignored event ${event.state} because we are not busy (no active call)');
        return;
      }
    }

    _callStateSubject.add(event);

    switch (event.state) {
      case CallState.beCalled:
        _isBusy = true;
        _playSound();
        _startDialTimer(event.data);
        break;
      case CallState.beAccepted:
        _stopSound();
        _stopDialTimer();

        if (isSingle) {
          _callStateSubject.add(CallEvent(CallState.connecting, event.data));
          _joinRoom().then((value) {
            _callStartTime = DateTime.now();
            _callStateSubject.add(CallEvent(CallState.calling, event.data));
          }).catchError((e) {
            _callStateSubject.add(CallEvent(CallState.networkError, event.data));
          });
        } else {
          _callStateSubject.add(CallEvent(CallState.calling, event.data));
        }
        break;

      case CallState.beRejected:
      case CallState.beCanceled:
      case CallState.timeout:
        if (event.state == CallState.beRejected ||
            event.state == CallState.beCanceled ||
            event.state == CallState.timeout) {
          Logger.print(
              'Handle event: ${event.state}, sessionType: ${event.data.invitation!.sessionType} userID: ${event.data.userID}');
          if (isSingle) {
            _stopSound();
            _stopDialTimer();

            insertCallMessage(
              state: event.state,
              signalingInfo: event.data,
            );
            Future.delayed(const Duration(milliseconds: 300), () {
              _hangupCleanup();
            });
          } else {
            // Group call: track rejection/cancel/timeout
            final userID = event.data.userID;
            Logger.print('Group call event: ${event.state}, userID: $userID');
            if (userID != null) {
              _rejectedOrHungupUserIDs.add(userID);
              _checkAutoCloseGroupCall();
            }
          }
        }

        break;

      case CallState.otherAccepted:
      case CallState.otherReject:
        _stopSound();
        _stopDialTimer();

        if (isSingle) {
          insertCallMessage(
            state: event.state,
            signalingInfo: event.data,
          );
        }

        Future.delayed(const Duration(milliseconds: 1000), () {
          if (_isBusy) {
            _hangupCleanup();
          }
        });

        break;

      case CallState.beHangup:
        if (isSingle) {
          _stopSound();
          _stopDialTimer();

          // Calculate duration if we were in a call
          var duration = 0;
          if (_callStartTime != null) {
            duration = DateTime.now().difference(_callStartTime!).inSeconds;
          }

          insertCallMessage(
            state: event.state,
            signalingInfo: event.data,
            duration: duration,
          );

          _hangupCleanup();
        } else {
          // Group call hangup
          final userID = event.data.userID;
          if (userID != null) {
            _rejectedOrHungupUserIDs.add(userID);
            _checkAutoCloseGroupCall();
          }
        }
        break;
      case CallState.calling: // When we start calling
        _isBusy = true;
        break;
      default:
        break;
    }
  }

  void _handleRoomEvent(RoomEvent event) {
    final isSingle = currentCallEvent?.data.invitation?.sessionType == 1;

    if (event is ParticipantConnectedEvent) {
      if (isSingle) {
      } else {
        final userID = event.participant.identity;
        Logger.print('ParticipantConnectedEvent -> $userID', fileName: 'call_manager.dart');
        _connectedParticipantIDs.add(userID);
        _rejectedOrHungupUserIDs.remove(userID);
      }
    } else if (event is ParticipantDisconnectedEvent) {
      final userID = event.participant.identity;
      Logger.print('ParticipantDisconnectedEvent -> $userID', fileName: 'call_manager.dart');
      _connectedParticipantIDs.remove(userID);
      _rejectedOrHungupUserIDs.add(userID);
      _checkAutoCloseGroupCall();
    }
  }

  // --- Actions ---

  Future<void> _joinRoom() async {
    try {
      final cert = _certificate;
      if (cert == null) {
        Logger.print('Join room failed: No certificate');
        _hangupCleanup();
        return;
      }

      final token = cert.token;
      final url = cert.liveURL;

      if (token == null || url == null) {
        Logger.print('Join room failed: Token or URL is null');
        _hangupCleanup();
        return;
      }
      await _liveKitService.connect(url, token);
    } catch (e) {
      Logger.print('Join room failed: $e');
      if (currentCallEvent?.data.invitation?.sessionType == 1) {
        if (currentCallEvent?.data.invitation?.inviterUserID == OpenIM.iMManager.userID) {
          cancelCall();
        } else {
          rejectCall();
        }
      }
      _hangupCleanup();
    }
  }

  Future<void> startCall({
    required List<String> inviteeUserIDs,
    required CallType callType,
    String? groupID,
  }) async {
    if (_isBusy) return;
    _isBusy = true;

    final inviterUserID = OpenIM.iMManager.userID;
    final mediaType = callType == CallType.audio ? 'audio' : 'video';
    final sessionType = groupID != null ? 3 : 1; // 1: single, 3: group
    final roomID = const Uuid().v4();

    final info = SignalingInfo(
      userID: inviterUserID,
      invitation: InvitationInfo(
        inviterUserID: inviterUserID,
        inviteeUserIDList: inviteeUserIDs,
        roomID: roomID,
        timeout: _waitTimeout,
        mediaType: mediaType,
        sessionType: sessionType,
        platformID: await IMUtils.getPlatform(),
        groupID: groupID,
      ),
    );

    _callStateSubject.add(CallEvent(CallState.call, info));

    _playSound();

    try {
      SignalingCertificate cert;
      if (groupID != null) {
        cert = await _signalingService.inviteInGroup(info: info);
      } else {
        cert = await _signalingService.invite(info: info);
      }
      _certificate = cert;
      if (groupID != null) {
        await _joinRoom();
      }
    } catch (e) {
      _hangupCleanup();
      rethrow;
    }
  }

  Future<void> joinCall({
    required SignalingCertificate certificate,
    required InvitationInfo invitation,
    String? groupID,
  }) async {
    if (_isBusy) return;
    _isBusy = true;
    final info = SignalingInfo(
      userID: OpenIM.iMManager.userID,
      invitation: invitation,
    );
    _callStateSubject.add(CallEvent(CallState.join, info));

    try {
      _certificate = certificate;
      if (groupID != null) {
        await _joinRoom();
      }
    } catch (e) {
      _hangupCleanup();
      rethrow;
    }
  }

  Future<void> acceptCall() async {
    final event = currentCallEvent;
    if (event == null || event.state != CallState.beCalled) return;

    _stopSound();
    _stopDialTimer();

    try {
      _callStateSubject.add(CallEvent(CallState.connecting, event.data));
      final cert = await _signalingService.accept(info: event.data);
      _certificate = cert;
      _callStartTime = DateTime.now();
      await _joinRoom();
      _callStateSubject.add(CallEvent(CallState.calling, event.data));
    } catch (e) {
      _hangupCleanup();
      _callStateSubject.add(CallEvent(CallState.networkError, event.data));
      rethrow;
    }
  }

  Future<void> rejectCall() async {
    final event = currentCallEvent;

    try {
      if (event == null) return;

      await _signalingService.reject(info: event.data);
    } finally {
      _hangupCleanup();
      insertCallMessage(state: CallState.reject, signalingInfo: event?.data);
    }
  }

  Future<void> hangupCall({int? duration, bool skipHangup = false}) async {
    final event = currentCallEvent;

    try {
      if (!skipHangup) {
        if (event == null) return;

        await _signalingService.hangup(info: event.data);
      }
    } finally {
      _hangupCleanup();
      var d = duration ?? 0;

      if (_callStartTime != null) {
        d = DateTime.now().difference(_callStartTime!).inSeconds;
      }
      insertCallMessage(state: CallState.hangup, signalingInfo: event?.data, duration: d);
    }
  }

  Future<void> cancelCall() async {
    final event = currentCallEvent;

    try {
      if (event == null) return;

      await _signalingService.cancel(info: event.data);
    } finally {
      _hangupCleanup();
      insertCallMessage(state: CallState.cancel, signalingInfo: event?.data);
    }
  }

  void _hangupCleanup() {
    Logger.print('CallManager hangup cleanup');
    _stopSound();
    _stopDialTimer();

    _certificate = null;
    _isBusy = false;
    _callStateSubject.add(null);
    _callStartTime = null;

    _liveKitService.disconnect();
    _rejectedOrHungupUserIDs.clear();
    _connectedParticipantIDs.clear();
  }

  void cleanup() {
    _hangupCleanup();
  }

  void _checkAutoCloseGroupCall() {
    final event = currentCallEvent;
    // Check if it's a group call (sessionType == 3 or groupID != null)
    if (event == null || event.data.invitation?.sessionType == 1) return;

    final allInvitees = event.data.invitation!.inviteeUserIDList ?? [];
    final selfUserID = OpenIM.iMManager.userID;
    // Active remote participants
    final activeParticipants = _liveKitService.room?.remoteParticipants.keys.toList() ?? [];

    // Filter waiting
    final waitingCount = allInvitees.where((id) {
      // Skip myself when counting pending participants
      if (id == selfUserID) return false;
      return !activeParticipants.contains(id) && !_rejectedOrHungupUserIDs.contains(id);
    }).length;

    if (activeParticipants.isEmpty && waitingCount == 0) {
      hangupCall();
    }
  }

  // --- Audio ---

  void _playSound() async {
    if (_audioPlayer.playing) return;

    if (Platform.isIOS) {
      try {
        final ringerMode = await SoundMode.ringerModeStatus;
        // On Android: normal, silent, vibrate, or unknown
        if (ringerMode == RingerModeStatus.silent) {
          Logger.print('System is in silent mode, skipping ringtone');
          return;
        } else if (ringerMode == RingerModeStatus.vibrate) {
          Logger.print('System is in vibrate mode, skipping ringtone');
          if (await Vibration.hasVibrator()) {
            Vibration.vibrate(duration: 500);
          }
          return;
        }
      } catch (e) {
        // If sound_mode fails, continue playing (fallback)
        Logger.print('Failed to check sound mode: $e');
      }
    } else {
      _audioPlayer.setSkipSilenceEnabled(false);
    }

    await _audioPlayer.setAsset(_ring, package: 'openim_common');
    _audioPlayer.setLoopMode(LoopMode.one);
    _audioPlayer.play();
  }

  void _stopSound() {
    Logger.print('Stopping ringtone if playing');
    // Force stop regardless of current state; playing flag may lag behind.
    _audioPlayer.stop();
    _audioPlayer.seek(Duration.zero);
  }

  // --- Timer ---

  void _startDialTimer(SignalingInfo info) {
    _dialTimer?.cancel();
    var timeout = info.invitation?.timeout ?? _waitTimeout;
    _dialTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      timeout--;
      if (timeout <= 0) {
        _hangupCleanup();
        // Notify timeout
        _callStateSubject.add(CallEvent(CallState.timeout, info));
      }
    });
  }

  void _stopDialTimer() {
    _dialTimer?.cancel();
    _dialTimer = null;
  }

  void insertCallMessage({
    required CallState state,
    SignalingInfo? signalingInfo,
    int duration = 0,
  }) async {
    final info = signalingInfo ?? currentCallEvent?.data;
    if (info == null || info.invitation?.sessionType != 1) return;

    (() async {
      var invitation = info.invitation;
      var mediaType = invitation!.mediaType;
      var inviterUserID = invitation.inviterUserID;
      var inviteeUserID = invitation.inviteeUserIDList!.first;
      var groupID = invitation.groupID;
      Logger.print(
          'end calling and insert message state:${state.name}, mediaType:$mediaType, inviterUserID:$inviterUserID, inviteeUserID:$inviteeUserID, groupID:$groupID, duration:$duration',
          functionName: 'insertCallMessage');
      _recordCall(state: state, signaling: info, duration: duration);
      var message = await OpenIM.iMManager.messageManager.createCallMessage(
        state: state.name,
        type: mediaType!,
        duration: duration,
      );
      switch (invitation.sessionType) {
        case 1:
          {
            String? receiverID;
            if (inviterUserID != OpenIM.iMManager.userID) {
              receiverID = inviterUserID;
            } else {
              receiverID = inviteeUserID;
            }

            var msg = await OpenIM.iMManager.messageManager.insertSingleMessageToLocalStorage(
              receiverID: inviteeUserID,
              senderID: inviterUserID,
              // receiverID: receiverID,
              // senderID: OpenIM.iMManager.uid,
              message: message
                ..status = 2
                ..isRead = true,
            );

            onSignalingMessage?.call(SignalingMessageEvent(msg, 1, receiverID, null));
          }
          break;
        case 2:
          {
            // signalingMessageSubject.add(
            //   SignalingMessageEvent(message, 2, null, groupID),
            // );
            // OpenIM.iMManager.messageManager.insertGroupMessageToLocalStorage(
            //   groupID: groupID!,
            //   senderID: inviterUserID,
            //   message: message..status = 2,
            // );
          }
          break;
      }
    })();
  }

  void _recordCall({
    required CallState state,
    required SignalingInfo signaling,
    int duration = 0,
  }) async {
    var invitation = signaling.invitation;
    if (invitation!.sessionType != ConversationType.single) return;
    var mediaType = invitation.mediaType;
    var inviterUserID = invitation.inviterUserID;
    var inviteeUserID = invitation.inviteeUserIDList!.first;
    var isMeCall = inviterUserID == OpenIM.iMManager.userID;
    var userID = isMeCall ? inviteeUserID : inviterUserID!;
    var incomingCall = isMeCall ? false : true;
    var userInfo = (await OpenIM.iMManager.userManager.getUsersInfo(userIDList: [userID])).firstOrNull;
    if (null == userInfo) return;
    final cache = Get.find<CacheController>();
    cache.addCallRecords(CallRecords(
      userID: userID,
      nickname: userInfo.nickname ?? '',
      faceURL: userInfo.faceURL,
      success: state == CallState.hangup || state == CallState.beHangup,
      date: DateTime.now().millisecondsSinceEpoch,
      type: mediaType!,
      incomingCall: incomingCall,
      duration: duration,
    ));
  }
}
