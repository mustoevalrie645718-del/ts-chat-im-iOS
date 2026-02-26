import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:openim_common/openim_common.dart';

import '../../live_client.dart';

import '../../services/livekit_service.dart';
import 'widgets/call_state.dart';
import 'widgets/participant.dart';

class SingleRoomView extends SignalView {
  const SingleRoomView({
    super.key,
    required super.callType,
    required super.userID,
    required super.autoPickup,
    super.onClose,
    super.onSyncUserInfo,
    super.onError,
    super.onEnabledSpeaker,
  });

  @override
  SignalState<SingleRoomView> createState() => _SingleRoomViewState();
}

class _SingleRoomViewState extends SignalState<SingleRoomView> with WidgetsBindingObserver {
  StreamSubscription? _roomSub;
  StreamSubscription? _roomEventsSub;
  StreamSubscription? _participantEventsSub;
  bool _poorNetwork = false;
  bool _didForceClose = false;
  Timer? _reconnectCloseTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _roomSub?.cancel();
    _roomEventsSub?.cancel();
    _participantEventsSub?.cancel();
    room?.removeListener(_onRoomDidUpdate);
    _cancelReconnectCloseTimer();
    if (Platform.isAndroid) {
      IMUtils.disableBackgroundExecution();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    Logger.print('[SingleRoom] AppLifecycleState changed to: $state');

    if (state == AppLifecycleState.paused) {
      _ensureBackgroundExecution();
    } else if (state == AppLifecycleState.resumed) {
      Logger.print('[SingleRoom] App resumed, room state: ${room?.connectionState}');
    }
  }

  Future<void> _ensureBackgroundExecution() async {
    if (!Platform.isAndroid) return;
    try {
      if (!FlutterBackground.isBackgroundExecutionEnabled) {
        Logger.print('[SingleRoom] Background execution not enabled, re-enabling...');
        await IMUtils.requestBackgroundPermission(
          title: StrRes.audioAndVideoCall,
          text: StrRes.audioAndVideoCall,
        );
      }
    } catch (e) {
      Logger.print('[SingleRoom] Error ensuring background execution: $e');
    }
  }

  @override
  Future<void> bindRoomStreams() async {
    if (_roomSub != null) return;

    Logger.print('SingleRoomView: bindRoomStreams() called');
    _roomSub = LiveKitService().roomStream.listen((room) {
      Logger.print('SingleRoomView: roomStream listener fired. Room: $room');
      if (room != null && this.room != room) {
        Logger.print('SingleRoomView: New room detected. Setting up listeners.');
        this.room?.removeListener(_onRoomDidUpdate);
        this.room = room;
        this.room!.addListener(_onRoomDidUpdate);

        _setUpListeners();
        _publish().then((_) {
          Logger.print('SingleRoomView: _publish completed.');
          _sortParticipants();
        });
      } else {
        this.room?.removeListener(_onRoomDidUpdate);
        this.room?.dispose();
        this.room = null;
        Logger.print('SingleRoomView: Room check skipped. Room: $room, Current: ${this.room}');
      }
    });
  }

  void _setUpListeners() {
    Logger.print('SingleRoomView: _setUpListeners called');
    _roomEventsSub?.cancel();
    _participantEventsSub?.cancel();

    _roomEventsSub = LiveKitService().roomEventsStream.listen((event) {
      if (event is RoomDisconnectedEvent) {
        _handleRoomDisconnected(event);
      } else if (event is RoomAttemptReconnectEvent) {
        _handleRoomAttemptReconnect(event);
      } else if (event is RoomReconnectedEvent) {
        _handleRoomReconnected(event);
      } else if (event is ParticipantConnectedEvent) {
        _handleParticipantConnected(event);
      } else if (event is ParticipantDisconnectedEvent) {
        _handleParticipantDisconnected(event);
      }
    });

    _participantEventsSub = LiveKitService().participantEventsStream.listen((event) {
      Logger.print('SingleRoomView listener received event: ${event.runtimeType}');
      // Any participant activity implies connection is alive; cancel reconnect timer.
      _cancelReconnectCloseTimer();
      if (event is LocalTrackPublishedEvent) {
        _onRoomDidUpdate();
      } else if (event is LocalTrackUnpublishedEvent) {
        Logger.print('SingleRoomView: LocalTrackUnpublishedEvent');
      } else if (event is TrackSubscribedEvent) {
        _handleTrackSubscribed(event);
      } else if (event is TrackUnsubscribedEvent) {
        Logger.print('SingleRoomView: TrackUnsubscribedEvent');
      } else if (event is ParticipantConnectionQualityUpdatedEvent) {
        _handleConnectionQualityUpdate(event);
      } else if (event is TrackMutedEvent) {
        Logger.print('TrackMutedEvent: ${event.participant.metadata} ${event.publication.kind}');
      } else if (event is TrackUnmutedEvent) {
        Logger.print('TrackUnmutedEvent: ${event.participant.metadata} ${event.publication.kind}');
      }
    });
  }

