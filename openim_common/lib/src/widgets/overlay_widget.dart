import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:openim_common/openim_common.dart';

class OverlayWidget {
  static final OverlayWidget singleton = OverlayWidget._();

  factory OverlayWidget() => singleton;

  OverlayWidget._();

  OverlayState? _overlayState;
  OverlayEntry? _overlayEntry;
  bool _isVisible = false;

  OverlayState? _dialogOverlayState;
  OverlayEntry? _dialogOverlayEntry;
  bool _isDialogVisible = false;

  OverlayState? _toastOverlayState;
  OverlayEntry? _toastOverlayEntry;
  bool _isToastVisible = false;
  Timer? _toastTimer;

  OverlayState? _autoCloseDialogOverlayState;
  OverlayEntry? _autoCloseDialogOverlayEntry;
  bool _isAutoCloseDialogVisible = false;
  Timer? _autoCloseTimer;

  void showDialog({
    required BuildContext context,
    required Widget child,
  }) async {
    if (_isDialogVisible) return;
    _dialogOverlayState = Overlay.of(context);
    _dialogOverlayEntry = OverlayEntry(
      builder: (BuildContext context) => DialogContainer(
        onDismiss: hideDialog,
        child: child,
      ),
    );
    _isDialogVisible = true;
    _dialogOverlayState?.insert(_dialogOverlayEntry!, above: _overlayEntry);
  }

  void showAutoCloseDialog({
    required BuildContext context,
    required Widget child,
    int countdownSeconds = 3,
    String buttonText = 'ok',
    VoidCallback? onAutoClose,
  }) async {
    if (_isAutoCloseDialogVisible) return;
    _autoCloseDialogOverlayState = Overlay.of(context);
    _autoCloseDialogOverlayEntry = OverlayEntry(
      builder: (BuildContext context) => AutoCloseDialogContainer(
        onDismiss: hideAutoCloseDialog,
        countdownSeconds: countdownSeconds,
        buttonText: buttonText,
        onAutoClose: onAutoClose,
        child: child,
      ),
    );
    _isAutoCloseDialogVisible = true;
    _autoCloseDialogOverlayState?.insert(_autoCloseDialogOverlayEntry!, above: _overlayEntry);
  }

  // Convenience method for showing a simple auto-close alert dialog
  void showAutoCloseAlert({
    required BuildContext context,
    String? title,
    String? message,
    int countdownSeconds = 3,
    String buttonText = 'ok',
    VoidCallback? onAutoClose,
  }) {
    showAutoCloseDialog(
      context: context,
      countdownSeconds: countdownSeconds,
      buttonText: buttonText,
      onAutoClose: onAutoClose,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null)
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
          if (message != null) ...[
            if (title != null) const SizedBox(height: 12),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  void showBottomSheet({
    required BuildContext context,
    required Widget Function(AnimationController? controller) child,
  }) {
    if (_isVisible) return;
    _overlayState = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (BuildContext context) => BottomSheetContainer(
        onDismiss: dismiss,
        child: child,
      ),
    );
    _isVisible = true;
    _overlayState?.insert(_overlayEntry!);
  }

  void showToast({
    required BuildContext context,
    required String text,
    VoidCallback? onDelayDismiss,
  }) async {
    if (_isToastVisible) return;
    var count = 3;
    _toastTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      count--;

      if (count == 0) {
        timer.cancel;
        hideToast();
        onDelayDismiss?.call();
      }
    });
    _toastOverlayState = Overlay.of(context);
    _toastOverlayEntry = OverlayEntry(
      builder: (BuildContext context) => DialogContainer(
        onDismiss: hideToast,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            text,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
    _isToastVisible = true;
    _toastOverlayState?.insert(_toastOverlayEntry!, above: _overlayEntry);
  }

  void hideDialog() {
    if (!_isDialogVisible) return;
    _dialogOverlayEntry?.remove();
    _dialogOverlayEntry = null;
    _isDialogVisible = false;
  }

  void hideAutoCloseDialog() {
    if (!_isAutoCloseDialogVisible) return;
    _autoCloseTimer?.cancel();
    _autoCloseTimer = null;
    _autoCloseDialogOverlayEntry?.remove();
    _autoCloseDialogOverlayEntry = null;
    _isAutoCloseDialogVisible = false;
  }

  void hideToast() {
    if (!_isToastVisible) return;
    _toastTimer = null;
    _toastOverlayEntry?.remove();
    _toastOverlayEntry = null;
    _isToastVisible = false;
  }

  dismiss() async {
    if (!_isVisible && !_isDialogVisible && !_isToastVisible && !_isAutoCloseDialogVisible) return;
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isVisible = false;

    _dialogOverlayEntry?.remove();
    _dialogOverlayEntry = null;
    _isDialogVisible = false;

    _toastOverlayEntry?.remove();
    _toastOverlayEntry = null;
    _isToastVisible = false;

    _autoCloseTimer?.cancel();
    _autoCloseTimer = null;
    _autoCloseDialogOverlayEntry?.remove();
    _autoCloseDialogOverlayEntry = null;
    _isAutoCloseDialogVisible = false;
  }
}

class AutoCloseDialogContainer extends StatefulWidget {
  const AutoCloseDialogContainer({
    Key? key,
    required this.child,
    required this.countdownSeconds,
    required this.buttonText,
    this.backgroundColor,
    this.onDismiss,
    this.onAutoClose,
  }) : super(key: key);

