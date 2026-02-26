import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

double kInputBoxMinHeight = 56.h;

class ChatInputBox extends StatefulWidget {
  const ChatInputBox({
    Key? key,
    required this.toolbox,
    required this.voiceRecordBar,
    required this.emojiView,
    required this.multiOpToolbox,
    this.allAtMap = const {},
    this.atCallback,
    this.controller,
    this.focusNode,
    this.style,
    this.atStyle,
    this.inputFormatters,
    this.enabled = true,
    this.isMultiModel = false,
    this.isNotInGroup = false,
    this.hintText,
    this.openAtList,
    this.forceCloseToolboxSub,
    this.quoteContent,
    this.quoteContentChild,
    this.onClearQuote,
    this.onSend,
    this.directionalText,
    this.onCloseDirectional,
  }) : super(key: key);
  final AtTextCallback? atCallback;
  final Map<String, String> allAtMap;
  final FocusNode? focusNode;
  final TextEditingController? controller;
  final TextStyle? style;
  final TextStyle? atStyle;
  final List<TextInputFormatter>? inputFormatters;
  final bool enabled;
  final bool isMultiModel;
  final bool isNotInGroup;
  final String? hintText;
  final String Function()? openAtList;
  final Widget toolbox;
  final Widget voiceRecordBar;
  final Widget emojiView;
  final Widget multiOpToolbox;
  final Stream? forceCloseToolboxSub;
  final String? quoteContent;
  final Widget? quoteContentChild;
  final Function()? onClearQuote;
  final ValueChanged<String>? onSend;
  final TextSpan? directionalText;
  final VoidCallback? onCloseDirectional;

  @override
  State<ChatInputBox> createState() => _ChatInputBoxState();
}

class _ChatInputBoxState extends State<ChatInputBox> /*with TickerProviderStateMixin */ {
  bool _toolsVisible = false;
  bool _emojiVisible = false;
  bool _leftKeyboardButton = false;
  bool _rightKeyboardButton = false;
  bool _sendButtonVisible = false;

  // late AnimationController _controller;
  // late Animation<double> _animation;
  bool get _showQuoteView => widget.quoteContentChild != null || IMUtils.isNotNullEmptyStr(widget.quoteContent);

  /// 不可使用时的透明度，如禁言开启
  double get _opacity => (widget.enabled ? 1 : .4);

  bool get _showDirectionalView => widget.directionalText != null;

  @override
  void initState() {
    widget.focusNode?.addListener(() {
      if (widget.focusNode!.hasFocus) {
        setState(() {
          _toolsVisible = false;
          _emojiVisible = false;
          _leftKeyboardButton = false;
          _rightKeyboardButton = false;
        });
      }
    });

    widget.forceCloseToolboxSub?.listen((value) {
      if (!mounted) return;
      setState(() {
        _toolsVisible = false;
        _emojiVisible = false;
        _rightKeyboardButton = false;
      });
    });

    widget.controller?.addListener(() {
      setState(() {
        _sendButtonVisible = widget.controller!.text.isNotEmpty;
      });
      // if (widget.controller!.text.isEmpty) {
      //   _controller.reverse();
      // } else {
      //   _controller.forward();
      // }
    });

    super.initState();
  }

