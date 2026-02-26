import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:openim_common/openim_common.dart';

/// A simple confirmation dialog that uses Overlay instead of Navigator
/// This avoids all the Navigator-related issues in complex scenarios
class SimpleConfirmationDialog {
  static Future<bool> show({
    required BuildContext context,
    required String content,
    Widget? customDialog,
    String? title,
    String? cancelText,
    String? confirmText,
  }) async {
    final cancel = cancelText ?? StrRes.cancel;
    final confirm = confirmText ?? StrRes.confirm;
    final completer = Completer<bool>();
    late OverlayEntry overlayEntry;
    _AnimatedDialogWrapperState? animationState;

    overlayEntry = OverlayEntry(
      builder: (context) => _AnimatedDialogWrapper(
        onStateCreated: (state) => animationState = state,
        child: customDialog ??
            _ConfirmationDialogWidget(
              content: content,
              title: title,
              cancelText: cancel,
              confirmText: confirm,
              onCancel: () async {
                await animationState?._playExitAnimation();
                overlayEntry.remove();
                completer.complete(false);
              },
              onConfirm: () async {
                await animationState?._playExitAnimation();
                overlayEntry.remove();
                completer.complete(true);
              },
            ),
      ),
    );

    // Insert overlay entry
    Overlay.of(context).insert(overlayEntry);

    return completer.future;
  }
}

// Animated wrapper for dialog entrance/exit animations
class _AnimatedDialogWrapper extends StatefulWidget {
  final Widget child;
  final Function(_AnimatedDialogWrapperState)? onStateCreated;

  const _AnimatedDialogWrapper({
    required this.child,
    this.onStateCreated,
  });

  @override
  State<_AnimatedDialogWrapper> createState() => _AnimatedDialogWrapperState();
}

class _AnimatedDialogWrapperState extends State<_AnimatedDialogWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _backgroundOpacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    _opacityAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );

    _backgroundOpacityAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );

    // Notify parent that state is created
    widget.onStateCreated?.call(this);
    
    // Start entrance animation
    _controller.forward();
  }

  Future<void> _playExitAnimation() async {
    await _controller.reverse();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Material(
          color: Colors.black.withOpacity(0.5 * _backgroundOpacityAnimation.value),
          child: Center(
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: Transform.scale(
                scale: 0.8 + (_scaleAnimation.value * 0.2), // Scale from 0.8 to 1.0
                child: child,
              ),
            ),
          ),
        );
      },
      child: widget.child,
    );
  }
}

class _ConfirmationDialogWidget extends StatelessWidget {
  final String content;
  final String? title;
  final String cancelText;
  final String confirmText;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const _ConfirmationDialogWidget({
    required this.content,
    this.title,
    required this.cancelText,
    required this.confirmText,
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        width: 300.w,
        color: Styles.c_FFFFFF,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title section
                if (title != null)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, content.isNotEmpty ? 16.h : 24.h),
                    alignment: Alignment.center,
                    child: Text(
                      title!,
                      textAlign: TextAlign.center,
                      style: Styles.ts_0C1C33_17sp.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                // Content section
                if (content.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(24.w, title != null ? 0 : 24.h, 24.w, 24.h),
                    alignment: Alignment.center,
                    child: Text(
                      content,
                      textAlign: TextAlign.center,
                      style: Styles.ts_0C1C33_17sp.copyWith(
                        color: const Color(0xFF666666),
                      ),
                    ),
                  ),

                // Divider
                Container(
                  height: 0.5.h,
                  color: Styles.c_E8EAEF,
                ),

                // Buttons section
                Row(
                  children: [
                    _buildButton(
                      text: cancelText,
                      textStyle: Styles.ts_0C1C33_17sp,
                      onTap: onCancel,
                    ),
                    Container(
                      color: Styles.c_E8EAEF,
                      width: 0.5.w,
                      height: 48.h,
                    ),
                    _buildButton(
                      text: confirmText,
                      textStyle: Styles.ts_0089FF_17sp,
                      onTap: onConfirm,
                    ),
                  ],
                )
              ],
            ),
          ),
    );
  }

  Widget _buildButton({
    required String text,
    required TextStyle textStyle,
    required VoidCallback onTap,
  }) =>
      Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: Styles.c_FFFFFF,
            ),
            height: 48.h,
            alignment: Alignment.center,
            child: Text(
              text,
              style: textStyle,
            ),
          ),
        ),
      );
}