  void _handleRoomDisconnected(RoomDisconnectedEvent event) {
    Logger.print(
      'RoomDisconnectedEvent',
      fileName: 'single-room.dart',
      keyAndValues: ['reason', event.reason.toString()],
    );

    if (event.reason == DisconnectReason.joinFailure || event.reason == DisconnectReason.reconnectAttemptsExceeded) {
      final tips = event.reason == DisconnectReason.joinFailure ? StrRes.joinFailure : StrRes.callingInterruption;

      OverlayWidget().showToast(
        context: context,
        text: tips,
        onDelayDismiss: () {
          insertInterruptionMessage();
          widget.onClose?.call();
        },
      );
    } else if (event.reason == DisconnectReason.signalingConnectionFailure ||
        event.reason == DisconnectReason.roomDeleted ||
        event.reason == DisconnectReason.stateMismatch) {
      OverlayWidget().showToast(
        context: context,
        text: StrRes.callingInterruption,
        onDelayDismiss: () {
          insertInterruptionMessage();
          widget.onError?.call(StrRes.callingInterruption, null);
        },
      );
    } else if (event.reason == DisconnectReason.participantRemoved) {
      if (!Platform.isIOS) {
        return;
      }
      // Ensure onClose is called even when app is in background
      final lifecycleState = WidgetsBinding.instance.lifecycleState;
      if (lifecycleState == AppLifecycleState.paused ||
          lifecycleState == AppLifecycleState.inactive ||
          lifecycleState == AppLifecycleState.detached) {
        Logger.print('[SingleRoom] App in background, calling onClose directly');
        insertHangupMessageWhenInBackground();
      }
    }
  }

  void _handleRoomAttemptReconnect(RoomAttemptReconnectEvent event) {
    Logger.print(
      'RoomAttemptReconnectEvent',
      fileName: 'single-room.dart',
      keyAndValues: [event.attempt, event.maxAttemptsRetry],
    );
    _startReconnectCloseTimer();
  }

  void _handleRoomReconnected(RoomReconnectedEvent event) {
    Logger.print('RoomReconnectedEvent', fileName: 'single-room.dart');
    _didForceClose = false;
    _cancelReconnectCloseTimer();

    // After reconnecting, if only the local participant remains, close the call.
    final remoteCount = room?.remoteParticipants.length ?? 0;
    if (remoteCount == 0) {
      OverlayWidget().showToast(
        context: context,
        text: StrRes.callingInterruption,
        onDelayDismiss: () {
          insertInterruptionMessage();

          widget.onClose?.call();
        },
      );
    }
  }

  void _handleParticipantConnected(ParticipantConnectedEvent event) {
    Logger.print(
      'ParticipantConnectedEvent',
      fileName: 'single-room.dart',
      keyAndValues: ['metadata', event.participant.metadata ?? event.participant.identity],
    );
    // sender
    // if (widget.initState == CallState.call &&
    //     enabledMicrophone &&
    //     room?.localParticipant?.isMicrophoneEnabled() == false) {
    //   room?.localParticipant?.setMicrophoneEnabled(true);
    // }
  }

  void _handleParticipantDisconnected(ParticipantDisconnectedEvent event) {
    Logger.print(
      'ParticipantDisconnectedEvent',
      fileName: 'single-room.dart',
      keyAndValues: ['metadata', event.participant.metadata ?? event.participant.identity],
    );
    if (_poorNetwork) {
      OverlayWidget().showToast(
          context: context,
          text: StrRes.callingInterruption,
          onDelayDismiss: () {
            widget.onClose?.call();
          });
    } else {
      widget.onClose?.call();
    }
    _onRoomDidUpdate();
  }

  void _handleTrackSubscribed(TrackSubscribedEvent event) {
    Logger.print(
      'TrackSubscribedEvent',
      fileName: 'single-room.dart',
      keyAndValues: ['metadata', event.participant.metadata ?? event.participant.identity],
    );

    // if (widget.initState == CallState.call &&
    //     enabledMicrophone &&
    //     room?.localParticipant?.isMicrophoneEnabled() == false) {
    //   room?.localParticipant?.setMicrophoneEnabled(true);
    // }
    _onRoomDidUpdate();
  }

