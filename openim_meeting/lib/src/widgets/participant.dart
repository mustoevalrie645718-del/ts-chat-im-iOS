import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart' hide Participant;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:openim_common/openim_common.dart';

import 'no_video.dart';
import 'participant_info.dart';
import 'participant_stats.dart';

// Public class to track camera position across widgets
class CameraPositionTracker {
  static final ValueNotifier<CameraPosition> currentPosition = ValueNotifier(CameraPosition.front);
}

abstract class ParticipantWidget extends StatefulWidget {
  // Convenience method to return relevant widget for participant
  static ParticipantWidget widgetFor(
    ParticipantTrack participantTrack, {
    bool showStatsLayer = false,
    bool isHost = false,
    bool enableZoom = false,
    VoidCallback? onTapSwitchCamera,
  }) {
    if (participantTrack.participant is LocalParticipant) {
      return LocalParticipantWidget(
        participantTrack.participant as LocalParticipant,
        participantTrack.type,
        showStatsLayer,
        isHost: isHost,
        enableZoom: enableZoom,
        onTapSwitchCamera: onTapSwitchCamera,
      );
    } else if (participantTrack.participant is RemoteParticipant) {
      return RemoteParticipantWidget(
        participantTrack.participant as RemoteParticipant,
        participantTrack.type,
        showStatsLayer,
        isHost: isHost,
        enableZoom: enableZoom,
        onTapSwitchCamera: onTapSwitchCamera,
      );
    }
    throw UnimplementedError('Unknown participant type');
  }

  // Must be implemented by child class
  abstract final Participant participant;
  abstract final ParticipantTrackType type;
  abstract final bool showStatsLayer;
  final bool isHost;
  final bool enableZoom;
  final VoidCallback? onTapSwitchCamera;

  const ParticipantWidget({
    this.isHost = false,
    this.enableZoom = false,
    this.onTapSwitchCamera,
    super.key,
  });
}

class LocalParticipantWidget extends ParticipantWidget {
  @override
  final LocalParticipant participant;
  @override
  final ParticipantTrackType type;
  @override
  final bool showStatsLayer;

  const LocalParticipantWidget(
    this.participant,
    this.type,
    this.showStatsLayer, {
    super.key,
    super.isHost,
    super.enableZoom,
    super.onTapSwitchCamera,
  });

  @override
  State<StatefulWidget> createState() => _LocalParticipantWidgetState();
}

class RemoteParticipantWidget extends ParticipantWidget {
  @override
  final RemoteParticipant participant;
  @override
  final ParticipantTrackType type;
  @override
  final bool showStatsLayer;

  const RemoteParticipantWidget(
    this.participant,
    this.type,
    this.showStatsLayer, {
    super.key,
    super.isHost,
    super.enableZoom,
    super.onTapSwitchCamera,
  });

  @override
  State<StatefulWidget> createState() => _RemoteParticipantWidgetState();
}

abstract class _ParticipantWidgetState<T extends ParticipantWidget> extends State<T> {
  VideoTrack? get activeVideoTrack;
  AudioTrack? get activeAudioTrack;
  TrackPublication? get videoPublication;
  TrackPublication? get audioPublication;
  bool get isScreenShare => widget.type == ParticipantTrackType.kScreenShare;
  EventsListener<ParticipantEvent>? _listener;

  @override
  void initState() {
    super.initState();
    _listener = widget.participant.createListener();
    _listener?.on<TranscriptionEvent>((e) {
      for (var seg in e.segments) {
        print('Transcription: ${seg.text} ${seg.isFinal}');
      }
    });

    widget.participant.addListener(_onParticipantChanged);
    // Listen to camera position changes for instant mirror mode updates
    CameraPositionTracker.currentPosition.addListener(_onCameraPositionChanged);
    _onParticipantChanged();
  }

  @override
  void dispose() {
    widget.participant.removeListener(_onParticipantChanged);
    CameraPositionTracker.currentPosition.removeListener(_onCameraPositionChanged);
    _listener?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant T oldWidget) {
    oldWidget.participant.removeListener(_onParticipantChanged);
    widget.participant.addListener(_onParticipantChanged);
    _onParticipantChanged();
    super.didUpdateWidget(oldWidget);
  }

  // Notify Flutter that UI re-build is required, but we don't set anything here
  // since the updated values are computed properties.
  void _onParticipantChanged() => setState(() {
        _parseMetadata();
      });

  void _onCameraPositionChanged() {
    if (mounted) setState(() {});
  }

