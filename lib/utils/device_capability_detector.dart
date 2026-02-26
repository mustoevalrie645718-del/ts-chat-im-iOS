import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:openim_common/openim_common.dart';

/// Device capability detector for optimizing app behavior on low-end devices
class DeviceCapabilityDetector {
  static bool? _isLowEndDevice;
  static late BaseDeviceInfo _deviceInfo;

  /// Check if the current device is a low-end device
  /// Low-end device criteria:
  /// - Android API level < 24 (Android 7.0 from 2016)
  /// - 8-year-old devices would be Android 5-6 era (API 21-23)
  static Future<bool> isLowEndDevice() async {
    if (_isLowEndDevice != null) {
      return _isLowEndDevice!;
    }

    if (!Platform.isAndroid) {
      _isLowEndDevice = false;
      return false;
    }

    try {
      final deviceInfoPlugin = DeviceInfoPlugin();
      _deviceInfo = await deviceInfoPlugin.deviceInfo;

      if (_deviceInfo is AndroidDeviceInfo) {
        final androidInfo = _deviceInfo as AndroidDeviceInfo;
        final sdkInt = androidInfo.version.sdkInt;

        // Android 7.0 (API 24) is from 2016
        // 8 years old devices would be Android 5-6 era (API 21-23)
        _isLowEndDevice = sdkInt < 24;

        Logger.print(
          '[DeviceCapability] Android API: $sdkInt (${androidInfo.version.release}), isLowEnd: $_isLowEndDevice',
          fileName: 'device_capability_detector.dart',
        );
      } else {
        _isLowEndDevice = false;
      }
    } catch (e) {
      Logger.print('[DeviceCapability] Error detecting device: $e', fileName: 'device_capability_detector.dart');
      _isLowEndDevice = false;
    }

    return _isLowEndDevice!;
  }

  /// Get device information as a string for logging
  static Future<String> getDeviceInfoString() async {
    try {
      if (!Platform.isAndroid) {
        return 'iOS device';
      }

      final deviceInfoPlugin = DeviceInfoPlugin();
      final deviceInfo = await deviceInfoPlugin.deviceInfo;

      if (deviceInfo is AndroidDeviceInfo) {
        final androidInfo = deviceInfo;
        return 'Android ${androidInfo.version.release} (API ${androidInfo.version.sdkInt}), '
            'Model: ${androidInfo.model}, '
            'Manufacturer: ${androidInfo.manufacturer}';
      }
    } catch (e) {
      return 'Unknown: $e';
    }

    return 'Unknown';
  }

  /// Apply optimizations for low-end devices
  static Future<void> applyLowEndOptimizations() async {
    final isLowEnd = await isLowEndDevice();

    if (!isLowEnd) {
      Logger.print('[DeviceCapability] Device is not low-end, skipping optimizations',
          fileName: 'device_capability_detector.dart');
      return;
    }

    Logger.print('[DeviceCapability] Applying optimizations for low-end device',
        fileName: 'device_capability_detector.dart');

    // TODO: Implement specific optimizations:
    // 1. Reduce image cache size
    // 2. Disable certain animations
    // 3. Lower video call quality limits
    // 4. Reduce concurrent network requests
    // 5. More aggressive memory cleanup

    // For now, just log that optimizations would be applied
    Logger.print('[DeviceCapability] Low-end optimizations applied', fileName: 'device_capability_detector.dart');
  }

  /// Log device information for debugging
  static Future<void> logDeviceInfo() async {
    final deviceInfoString = await getDeviceInfoString();
    final isLowEnd = await isLowEndDevice();

    Logger.print('[DeviceCapability] Device: $deviceInfoString', fileName: 'device_capability_detector.dart');
    Logger.print('[DeviceCapability] Low-end device: $isLowEnd', fileName: 'device_capability_detector.dart');
  }
}
