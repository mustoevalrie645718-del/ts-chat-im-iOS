import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:openim_common/openim_common.dart';
import 'package:uuid/uuid.dart';

typedef CustomAvatarBuilder = Widget? Function();

enum AvatarType { text, network, file, nineGrid, custom }

/// Configuration class for avatar appearance and behavior
class AvatarConfig {
  final double defaultSize;
  final Color defaultBackgroundColor;
  final TextStyle defaultTextStyle;
  final double defaultBorderRadius;
  final Duration heroAnimationDuration;

  const AvatarConfig({
    this.defaultSize = 44.0,
    this.defaultBackgroundColor = const Color(0xFF0089FF),
    this.defaultTextStyle = const TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.w500,
    ),
    this.defaultBorderRadius = 6.0,
    this.heroAnimationDuration = const Duration(milliseconds: 300),
  });
}

/// Layout configuration for nine-grid avatar display
class NineGridLayout {
  final int totalItems;
  final double itemSize;
  final double margin;
  final List<int> rowLengths;

  const NineGridLayout({
    required this.totalItems,
    required this.itemSize,
    required this.margin,
    required this.rowLengths,
  });

  /// Calculates optimal layout for given number of items
  factory NineGridLayout.calculate(int count, double avatarSize) {
    const double margin = 2.0;
    double itemSize;
    List<int> rowLengths;

    switch (count) {
      case 1:
        itemSize = avatarSize;
        rowLengths = [1];
        break;
      case 2:
        itemSize = avatarSize / 2;
        rowLengths = [2];
        break;
      case 3:
        itemSize = avatarSize / 2;
        rowLengths = [1, 2];
        break;
      case 4:
        itemSize = avatarSize / 2;
        rowLengths = [2, 2];
        break;
      case 5:
        itemSize = avatarSize / 3;
        rowLengths = [2, 3];
        break;
      case 6:
        itemSize = avatarSize / 3;
        rowLengths = [3, 3];
        break;
      case 7:
        itemSize = avatarSize / 3;
        rowLengths = [1, 3, 3];
        break;
      case 8:
        itemSize = avatarSize / 3;
        rowLengths = [2, 3, 3];
        break;
      case 9:
        itemSize = avatarSize / 3;
        rowLengths = [3, 3, 3];
        break;
      default:
        itemSize = avatarSize;
        rowLengths = [1];
    }

    return NineGridLayout(
      totalItems: count,
      itemSize: itemSize,
      margin: margin,
      rowLengths: rowLengths,
    );
  }
}

/// A versatile avatar widget supporting various display modes:
/// - Text avatars with initials
/// - Network/local image avatars
/// - Nine-grid group avatars
/// - Custom builder patterns
class AvatarView extends StatelessWidget {
  const AvatarView({
    super.key,
    this.width,
    this.height,
    this.onTap,
    this.url,
    this.file,
    this.builder,
    this.text,
    this.textStyle,
    this.onLongPress,
    this.isCircle = false,
    this.borderRadius,
    this.enabledPreview = false,
    this.lowMemory = false,
    this.nineGridUrl = const [],
    this.isGroup = false,
    this.showDefaultAvatar = true,
    this.config = const AvatarConfig(),
    this.heroTag,
  });

  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final String? url;
  final File? file;
  final CustomAvatarBuilder? builder;
  final bool isCircle;
  final BorderRadius? borderRadius;
  final bool enabledPreview;
  final String? text;
  final TextStyle? textStyle;
  final bool lowMemory;
  final List<String> nineGridUrl;
  final bool isGroup;
  final bool showDefaultAvatar;
  final AvatarConfig config;
  final String? heroTag;

  /// Computed avatar size based on width/height or default
  double get _avatarSize => min(
        width ?? config.defaultSize.w,
        height ?? config.defaultSize.h,
      );

  /// Text style for avatar text, with fallback to config
  TextStyle get _textStyle =>
      textStyle ?? Styles.ts_FFFFFF_16sp;

  /// Background color for text avatars
  Color get _backgroundColor =>
      config.defaultBackgroundColor;

  /// Determines the avatar type based on available data
  AvatarType get _avatarType {
    if (builder != null) return AvatarType.custom;
    if (nineGridUrl.isNotEmpty) return AvatarType.nineGrid;
    if (file != null || _isUrlValid || _isAssetsPath) return AvatarType.network;
    return AvatarType.text;
  }

  /// Gets display text for text avatars (first character of name)
  String? get _displayText {
    if (isGroup) return null;
    if (text != null && text!.trim().isNotEmpty) {
      return text!.trim().substring(0, 1).toUpperCase();
    }
    return null;
  }

  /// Validates if the provided URL is valid for network loading
  bool get _isUrlValid => IMUtils.isUrlValid(url);

  /// Checks if the URL is an assets path
  bool get _isAssetsPath => url?.startsWith('assets/') == true;