  // Widgets to show above the info bar
  List<Widget> extraWidgets(bool isScreenShare) => [];

  UserInfo? userInfo;

  void _parseMetadata() {
    try {
      if (widget.participant.metadata == null) return;
      var data = json.decode(widget.participant.metadata!);
      userInfo = UserInfo.fromJson(data['userInfo']);
    } catch (error, stack) {
      Logger.print('$error $stack');
    }
  }

  VideoViewMirrorMode _getMirrorMode() {
    // Only apply mirror mode for local video tracks (not screen share)
    if (activeVideoTrack is LocalVideoTrack && !isScreenShare) {
      // Use the static tracked camera position instead of currentOptions
      // because switching camera doesn't always update currentOptions immediately
      return CameraPositionTracker.currentPosition.value == CameraPosition.front
          ? VideoViewMirrorMode.mirror
          : VideoViewMirrorMode.off;
    }
    // For remote tracks or screen share, no mirror mode
    return VideoViewMirrorMode.off;
  }

  @override
  Widget build(BuildContext ctx) {
    return Container(
      foregroundDecoration: BoxDecoration(
        border: widget.participant.isSpeaking && !isScreenShare
            ? Border.all(
                width: 5,
                color: Styles.c_0089FF,
              )
            : null,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF666666),
      ),
      child: Stack(
        children: [
          // Video
          activeVideoTrack != null && !activeVideoTrack!.muted
              ? InteractiveViewer(
                  panEnabled: widget.enableZoom,
                  scaleEnabled: widget.enableZoom,
                  child: VideoTrackRenderer(
                    activeVideoTrack!,
                    mirrorMode: _getMirrorMode(),
                  ),
                )
              : Align(
                  alignment: Alignment.center,
                  child: NoVideoAvatarWidget(
                    nickname: userInfo?.nickname,
                    faceURL: userInfo?.faceURL,
                    width: 70.w,
                    height: 70.h,
                  ),
                ),

          if (isScreenShare && widget.participant.identity == OpenIM.iMManager.userID)
            LayoutBuilder(builder: (ctx, constraints) {
              return Container(
                alignment: Alignment.center,
                constraints: BoxConstraints(
                    maxWidth: constraints.maxWidth,
                    maxHeight: constraints.maxHeight,
                    minWidth: constraints.maxWidth,
                    minHeight: constraints.maxHeight),
                foregroundDecoration: BoxDecoration(
                  border: widget.participant.isSpeaking
                      ? Border.all(
                          width: 5,
                          color: Styles.c_0089FF,
                        )
                      : null,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFF666666),
                ),
                child: Text(
                  StrRes.screenShareHint,
                  style: Styles.ts_FFFFFF_14sp,
                ),
              );
            }),
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // ...extraWidgets(isScreenShare),
                ParticipantInfoWidget(
                  title: userInfo?.nickname,
                  audioAvailable: !widget.participant.isMuted,
                  connectionQuality: widget.participant.connectionQuality,
                  isScreenShare: isScreenShare,
                  isHost: widget.isHost,
                ),
              ],
            ),
          ),
          if (widget.showStatsLayer)
            Positioned(
                top: 130,
                right: 30,
                child: ParticipantStatsWidget(
                  participant: widget.participant,
                )),
          if (widget.onTapSwitchCamera != null && !isScreenShare)
            Align(
              alignment: Alignment.topLeft,
              child: CupertinoButton(
                  onPressed: widget.onTapSwitchCamera,
                  child: const Icon(
                    Icons.switch_camera,
                    color: Colors.white,
                  )),
            ),
        ],
      ),
    );
  }
}

class _LocalParticipantWidgetState extends _ParticipantWidgetState<LocalParticipantWidget> {
  @override
  LocalTrackPublication<LocalVideoTrack>? get videoPublication => widget.participant.videoTrackPublications
      .where((element) => element.source == widget.type.lkVideoSourceType)
      .firstOrNull;

  @override
  LocalTrackPublication<LocalAudioTrack>? get audioPublication => widget.participant.audioTrackPublications
      .where((element) => element.source == widget.type.lkAudioSourceType)
      .firstOrNull;

  @override
  VideoTrack? get activeVideoTrack => videoPublication?.track;

  @override
  AudioTrack? get activeAudioTrack => audioPublication?.track;
}

