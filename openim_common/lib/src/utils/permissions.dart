import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sprintf/sprintf.dart';

/// Permission management utility class
/// Centralized management of various permission requests and checks required by the application
class Permissions {
  Permissions._();

  // Cache device information to avoid repeated retrieval
  static AndroidDeviceInfo? _androidInfo;

  /// Get Android device information (with caching)
  static Future<AndroidDeviceInfo> get androidInfo async {
    return _androidInfo ??= await DeviceInfoPlugin().androidInfo;
  }

  /// Check system alert window permission
  static Future<bool> checkSystemAlertWindow() async {
    return Permission.systemAlertWindow.isGranted;
  }

  /// Check storage permission
  static Future<bool> checkStorage() async {
    return Permission.storage.isGranted;
  }

  /// Generic permission request method
  ///
  /// [permission] The permission to request
  /// [onGranted] Callback after permission is granted
  /// [allowLimited] Whether to allow limited permissions (mainly for photo permissions)
  static Future<void> _requestPermission(
    Permission permission, {
    VoidCallback? onGranted,
    bool allowLimited = false,
  }) async {
    final status = await permission.status;

    if (status.isGranted || (allowLimited && status.isLimited)) {
      onGranted?.call();
      return;
    }

    final request = await permission.request();

    if (request.isGranted || (allowLimited && request.isLimited)) {
      onGranted?.call();
      return;
    }

    if (request.isPermanentlyDenied || request.isDenied) {
      _showPermissionDeniedDialog(permission.title);
    }
  }

  /// Request camera permission
  static Future<void> camera(VoidCallback? onGranted) async {
    await _requestPermission(Permission.camera, onGranted: onGranted);
  }

  /// Request storage permission (automatically selects appropriate permission based on Android version)
  static Future<void> storage(VoidCallback? onGranted) async {
    if (!Platform.isAndroid) {
      onGranted?.call();
      return;
    }

    final info = await androidInfo;
    final permission = info.version.sdkInt <= 32 ? Permission.storage : Permission.manageExternalStorage;

    await _requestPermission(permission, onGranted: onGranted);
  }

  /// Request manage external storage permission
  static Future<void> manageExternalStorage(VoidCallback? onGranted) async {
    await _requestPermission(Permission.manageExternalStorage, onGranted: onGranted);
  }

  /// Request microphone permission
  static Future<void> microphone(VoidCallback? onGranted) async {
    await _requestPermission(Permission.microphone, onGranted: onGranted);
  }

  /// Request location permission
  static Future<void> location(VoidCallback? onGranted) async {
    await _requestPermission(Permission.location, onGranted: onGranted);
  }

  /// Request speech recognition permission
  static Future<void> speech(VoidCallback? onGranted) async {
    await _requestPermission(Permission.speech, onGranted: onGranted);
  }

  /// Request photos/gallery permission (automatically selects appropriate permission based on platform and Android version)
  static Future<void> photos(VoidCallback? onGranted) async {
    if (Platform.isAndroid) {
      final info = await androidInfo;
      if (info.version.sdkInt <= 32) {
        // Android 12 and below use storage permission
        await storage(onGranted);
      } else {
        // Android 13 and above use photos permission
        await _requestPermission(
          Permission.photos,
          onGranted: onGranted,
          allowLimited: true,
        );
      }
    } else {
      // iOS uses photos permission
      await _requestPermission(
        Permission.storage,
        onGranted: onGranted,
        allowLimited: true,
      );
    }
  }

  /// Request notification permission
  ///
  /// Returns whether permission is granted
  static Future<bool> notification() async {
    final status = await Permission.notification.request();

    if (status.isGranted) {
      return true;
    }

    if (status.isPermanentlyDenied || status.isDenied) {
      _showPermissionDeniedDialog(Permission.notification.title);
    }

    return false;
  }

  /// Request ignore battery optimizations permission
  static Future<void> ignoreBatteryOptimizations(VoidCallback? onGranted) async {
    final status = await Permission.ignoreBatteryOptimizations.request();

    if (status.isGranted) {
      onGranted?.call();
    }
    // Note: Battery optimization permission usually doesn't show denial dialog as it's a system-level setting
  }