  void _handleConnectionQualityUpdate(ParticipantConnectionQualityUpdatedEvent event) {
    Logger.print(
      'ParticipantConnectionQualityUpdatedEvent',
      fileName: 'single-room.dart',
      keyAndValues: [event.toString()],
    );

    if (!mounted) return;

    if (event.connectionQuality == ConnectionQuality.lost || event.connectionQuality == ConnectionQuality.poor) {
      final isMine = event.participant.identity == room?.localParticipant?.identity;

      if (!isMine && event.connectionQuality == ConnectionQuality.lost) {
        OverlayWidget().showToast(
          context: context,
          text: StrRes.callingInterruption,
          onDelayDismiss: () {
            insertInterruptionMessage();

            widget.onClose?.call();
          },
        );
        return;
      }
      _poorNetwork = true;

      OverlayWidget().showToast(
        context: context,
        text: isMine ? StrRes.networkNotStable : StrRes.otherNetworkNotStableHint,
      );
    } else {
      _poorNetwork = false;
    }
  }

  Future _publish([bool publishMic = true]) async {
    // video will fail when running in ios simulator
    await IMUtils.requestBackgroundPermission(title: StrRes.audioAndVideoCall, text: StrRes.audioAndVideoCall);

    try {
      final enabled = widget.callType == CallType.video;
      await room?.localParticipant?.setCameraEnabled(enabled);
      Logger.print('publish video success', fileName: 'single-room.dart');
      final pubs = room?.localParticipant?.videoTrackPublications;
      Logger.print('SingleRoomView: _publish post-check. Enabled: $enabled, Pubs count: ${pubs?.length}');
      if (pubs != null) {
        for (var p in pubs) {
          Logger.print('SingleRoomView: _publish pub: ${p.sid}, track: ${p.track}');
        }
      }
    } catch (error, stackTrace) {
      Logger.print('could not publish video: ${error.toString()} ${stackTrace.toString()}',
          fileName: 'single-room.dart');
    }

    try {
      await room?.localParticipant?.setMicrophoneEnabled(publishMic ? enabledMicrophone : false);
      Logger.print('setMicrophoneEnabled enable[${publishMic ? enabledMicrophone : false}] success',
          fileName: 'single-room.dart');
    } catch (error, stackTrace) {
      Logger.print('could not publish audio: ${error.toString()} ${stackTrace.toString()}',
          fileName: 'single-room.dart');
    }

    try {
      await room?.setSpeakerOn(enabledSpeaker);
      Logger.print('setSpeakerOn[$enabledSpeaker] success', fileName: 'single-room.dart');
    } catch (error, stackTrace) {
      Logger.print('could not set speaker on [$enabledSpeaker]: ${error.toString()} ${stackTrace.toString()}',
          fileName: 'single-room.dart');
    }
  }

  void _onRoomDidUpdate() {
    _sortParticipants();
  }

  void _startReconnectCloseTimer() {
    if (_didForceClose || _reconnectCloseTimer != null) return;
    _reconnectCloseTimer = Timer(const Duration(seconds: 10), () {
      if (_didForceClose) return;
      _didForceClose = true;
      _reconnectCloseTimer = null;
      OverlayWidget().showToast(
        context: context,
        text: StrRes.callingInterruption,
        onDelayDismiss: () {
          insertInterruptionMessage();

          widget.onError?.call(StrRes.callingInterruption, null);
        },
      );
    });
  }

  void _cancelReconnectCloseTimer() {
    _reconnectCloseTimer?.cancel();
    _reconnectCloseTimer = null;
  }

  void _sortParticipants() {
    if (null == room || !mounted) return;

    final localParticipant = room!.localParticipant;
    if (null != localParticipant) {
      VideoTrack? videoTrack;
      Logger.print('SingleRoomView: _sortParticipants local pubs: ${localParticipant.videoTrackPublications.length}');
      for (var t in localParticipant.videoTrackPublications) {
        Logger.print('SingleRoomView: local pub: ${t.sid}, isScreenShare: ${t.isScreenShare}, track: ${t.track}');
        if (!t.isScreenShare) {
          videoTrack = t.track;
          break;
        }
      }
      localParticipantTrack = ParticipantTrack(
        participant: localParticipant,
        videoTrack: videoTrack,
        isScreenShare: false,
      );
    }

    final participants = room!.remoteParticipants.values;
    final participant = participants.isNotEmpty ? participants.first : null;
    if (null != participant) {
      VideoTrack? videoTrack;
      for (var t in participant.videoTrackPublications) {
        if (!t.isScreenShare) {
          videoTrack = t.track;
          break;
        }
      }
      remoteParticipantTrack = ParticipantTrack(
        participant: participant,
        videoTrack: videoTrack,
        isScreenShare: false,
      );
    } else {
      remoteParticipantTrack = null;
    }

    onRemoteParticipantsUpdated();
  }

  @override
  bool existParticipants() {
    return room?.remoteParticipants.isNotEmpty == true;
  }
}
