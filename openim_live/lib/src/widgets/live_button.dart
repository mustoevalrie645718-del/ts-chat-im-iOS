import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:openim_common/openim_common.dart';

class LiveButton extends StatelessWidget {
  const LiveButton({
    super.key,
    required this.text,
    required this.icon,
    this.onTap,
    this.loading = false,
  });
  final String text;
  final String icon;
  final Function()? onTap;
  final bool loading;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: AlignmentDirectional.center,
          children: [
            CupertinoButton(
                onPressed: onTap,
                child: icon.toImage
                  ..width = 62.w
                  ..height = 62.h),
            if (loading) _buildLoadView()
          ],
        ),
        text.toText..style = Styles.ts_FFFFFF_opacity70_14sp,
      ],
    );
  }

  Widget _buildLoadView() {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        Container(
          width: 62.w,
          height: 62.h,
          decoration: const BoxDecoration(
            shape: BoxShape.rectangle,
            color: Color(0xFF00D66A),
            borderRadius: BorderRadius.all(Radius.circular(24)),
          ),
        ),
        const CircularProgressIndicator(),
      ],
    );
  }

  LiveButton.microphone({
    super.key,
    this.onTap,
    bool on = true,
    this.loading = false,
  })  : text = StrRes.microphone,
        icon = on ? ImageRes.liveMicOn : ImageRes.liveMicOff;

  LiveButton.speaker({
    super.key,
    this.onTap,
    bool on = true,
    this.loading = false,
  })  : text = StrRes.speaker,
        icon = on ? ImageRes.liveSpeakerOn : ImageRes.liveSpeakerOff;

  LiveButton.hungUp({
    super.key,
    this.onTap,
    this.loading = false,
  })  : text = StrRes.hangUp,
        icon = ImageRes.liveHangUp;

  LiveButton.reject({
    super.key,
    this.onTap,
    this.loading = false,
  })  : text = StrRes.reject,
        icon = ImageRes.liveHangUp;

  LiveButton.cancel({
    super.key,
    this.onTap,
    this.loading = false,
  })  : text = StrRes.cancel,
        icon = ImageRes.liveHangUp;

  LiveButton.pickUp({
    super.key,
    this.onTap,
    this.loading = false,
  })  : text = StrRes.pickUp,
        icon = ImageRes.livePicUp;
}
