import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:openim_common/openim_common.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PinnedMessageWidget extends StatefulWidget {
  final List<Message> messages;
  final Function(Message)? onRemove;
  final Function(Message)? onTap;

  const PinnedMessageWidget({
    super.key,
    required this.messages,
    this.onRemove,
    this.onTap,
  });

  @override
  State<PinnedMessageWidget> createState() => _PinnedMessageWidgetState();
}

class _PinnedMessageWidgetState extends State<PinnedMessageWidget> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late final AnimationController _controller;
  late final Animation<double> _sizeAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _sizeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void didUpdateWidget(covariant PinnedMessageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.messages.length <= 1) {
      _collapse();
    }
    print('didUpdateWidget');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _expand() {
    setState(() {
      _isExpanded = true;
      _controller.forward();
    });
  }

  void _collapse() {
    setState(() {
      _isExpanded = false;
      _controller.reverse();
    });
  }

  void _toggleExpand() {
    if (_isExpanded) {
      _collapse();
    } else {
      _expand();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.messages.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: _isExpanded ? const EdgeInsets.symmetric(horizontal: 8) : EdgeInsets.fromLTRB(8.w, 0, 8.w, 8.w),
      decoration: BoxDecoration(
        color: Styles.c_FFFFFF,
        borderRadius: BorderRadius.circular(5),
        shape: BoxShape.rectangle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildItem(widget.messages.first),
          if (widget.messages.length > 1)
            Stack(
              children: [
                SizeTransition(
                  sizeFactor: _sizeAnimation,
                  axis: Axis.vertical,
                  axisAlignment: -1,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        ...widget.messages.sublist(1).map((e) => _buildItem(e)),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: _toggleExpand,
                          child: ImageRes.expaned.toImage
                            ..height = 13.h
                            ..width = 40.w,
                        ),
                      ],
                    ),
                  ),
                ),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: _isExpanded ? 0 : 1,
                  child: _buildMoreItemFlag(),
                ),
              ],
            ),
        ],
      ),
    );
  }

  String _getMessageText(Message message) {
    final nickname = message.senderNickname ?? 'Unknown User';

    if (message.contentType == MessageType.groupInfoSetAnnouncementNotification) {
      final elem = message.notificationElem!;
      final map = jsonDecode(elem.detail!);
      final notification = GroupNotification.fromJson(map);

      return '$nickname: ${notification.group?.notification ?? ''}';
    } else if (message.contentType == MessageType.atText) {
      final atElem = message.atTextElem;
      final atUsers = atElem?.atUsersInfo;
      var text = atElem?.text;

      if (atUsers?.isNotEmpty == true) {
        for (final u in atUsers!) {
          text = text?.replaceAll('@${u.atUserID}', '@${u.groupNickname}');
        }
      }

      return '$nickname: ${text ?? ''}';
    }

    return '$nickname: ${message.textElem?.content ?? ''}';
  }

  Widget _buildRemoveButton(Message message) {
    if (message.contentType == MessageType.groupInfoSetAnnouncementNotification) {
      return IconButton(
        color: _isExpanded ? Colors.grey.shade400 : Colors.transparent,
        icon: const Icon(Icons.keyboard_arrow_right, size: 20),
        onPressed: null,
      );
    }

    if (widget.onRemove == null) {
      return const SizedBox.shrink();
    }

    return (_isExpanded || widget.messages.length == 1
        ? CupertinoButton(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Text(
              StrRes.delMember,
              style: const TextStyle(fontSize: 12),
            ),
            onPressed: () {
              widget.onRemove?.call(message);

              if (widget.messages.length <= 1) {
                _collapse();
              }
            },
          )
        : const SizedBox());
  }

  Widget _buildItem(Message message) {
    return GestureDetector(
      onTap: () {
        if (_isExpanded || widget.messages.length == 1) {
          widget.onTap?.call(message);
        }
        if (widget.messages.length > 1) {
          _toggleExpand();
        }
      },
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            height: 40.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                8.horizontalSpace,
                message.contentType == MessageType.groupInfoSetAnnouncementNotification
                    ? (ImageRes.notice.toImage..height = 20.h)
                    : (ImageRes.msgPinedHead.toImage..height = 20.h),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getMessageText(message),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                14.horizontalSpace,
                _buildRemoveButton(message),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoreItemFlag() {
    return Column(
      children: [
        Container(
          height: 6.h,
          margin: EdgeInsets.symmetric(horizontal: 10.w),
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: Styles.c_E8EAEF,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(6),
              bottomRight: Radius.circular(6),
            ),
          ),
        ),
      ],
    );
  }
}
