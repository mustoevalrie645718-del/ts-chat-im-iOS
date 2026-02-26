import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:openim_common/openim_common.dart';
import 'package:collection/collection.dart';

import 'participant.dart';
import 'participant_info.dart';

class FirstPage extends StatelessWidget {
  const FirstPage({super.key, required this.participantTrack});
  final ParticipantTrack participantTrack;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ParticipantWidget.widgetFor(
          participantTrack,
          enableZoom: true,
          onTapSwitchCamera: participantTrack.participant is LocalParticipant ? participantTrack.toggleCamera : null,
          isHost: participantTrack.isHost,
        ),
      ],
    );
  }
}

class OtherPage extends StatelessWidget {
  const OtherPage({
    super.key,
    required this.participantTracks,
    required this.pages,
    this.pageSize = 4,
    this.onDoubleTap,
  });
  final List<ParticipantTrack> participantTracks;
  final int pages;
  final int pageSize;
  final ValueChanged<ParticipantTrack>? onDoubleTap;

  List<ParticipantTrack> get list =>
      participantTracks.sublist(pages * pageSize, min((pages + 1) * pageSize, participantTracks.length));

  Widget _participantWidgetFor(ParticipantTrack track) {
    final videoTracks = track.participant.videoTrackPublications;
    final screenTrack = videoTracks.firstWhereOrNull((e) => e.isScreenShare);
    final videoTrack = videoTracks.firstWhereOrNull((e) => !e.isScreenShare);
    final audioTrack = track.participant.audioTrackPublications.firstOrNull;
    Logger.print('audioTrack:${track.participant.audioTrackPublications.length}');

    Logger.print('participantWidgetFor:'
        'videoTrack:${screenTrack != null} '
        'screenShareTrack:${videoTrack != null} '
        'screen track muted:${screenTrack?.muted == true} '
        'video track muted:${videoTrack?.muted == true} '
        'audio track muted:${track.participant.isMuted} ');
    return GestureDetector(
      onDoubleTap: () {
        onDoubleTap?.call(track);
      },
      child: ParticipantWidget.widgetFor(
        track,
        // useScreenShareTrack: screenTrack != null && !screenTrack.muted,
        onTapSwitchCamera: track.participant is LocalParticipant ? track.toggleCamera : null,
        isHost: track.isHost,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Flexible(
          flex: 1,
          child: Row(
            children: [
              Expanded(
                child: list.isNotEmpty ? _participantWidgetFor(list[0]) : const SizedBox(),
              ),
              1.horizontalSpace,
              Expanded(
                child: list.length > 1 ? _participantWidgetFor(list[1]) : const SizedBox(),
              ),
            ],
          ),
        ),
        1.verticalSpace,
        Flexible(
          flex: 1,
          child: Row(
            children: [
              Expanded(
                child: list.length > 2 ? _participantWidgetFor(list[2]) : const SizedBox(),
              ),
              1.horizontalSpace,
              Expanded(
                child: list.length > 3 ? _participantWidgetFor(list[3]) : const SizedBox(),
              ),
            ],
          ),
        ),
      ],
    );
    // return GridView.count(
    //   crossAxisCount: 2,
    //   mainAxisSpacing: 1.h,
    //   crossAxisSpacing: 1.w,
    //   // childAspectRatio: 187 / 309.5,
    //   children: list.map((e) => ParticipantWidget.widgetFor(e)).toList(),
    // );
  }
}