  /// Generic multiple permissions request method
  ///
  /// [permissions] List of permissions to request
  /// [onGranted] Callback after all permissions are granted
  /// [allowLimited] Whether to allow limited permissions
  static Future<bool> _requestMultiplePermissions(
    List<Permission> permissions, {
    VoidCallback? onGranted,
    bool allowLimited = false,
  }) async {
    final results = await permissions.request();
    final deniedPermissions = <String>[];

    bool allGranted = true;

    for (final entry in results.entries) {
      final permission = entry.key;
      final status = entry.value;

      final isGranted = status.isGranted || (allowLimited && status.isLimited);

      if (!isGranted) {
        allGranted = false;
        deniedPermissions.add(permission.title);
      }
    }
    if (allGranted) {
      onGranted?.call();
    } else if (deniedPermissions.isNotEmpty) {
      final message = deniedPermissions.join(', ');
      _showPermissionDeniedDialog(message);
    }

    return allGranted;
  }

  /// Request camera and microphone permissions 卡卡西
  static Future<void> cameraAndMicrophone(VoidCallback? onGranted) async {
    await _requestMultiplePermissions(
      [Permission.camera, Permission.microphone],
      onGranted: onGranted
    );
  }
  static Future<void> cameraAndMicrophone1(VoidCallback? onGranted) async {
    final r = await [Permission.storage, Permission.videos].request();

    final cam = r[Permission.storage];
    final mic = r[Permission.videos];
    debugPrint('卡卡西after cam=$cam denied=${cam?.isDenied} perm=${cam?.isPermanentlyDenied}');
    debugPrint('卡卡西after mic=$mic denied=${mic?.isDenied} perm=${mic?.isPermanentlyDenied}');
    final ok = (cam?.isGranted ?? false) && (mic?.isGranted ?? false);
    if (ok) {
      onGranted?.call();
      return;
    }

    final needSettings =
        (cam?.isPermanentlyDenied ?? false) || (mic?.isPermanentlyDenied ?? false);

    if (needSettings) {
      openAppSettings();
    } else {
      // denied：解释用途即可
    }
  }

  /// Request media-related permissions (camera, microphone, storage/photos)
  static Future<bool> media() async {
    final permissions = [Permission.camera, Permission.microphone];

    // Add storage permission based on platform and Android version
    if (Platform.isAndroid) {
      final info = await androidInfo;
      permissions.add(info.version.sdkInt <= 32 ? Permission.storage : Permission.photos);
    } else {
      permissions.add(Permission.photos);
    }

    return await _requestMultiplePermissions(
      permissions,
      allowLimited: true,
    );
  }

  /// Request storage and microphone permissions
  static Future<void> storageAndMicrophone(VoidCallback? onGranted) async {
    final permissions = [Permission.microphone];

    if (Platform.isAndroid) {
      final info = await androidInfo;
      permissions.add(info.version.sdkInt <= 32 ? Permission.storage : Permission.manageExternalStorage);
    }

    await _requestMultiplePermissions(permissions, onGranted: onGranted);
  }

  /// Batch request permissions
  ///
  /// Returns permission status mapping
  static Future<Map<Permission, PermissionStatus>> request(
    List<Permission> permissions,
  ) async {
    return await permissions.request();
  }

  /// Show permission denied dialog
  static void _showPermissionDeniedDialog(String permissionNames) {
    final context = Get.context;
    if (context == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(StrRes.permissionDeniedTitle),
          content: Text(
            sprintf(StrRes.permissionDeniedHint, [permissionNames]),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(StrRes.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                openAppSettings();
              },
              child: Text(
                StrRes.determine,
                style: TextStyle(
                  color: Theme.of(dialogContext).primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Permission extension methods
extension PermissionExt on Permission {
  /// Get localized name of the permission
  String get title {
    switch (this) {
      case Permission.storage:
        return StrRes.externalStorage;
      case Permission.manageExternalStorage:
        return StrRes.externalStorage;
      case Permission.photos:
        return StrRes.gallery;
      case Permission.camera:
        return StrRes.camera;
      case Permission.microphone:
        return StrRes.microphone;
      case Permission.notification:
        return StrRes.notification;
      case Permission.location:
        return 'Location';
      case Permission.speech:
        return 'Speech Recognition';
      case Permission.ignoreBatteryOptimizations:
        return 'Battery Optimization';
      case Permission.systemAlertWindow:
        return 'System Alert Window';
      default:
        return toString().split('.').last;
    }
  }

  /// Check if permission is granted (including limited permission)
  Future<bool> get isGrantedOrLimited async {
    final status = await this.status;
    return status.isGranted || status.isLimited;
  }
}

/// Permission status extension methods
extension PermissionStatusExt on PermissionStatus {
  /// Whether it's in an available state (granted or limited permission)
  bool get isAvailable => isGranted || isLimited;

  /// Whether permission rationale should be shown
  bool get shouldShowRationale => isDenied && !isPermanentlyDenied;
}