  final Widget child;
  final int countdownSeconds;
  final String buttonText;
  final Color? backgroundColor;
  final VoidCallback? onDismiss;
  final VoidCallback? onAutoClose;

  @override
  State<AutoCloseDialogContainer> createState() => _AutoCloseDialogContainerState();
}

class _AutoCloseDialogContainerState extends State<AutoCloseDialogContainer> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late int _currentCountdown;
  Timer? _countdownTimer;

  @override
  void initState() {
    _currentCountdown = widget.countdownSeconds;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _startCountdown();
        } else if (status == AnimationStatus.dismissed) {
          widget.onDismiss?.call();
        }
      });
    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller);
    _controller.forward();

    super.initState();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentCountdown--;
      });

      if (_currentCountdown <= 0) {
        timer.cancel();
        widget.onAutoClose?.call();
        _controller.reverse();
      }
    });
  }

  void _onManualClose() {
    _countdownTimer?.cancel();
    _controller.reverse();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: GestureDetector(
        onTap: () {
          // Do nothing to prevent accidental closure by tapping outside
        },
        behavior: HitTestBehavior.translucent,
        child: Material(
          color: widget.backgroundColor ?? Colors.black.withAlpha(150),
          child: Center(
            child: _wrapChildWithCountdownButton(widget.child),
          ),
        ),
      ),
    );
  }

  Widget _wrapChildWithCountdownButton(Widget child) {
    // Reference CustomDialog style from dialog.dart
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          width: 300.w,
          color: Styles.c_FFFFFF,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Content section
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 24.h),
                alignment: Alignment.center,
                child: child,
              ),

              // Divider
              Container(
                height: 0.5.h,
                color: Styles.c_E8EAEF,
              ),

              // Button section (single button instead of two)
              Container(
                width: double.infinity,
                height: 48.h,
                child: GestureDetector(
                  onTap: () {
                    _onManualClose();
                    widget.onAutoClose?.call();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Styles.c_FFFFFF,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _currentCountdown > 0 ? '${widget.buttonText}（${_currentCountdown}s）' : widget.buttonText,
                      style: Styles.ts_0089FF_17sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DialogContainer extends StatefulWidget {
  const DialogContainer({
    Key? key,
    required this.child,
    this.backgroundColor,
    this.onDismiss,
  }) : super(key: key);

  final Widget child;
  final Color? backgroundColor;
  final VoidCallback? onDismiss;

  @override
  State<DialogContainer> createState() => _DialogContainerState();
}

class _DialogContainerState extends State<DialogContainer> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          // _controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          widget.onDismiss?.call();
          // _controller.forward();
        }
      });
    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller)
        /*..addListener(() {
            setState(() {});
          })*/
        ;
    _controller.forward();

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: GestureDetector(
        onTap: () {
          _controller.reverse();
        },
        behavior: HitTestBehavior.translucent,
        child: Material(
          color: widget.backgroundColor ?? Colors.black.withAlpha(150),
          child: Center(child: widget.child),
        ),
      ),
    );
  }
}

class BottomSheetContainer extends StatefulWidget {
  const BottomSheetContainer({
    Key? key,
    required this.child,
    this.onDismiss,
  }) : super(key: key);

  final Widget Function(AnimationController? controller) child;
  final Function()? onDismiss;

  @override
  State<BottomSheetContainer> createState() => _BottomSheetContainerState();
}

class _BottomSheetContainerState extends State<BottomSheetContainer> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _childAnimation;
  late Animation<double> _bgAnimation;

  @override
  void initState() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          // _controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          widget.onDismiss?.call();
          // _controller.forward();
        }
      });
    _childAnimation = Tween(begin: const Offset(0, 1), end: const Offset(0, 0)).animate(_controller)
        /*..addListener(() {
            setState(() {});
          })*/
        ;
    _bgAnimation = Tween(begin: 0.5, end: 1.0).animate(_controller)
        /*..addListener(() {
            setState(() {});
          })*/
        ;

    _controller.forward();

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _controller.reverse();
      },
      onVerticalDragEnd: (detail) {
        _controller.reverse();
      },
      behavior: HitTestBehavior.translucent,
      child: FadeTransition(
          opacity: _bgAnimation,
          child: Material(
            color: Colors.black.withAlpha(150),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SlideTransition(
                  position: _childAnimation,
                  child: widget.child.call(_controller),
                ),
              ],
            ),
          )),
    );
  }
}