  @override
  void dispose() {
    // _controller.dispose();
    // widget.controller?.dispose();
    // widget.focusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) widget.controller?.clear();
    return widget.isNotInGroup
        ? const ChatDisableInputBox()
        : widget.isMultiModel
            ? widget.multiOpToolbox
            : Column(
                children: [
                  Container(
                    // height: 56.h,
                    constraints: BoxConstraints(minHeight: kInputBoxMinHeight),
                    color: Styles.c_F0F2F6,
                    child: Row(
                      children: [
                        12.horizontalSpace,
                        (_leftKeyboardButton
                            ? (ImageRes.openKeyboard.toImage..onTap = onTapLeftKeyboard)
                            : (ImageRes.openVoice.toImage..onTap = onTapSpeak))
                          ..width = 32.w
                          ..height = 32.h
                          ..opacity = _opacity
                          ..color = Get.isDarkMode ? Colors.white : null,
                        12.horizontalSpace,
                        Expanded(
                          child: Stack(
                            children: [
                              Offstage(
                                offstage: _leftKeyboardButton,
                                child: _textFiled,
                              ),
                              Offstage(
                                offstage: !_leftKeyboardButton,
                                child: widget.voiceRecordBar,
                              ),
                            ],
                          ),
                        ),
                        12.horizontalSpace,
                        (_rightKeyboardButton
                            ? (ImageRes.openKeyboard.toImage..onTap = onTapRightKeyboard)
                            : (ImageRes.openEmoji.toImage..onTap = onTapEmoji))
                          ..width = 32.w
                          ..height = 32.h
                          ..opacity = _opacity
                          ..color = Get.isDarkMode ? Colors.white : null,
                        12.horizontalSpace,
                        (_sendButtonVisible ? ImageRes.sendMessage : ImageRes.openToolbox).toImage
                          ..width = 32.w
                          ..height = 32.h
                          ..opacity = _opacity
                          ..onTap = _sendButtonVisible ? send : toggleToolbox
                          ..color = Get.isDarkMode && !_sendButtonVisible ? Colors.white : null,
                        12.horizontalSpace,
                        // Visibility(
                        //   visible: !_leftKeyboardButton || !_rightKeyboardButton,
                        //   child: Container(
                        //     width: 60.0.w * (1.0 - _animation.value),
                        //     margin: EdgeInsets.only(right: 4.w),
                        //     child: Button(
                        //       text: StrRes.send,
                        //       height: 32.h,
                        //       onTap: send,
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                  if (_showQuoteView)
                    _QuoteView(
                      content: widget.quoteContent!,
                      contentChild: widget.quoteContentChild,
                      onClearQuote: widget.onClearQuote,
                    ),
                  if (_showDirectionalView)
                    _SubView(
                      textSpan: widget.directionalText,
                      onClose: () {
                        widget.onCloseDirectional?.call();
                      },
                    ),
                  Visibility(
                    visible: _toolsVisible,
                    child: FadeInUp(
                      duration: const Duration(milliseconds: 200),
                      child: widget.toolbox,
                    ),
                  ),
                  Visibility(
                    visible: _emojiVisible,
                    child: FadeInUp(
                      duration: const Duration(milliseconds: 200),
                      child: widget.emojiView,
                    ),
                  ),
                ],
              );
  }

  Widget get _textFiled => Container(
        margin: EdgeInsets.only(top: 10.h, bottom: _showQuoteView ? 4.h : 10.h),
        decoration: BoxDecoration(
          color: Styles.c_FFFFFF,
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: ChatTextField(
          allAtMap: widget.allAtMap,
          atCallback: widget.atCallback,
          controller: widget.controller,
          focusNode: widget.focusNode,
          style: widget.style ?? Styles.ts_0C1C33_17sp,
          atStyle: widget.atStyle ?? Styles.ts_0089FF_17sp,
          inputFormatters: widget.inputFormatters ?? [AtTextInputFormatter(widget.openAtList)],
          enabled: widget.enabled,
          hintText: widget.hintText,
          textAlign: widget.enabled ? TextAlign.start : TextAlign.center,
        ),
      );

  void send() {
    if (!widget.enabled) return;
    if (!_emojiVisible) focus();
    if (null != widget.onSend && null != widget.controller) {
      widget.onSend!(widget.controller!.text.toString().trim());
    }
  }

  void toggleToolbox() {
    if (!widget.enabled) return;
    setState(() {
      _toolsVisible = !_toolsVisible;
      _emojiVisible = false;
      _leftKeyboardButton = false;
      _rightKeyboardButton = false;
      widget.onClearQuote?.call();
      if (_toolsVisible) {
        unfocus();
      } else {
        focus();
      }
    });
  }

  void onTapSpeak() {
    if (!widget.enabled) return;
    //卡卡西修复 ios语音
    setState(() {
      _leftKeyboardButton = true;
      _rightKeyboardButton = false;
      _toolsVisible = false;
      _emojiVisible = false;
      unfocus();
    });

    // if (!widget.enabled) return;
    // Permissions.microphone(() => setState(() {
    //       _leftKeyboardButton = true;
    //       _rightKeyboardButton = false;
    //       _toolsVisible = false;
    //       _emojiVisible = false;
    //       widget.onClearQuote?.call();
    //       unfocus();
    //     }));
  }

  void onTapLeftKeyboard() {
    if (!widget.enabled) return;
    setState(() {
      _leftKeyboardButton = false;
      _toolsVisible = false;
      _emojiVisible = false;
      widget.onClearQuote?.call();
      focus();
    });
  }

  void onTapRightKeyboard() {
    if (!widget.enabled) return;
    setState(() {
      _rightKeyboardButton = false;
      _toolsVisible = false;
      _emojiVisible = false;
      widget.onClearQuote?.call();
      focus();
    });
  }

  void onTapEmoji() {
    if (!widget.enabled) return;
    setState(() {
      _rightKeyboardButton = true;
      _leftKeyboardButton = false;
      _emojiVisible = true;
      _toolsVisible = false;
      widget.onClearQuote?.call();
      unfocus();
    });
  }

  focus() {
    FocusScope.of(context).requestFocus(widget.focusNode);
  }

  unfocus() {
    widget.focusNode?.unfocus();
  }
}

class _QuoteView extends StatelessWidget {
  const _QuoteView({
    super.key,
    this.onClearQuote,
    required this.content,
    this.contentChild,
  });
  final Function()? onClearQuote;
  final String content;
  final Widget? contentChild;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 10.h, left: 56.w, right: 100.w),
      color: Styles.c_F0F2F6,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: onClearQuote,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 4.w),
          decoration: BoxDecoration(
            color: Styles.c_FFFFFF,
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: contentChild ??
                    Text(
                      content,
                      style: Styles.ts_8E9AB0_14sp,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
              ),
              ImageRes.delQuote.toImage
                ..width = 14.w
                ..height = 14.h,
            ],
          ),
        ),
      ),
    );
  }
}

class _SubView extends StatelessWidget {
  const _SubView({
    this.onClose,
    this.title,
    this.content,
    this.textSpan,
  }) : assert(content != null || textSpan != null, 'Either content or textSpan must be provided.');
  final VoidCallback? onClose;
  final String? title;
  final String? content;
  final InlineSpan? textSpan;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 10.h, left: 56.w, right: 100.w),
      color: Styles.c_F0F2F6,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: onClose,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 4.w),
          decoration: BoxDecoration(
            color: Styles.c_FFFFFF,
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Row(
                  children: [
                    if (title != null)
                      Text(
                        title!,
                        style: Styles.ts_8E9AB0_14sp,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (content != null)
                      Text(
                        title!,
                        style: Styles.ts_8E9AB0_14sp,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (textSpan != null)
                      Expanded(
                        child: RichText(
                          text: textSpan!,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
              ImageRes.delQuote.toImage
                ..width = 14.w
                ..height = 14.h,
            ],
          ),
        ),
      ),
    );
  }
}
