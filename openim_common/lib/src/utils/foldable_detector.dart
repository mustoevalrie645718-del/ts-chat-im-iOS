import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

/// Fold state information from the native Android side.
class FoldState {
  final bool isFoldable;
  final String? state; // FLAT, HALF_OPENED
  final String? orientation; // HORIZONTAL, VERTICAL
  final bool isSeparating;

  const FoldState({
    required this.isFoldable,
    this.state,
    this.orientation,
    this.isSeparating = false,
  });

  factory FoldState.fromMap(Map<dynamic, dynamic> map) {
    return FoldState(
      isFoldable: map['isFoldable'] as bool? ?? false,
      state: map['state'] as String?,
      orientation: map['orientation'] as String?,
      isSeparating: map['isSeparating'] as bool? ?? false,
    );
  }

  /// Whether the device is currently in a flat (fully unfolded) state.
  bool get isFlat => state == 'FLAT';

  /// Whether the device is currently in a half-opened (tent/laptop) state.
  bool get isHalfOpened => state == 'HALF_OPENED';

  @override
  String toString() {
    return 'FoldState(isFoldable: $isFoldable, state: $state, orientation: $orientation, isSeparating: $isSeparating)';
  }
}

/// Detailed folding feature information including bounds.
class FoldingFeatureInfo extends FoldState {
  final String? occlusionType; // NONE, FULL
  final Map<String, int>? bounds; // left, top, right, bottom

  const FoldingFeatureInfo({
    required super.isFoldable,
    super.state,
    super.orientation,
    super.isSeparating,
    this.occlusionType,
    this.bounds,
  });

  factory FoldingFeatureInfo.fromMap(Map<dynamic, dynamic> map) {
    Map<String, int>? boundsMap;
    if (map['bounds'] != null) {
      final rawBounds = map['bounds'] as Map<dynamic, dynamic>;
      boundsMap = {
        'left': rawBounds['left'] as int,
        'top': rawBounds['top'] as int,
        'right': rawBounds['right'] as int,
        'bottom': rawBounds['bottom'] as int,
      };
    }

    return FoldingFeatureInfo(
      isFoldable: map['isFoldable'] as bool? ?? false,
      state: map['state'] as String?,
      orientation: map['orientation'] as String?,
      isSeparating: map['isSeparating'] as bool? ?? false,
      occlusionType: map['occlusionType'] as String?,
      bounds: boundsMap,
    );
  }

  @override
  String toString() {
    return 'FoldingFeatureInfo(isFoldable: $isFoldable, state: $state, orientation: $orientation, isSeparating: $isSeparating, occlusionType: $occlusionType, bounds: $bounds)';
  }
}

/// Utility class for detecting foldable devices using native Android APIs.
///
/// This class uses Method Channel to communicate with the native Android side
/// which uses `androidx.window:window` library for accurate foldable detection.
///
/// Example usage:
/// ```dart
/// // Check if device is foldable
/// final isFoldable = await FoldableDetector.isFoldable;
///
/// // Get current fold state
/// final state = await FoldableDetector.getFoldState();
/// if (state.isFlat) {
///   // Device is fully unfolded
/// }
///
/// // Listen for fold state changes
/// FoldableDetector.onFoldStateChanged.listen((state) {
///   print('Fold state changed: $state');
/// });
/// ```
class FoldableDetector {
  FoldableDetector._();

  static const MethodChannel _channel = MethodChannel('io.openim/foldable');
  static const EventChannel _eventChannel = EventChannel('io.openim/foldable_events');

  static Stream<FoldState>? _onFoldStateChanged;

  /// Check if the current device is a foldable device.
  ///
  /// This method uses the native `androidx.window` library to detect
  /// if the device has a folding feature (hinge or fold).
  ///
  /// Returns `false` on iOS or if detection fails.
  static Future<bool> get isFoldable async {
    if (!Platform.isAndroid) {
      return false;
    }

    try {
      final result = await _channel.invokeMethod<bool>('isFoldable');
      return result ?? false;
    } on PlatformException catch (e) {
      print('FoldableDetector: Error checking isFoldable: ${e.message}');
      return false;
    } on MissingPluginException {
      // Method channel not registered (e.g., running on iOS or web)
      return false;
    }
  }

  /// Get the current fold state of the device.
  ///
  /// Returns detailed information about the fold state including:
  /// - Whether the device is foldable
  /// - Current state (FLAT, HALF_OPENED)
  /// - Orientation (HORIZONTAL, VERTICAL)
  /// - Whether the fold is separating content
  static Future<FoldState> getFoldState() async {
    if (!Platform.isAndroid) {
      return const FoldState(isFoldable: false);
    }

    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>('getFoldState');
      if (result != null) {
        return FoldState.fromMap(result);
      }
      return const FoldState(isFoldable: false);
    } on PlatformException catch (e) {
      print('FoldableDetector: Error getting fold state: ${e.message}');
      return const FoldState(isFoldable: false);
    } on MissingPluginException {
      return const FoldState(isFoldable: false);
    }
  }

  /// Get detailed folding feature information including bounds.
  ///
  /// Returns additional information such as:
  /// - Occlusion type (NONE, FULL)
  /// - Bounds of the folding feature (left, top, right, bottom)
  static Future<FoldingFeatureInfo> getFoldingFeatureInfo() async {
    if (!Platform.isAndroid) {
      return const FoldingFeatureInfo(isFoldable: false);
    }

    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>('getFoldingFeatureInfo');
      if (result != null) {
        return FoldingFeatureInfo.fromMap(result);
      }
      return const FoldingFeatureInfo(isFoldable: false);
    } on PlatformException catch (e) {
      print('FoldableDetector: Error getting folding feature info: ${e.message}');
      return const FoldingFeatureInfo(isFoldable: false);
    } on MissingPluginException {
      return const FoldingFeatureInfo(isFoldable: false);
    }
  }

  /// Stream of fold state changes.
  ///
  /// Subscribe to this stream to receive updates when the fold state changes.
  /// This is useful for adapting the UI when the user folds/unfolds the device.
  static Stream<FoldState> get onFoldStateChanged {
    if (!Platform.isAndroid) {
      return const Stream.empty();
    }

    _onFoldStateChanged ??= _eventChannel.receiveBroadcastStream().map((event) {
      if (event is Map) {
        return FoldState.fromMap(event);
      }
      return const FoldState(isFoldable: false);
    });

    return _onFoldStateChanged!;
  }
}