class PopupMenuButtonContainer extends StatefulWidget {
  const PopupMenuButtonContainer({
    Key? key,
    required this.builder,
    this.alignment = Alignment.topRight,
    this.onStartCloseAnimation,
    this.onCloseAnimationEnd,
  }) : super(key: key);

  final Widget Function(AnimationController? controller) builder;
  final Alignment alignment;
  final Future<bool> Function()? onStartCloseAnimation;
  final Function()? onCloseAnimationEnd;

  @override
  State<PopupMenuButtonContainer> createState() => _PopupMenuButtonContainerState();
}

class _PopupMenuButtonContainerState extends State<PopupMenuButtonContainer> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 80),
      vsync: this,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          // _controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          widget.onCloseAnimationEnd?.call();
          // _controller.forward();
        }
      });
    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller)
        /*..addListener(() {
            setState(() {});
          })*/
        ;
    _controller.forward();

    widget.onStartCloseAnimation?.call().then((value) {
      if (value) _controller.reverse();
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      alignment: widget.alignment,
      child: widget.builder.call(_controller),
    );
  }
}

class OverlayPopupMenuButton extends StatefulWidget {
  const OverlayPopupMenuButton({
    Key? key,
    required this.child,
    required this.builder,
    this.closePopMenuCompleter,
  }) : super(key: key);
  final Widget child;
  final Widget Function(AnimationController? controller) builder;
  final Completer<bool>? closePopMenuCompleter;

  @override
  State<OverlayPopupMenuButton> createState() => OverlayPopupMenuButtonState();
}

class OverlayPopupMenuButtonState extends State<OverlayPopupMenuButton> {
  OverlayState? _overlayState;
  OverlayEntry? _overlayEntry;
  bool _isVisible = false;
  final _globalKey = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  dismiss() async {
    if (!_isVisible) return;
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isVisible = false;
  }

  Rect getWidgetGlobalRect() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final topLeft = renderBox.localToGlobal(Offset.zero);
    final bottomRight = renderBox.localToGlobal(renderBox.size.bottomRight(Offset.zero));
    return Rect.fromPoints(topLeft, bottomRight);
  }

  @override
  Widget build(BuildContext context) {
    widget.closePopMenuCompleter?.future.then((value) => dismiss());
    return GestureDetector(
      onTapDown: (details) {
        if (_isVisible) return;
        _isVisible = true;
        final rect = getWidgetGlobalRect();
        final completer = Completer<bool>();
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;
        final contentWidth = _globalKey.currentContext?.size?.width ?? 0;
        final contentHeight = _globalKey.currentContext?.size?.height ?? 0;
        final popupMenuButtonWidth = rect.right - rect.left;
        final popupMenuButtonHeight = rect.bottom - rect.top;
        double? left = rect.left + popupMenuButtonWidth / 2 - contentWidth / 2;
        double? top = rect.top + popupMenuButtonHeight;
        double? right = rect.right - popupMenuButtonWidth / 2;
        double? bottom;
        bool reverse = false;
        if (left < 0) {
          left = 0;
        } else if (left + contentWidth > screenWidth) {
          left = screenWidth - contentWidth;
        }

        if (top + contentHeight > screenHeight) {
          top = null;
          bottom = screenHeight - rect.top;
          reverse = true;
        }

        _overlayState = Overlay.of(context);
        _overlayEntry = OverlayEntry(
          builder: (BuildContext context) => GestureDetector(
            onTap: () {
              // completer.complete(true);
              dismiss();
            },
            behavior: HitTestBehavior.translucent,
            child: Stack(
              children: [
                Positioned(
                  // right: right,
                  top: top,
                  bottom: bottom,
                  left: left,
                  child: PopupMenuButtonContainer(
                    onCloseAnimationEnd: dismiss,
                    onStartCloseAnimation: () => completer.future,
                    alignment: reverse ? Alignment.bottomCenter : Alignment.topCenter,
                    builder: widget.builder,
                  ),
                )
              ],
            ),
          ),
        );
        _overlayState?.insert(_overlayEntry!);
      },
      child: Stack(
        children: [
          Offstage(
            child: SizedBox(key: _globalKey, child: widget.builder.call(null)),
          ),
          widget.child,
        ],
      ),
    );
  }
}

class Toast {
  static void show(BuildContext context, String message, {Duration duration = const Duration(seconds: 2)}) {
    OverlayEntry? overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _ToastWidget(
        message: message,
        onDismiss: () => overlayEntry?.remove(),
        duration: duration,
      ),
    );

    Overlay.of(context).insert(overlayEntry);
  }
}

// Widget for displaying the toast with animation
class _ToastWidget extends StatefulWidget {
  final String message;
  final VoidCallback onDismiss;
  final Duration duration;

  const _ToastWidget({
    required this.message,
    required this.onDismiss,
    required this.duration,
  });

  @override
  _ToastWidgetState createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300), // Fade in/out duration
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    // Start animation
    _controller.forward();

    // Dismiss after duration
    Timer(widget.duration, () {
      _controller.reverse().then((_) => widget.onDismiss());
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              widget.message,
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