class _RemoteParticipantWidgetState extends _ParticipantWidgetState<RemoteParticipantWidget> {
  @override
  RemoteTrackPublication<RemoteVideoTrack>? get videoPublication => widget.participant.videoTrackPublications
      .where((element) => element.source == widget.type.lkVideoSourceType)
      .firstOrNull;

  @override
  RemoteTrackPublication<RemoteAudioTrack>? get audioPublication => widget.participant.audioTrackPublications
      .where((element) => element.source == widget.type.lkAudioSourceType)
      .firstOrNull;

  @override
  VideoTrack? get activeVideoTrack => videoPublication?.track;

  @override
  AudioTrack? get activeAudioTrack => audioPublication?.track;

  @override
  List<Widget> extraWidgets(bool isScreenShare) => [
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Menu for RemoteTrackPublication<RemoteAudioTrack>
            if (audioPublication != null)
              RemoteTrackPublicationMenuWidget(
                pub: audioPublication!,
                icon: Icons.volume_up,
              ),
            // Menu for RemoteTrackPublication<RemoteVideoTrack>
            if (videoPublication != null)
              RemoteTrackPublicationMenuWidget(
                pub: videoPublication!,
                icon: isScreenShare ? Icons.monitor : Icons.videocam,
              ),
            if (videoPublication != null)
              RemoteTrackFPSMenuWidget(
                pub: videoPublication!,
                icon: Icons.menu,
              ),
            if (videoPublication != null)
              RemoteTrackQualityMenuWidget(
                pub: videoPublication!,
                icon: Icons.monitor_outlined,
              ),
          ],
        ),
      ];
}

class RemoteTrackPublicationMenuWidget extends StatelessWidget {
  final IconData icon;
  final RemoteTrackPublication pub;
  const RemoteTrackPublicationMenuWidget({
    required this.pub,
    required this.icon,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.black.withOpacity(0.3),
        child: PopupMenuButton<Function>(
          tooltip: 'Subscribe menu',
          icon: Icon(icon,
              color: {
                TrackSubscriptionState.notAllowed: Colors.red,
                TrackSubscriptionState.unsubscribed: Colors.grey,
                TrackSubscriptionState.subscribed: Colors.green,
              }[pub.subscriptionState]),
          onSelected: (value) => value(),
          itemBuilder: (BuildContext context) => <PopupMenuEntry<Function>>[
            // Subscribe/Unsubscribe
            if (pub.subscribed == false)
              PopupMenuItem(
                child: const Text('Subscribe'),
                value: () => pub.subscribe(),
              )
            else if (pub.subscribed == true)
              PopupMenuItem(
                child: const Text('Un-subscribe'),
                value: () => pub.unsubscribe(),
              ),
          ],
        ),
      );
}

class RemoteTrackFPSMenuWidget extends StatelessWidget {
  final IconData icon;
  final RemoteTrackPublication pub;
  const RemoteTrackFPSMenuWidget({
    required this.pub,
    required this.icon,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.black.withOpacity(0.3),
        child: PopupMenuButton<Function>(
          tooltip: 'Preferred FPS',
          icon: Icon(icon, color: Colors.white),
          onSelected: (value) => value(),
          itemBuilder: (BuildContext context) => <PopupMenuEntry<Function>>[
            PopupMenuItem(
              child: const Text('30'),
              value: () => pub.setVideoFPS(30),
            ),
            PopupMenuItem(
              child: const Text('15'),
              value: () => pub.setVideoFPS(15),
            ),
            PopupMenuItem(
              child: const Text('8'),
              value: () => pub.setVideoFPS(8),
            ),
          ],
        ),
      );
}

class RemoteTrackQualityMenuWidget extends StatelessWidget {
  final IconData icon;
  final RemoteTrackPublication pub;
  const RemoteTrackQualityMenuWidget({
    required this.pub,
    required this.icon,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.black.withOpacity(0.3),
        child: PopupMenuButton<Function>(
          tooltip: 'Preferred Quality',
          icon: Icon(icon, color: Colors.white),
          onSelected: (value) => value(),
          itemBuilder: (BuildContext context) => <PopupMenuEntry<Function>>[
            PopupMenuItem(
              child: const Text('HIGH'),
              value: () => pub.setVideoQuality(VideoQuality.HIGH),
            ),
            PopupMenuItem(
              child: const Text('MEDIUM'),
              value: () => pub.setVideoQuality(VideoQuality.MEDIUM),
            ),
            PopupMenuItem(
              child: const Text('LOW'),
              value: () => pub.setVideoQuality(VideoQuality.LOW),
            ),
          ],
        ),
      );
}