  /// Gets the tap handler, with preview support if enabled
  VoidCallback? get _tapHandler {
    if (onTap != null) return onTap;
    if (enabledPreview && _isUrlValid) {
      return () => IMUtils.previewUrlPicture([
            MediaSource(thumbnail: url!, url: url!)
          ]);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final heroTagValue = heroTag ?? const Uuid().v4();
    final child = _buildGestureWrapper(_buildAvatarContent());

    return Hero(
      tag: heroTagValue,
      child: _buildClippedContainer(child),
    );
  }

  /// Wraps content with gesture detection
  Widget _buildGestureWrapper(Widget child) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _tapHandler,
      onLongPress: onLongPress,
      child: child,
    );
  }

  /// Builds the main avatar content based on type
  Widget _buildAvatarContent() {
    switch (_avatarType) {
      case AvatarType.custom:
        return builder!.call() ?? _buildTextAvatar();
      case AvatarType.nineGrid:
        return _buildNineGridAvatar();
      case AvatarType.network:
        return _buildImageAvatar();
      case AvatarType.text:
        return _buildTextAvatar();
      case AvatarType.file:
        return _buildImageAvatar();
    }
  }

  /// Applies clipping based on shape configuration
  Widget _buildClippedContainer(Widget child) {
    if (isCircle) {
      return ClipOval(child: child);
    }
    return ClipRRect(
      borderRadius: borderRadius ??
          BorderRadius.circular(config.defaultBorderRadius.r),
      child: child,
    );
  }

  /// Builds text-based avatar with initials or default icon
  Widget _buildTextAvatar() {
    return Container(
      width: _avatarSize,
      height: _avatarSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _backgroundColor,
        shape: BoxShape.rectangle,
      ),
      child: _buildTextAvatarContent(),
    );
  }

  /// Builds content for text avatar (text or icon)
  Widget? _buildTextAvatarContent() {
    if (_displayText != null) {
      return Text(_displayText!, style: _textStyle);
    }

    if (showDefaultAvatar) {
      return FaIcon(
        isGroup ? FontAwesomeIcons.userGroup : FontAwesomeIcons.solidUser,
        color: Colors.white,
        size: _avatarSize / 2,
      );
    }

    return null;
  }

  /// Builds network, file, or assets image avatar
  Widget _buildImageAvatar() {
    if (file != null) {
      return ImageUtil.fileImage(file: file!);
    }

    // Handle assets images
    if (_isAssetsPath) {
      return ImageUtil.assetImage(
        url!,
        width: _avatarSize,
        height: _avatarSize,
        fit: BoxFit.cover,
      );
    }

    // Handle network images
    return ImageUtil.networkImage(
      url: url!,
      width: _avatarSize,
      height: _avatarSize,
      fit: BoxFit.cover,
      lowMemory: lowMemory,
      loadProgress: false,
      errorWidget: _buildTextAvatar(),
      loadingWidet: _buildTextAvatar(),
    );
  }

  /// Builds nine-grid avatar layout for group avatars
  Widget _buildNineGridAvatar() {
    return Container(
      width: _avatarSize,
      height: _avatarSize,
      color: Colors.grey[300],
      padding: const EdgeInsets.all(2.0),
      alignment: Alignment.center,
      child: _buildNineGridContent(),
    );
  }

  /// Builds the nine-grid layout content
  Widget _buildNineGridContent() {
    final layout = NineGridLayout.calculate(nineGridUrl.length, _avatarSize);
    final rows = <Widget>[];
    int currentIndex = 0;

    for (final rowLength in layout.rowLengths) {
      rows.add(_buildNineGridRow(
        length: rowLength,
        startIndex: currentIndex,
        itemSize: layout.itemSize,
        margin: layout.margin,
      ));
      currentIndex += rowLength;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: rows,
    );
  }

  /// Builds a single row in the nine-grid layout
  Widget _buildNineGridRow({
    required int length,
    required int startIndex,
    required double itemSize,
    required double margin,
  }) {
    final rowItems = <Widget>[];

    for (int i = 0; i < length; i++) {
      final index = startIndex + i;
      if (index < nineGridUrl.length) {
        rowItems.add(_buildNineGridItem(nineGridUrl[index], itemSize));

        // Add separator except for last item
        if (i < length - 1) {
          rowItems.add(_buildGridSeparator(margin, itemSize));
        }
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: rowItems,
    );
  }

  /// Builds individual nine-grid item
  Widget _buildNineGridItem(String? imageUrl, double size) {
    return SizedBox(
      width: size,
      height: size,
      child: AvatarView(
        url: imageUrl,
        width: size,
        height: size,
        isCircle: false,
        borderRadius: BorderRadius.circular(2.r),
        enabledPreview: false,
        showDefaultAvatar: false,
      ),
    );
  }

  /// Builds separator between grid items
  Widget _buildGridSeparator(double width, double height) {
    return Container(
      width: width,
      height: height,
      color: Colors.white,
    );
  }
}

/// A simple red dot indicator widget for notifications
class RedDotView extends StatelessWidget {
  const RedDotView({
    super.key,
    this.size = 8.0,
    this.color,
  });

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color ?? Styles.c_FF381F,
        shape: BoxShape.circle,
        boxShadow: _buildShadows(),
      ),
    );
  }

  /// Builds the shadow effects for the red dot
  List<BoxShadow> _buildShadows() {
    return [
      BoxShadow(
        color: const Color(0x26C61B4A),
        offset: Offset(1.15.w, 1.15.h),
        blurRadius: 57.58.r,
      ),
      BoxShadow(
        color: const Color(0x1AC61B4A),
        offset: Offset(2.3.w, 2.3.h),
        blurRadius: 11.52.r,
      ),
      BoxShadow(
        color: const Color(0x0DC61B4A),
        offset: Offset(4.61.w, 4.61.h),
        blurRadius: 17.28.r,
      ),
    ];
  }
}