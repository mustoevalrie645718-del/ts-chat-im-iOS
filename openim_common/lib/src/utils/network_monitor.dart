import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkMonitor {
  // Singleton instance
  static final NetworkMonitor _instance = NetworkMonitor._internal();
  factory NetworkMonitor() => _instance;

  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _subscription; // Subscription to network changes
  List<ConnectivityResult> _currentStatus = <ConnectivityResult>[]; // Current network status
  Function(List<ConnectivityResult>)? _onStatusChanged; // Callback for status changes

  // Cached network availability status
  bool _isAvailable = false;
  DateTime? _lastCheck;
  static const _cacheValidityDuration = Duration(seconds: 30);

  // Private constructor for singleton pattern
  NetworkMonitor._internal() {
    _init();
  }

  /// Initialize network monitoring
  void _init() {
    // Listen to network changes
    _subscription = _connectivity.onConnectivityChanged.listen((result) {
      _currentStatus = result;
      _onStatusChanged?.call(result);
      // Refresh availability check when connectivity changes
      _refreshNetworkAvailability();
    });
    _checkInitialStatus();
  }

  /// Check initial network status
  Future<void> _checkInitialStatus() async {
    _currentStatus = await _connectivity.checkConnectivity();
    _onStatusChanged?.call(_currentStatus);
    // Initial availability check
    await _refreshNetworkAvailability();
  }

  /// Refresh network availability status
  Future<void> _refreshNetworkAvailability() async {
    if (_currentStatus.contains(ConnectivityResult.none)) {
      _isAvailable = false;
      _lastCheck = DateTime.now();
      return;
    }

    try {
      final result = await InternetAddress.lookup('www.openim.io');
      _isAvailable = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      _isAvailable = false;
    }
    _lastCheck = DateTime.now();
  }

  /// Get current network status
  List<ConnectivityResult> get currentStatus => _currentStatus;

  /// Register callback for network status changes
  void onNetworkChanged(Function(List<ConnectivityResult>) callback) {
    _onStatusChanged = callback;
  }

  /// Check if the network is actually available (uses cached result)
  Future<bool> isNetworkAvailable() async {
    // If no connectivity, return false immediately
    if (_currentStatus.contains(ConnectivityResult.none)) return false;

    // If never checked or cache expired, refresh
    if (_lastCheck == null || DateTime.now().difference(_lastCheck!) > _cacheValidityDuration) {
      await _refreshNetworkAvailability();
    }

    return _isAvailable;
  }

  /// Check if initial network status check has completed
  bool get hasInitialCheckCompleted => _lastCheck != null;

  /// Get cached network availability without async check
  /// Returns true if initial check hasn't completed yet to avoid false negatives
  bool get isAvailableSync => _lastCheck == null ? true : _isAvailable;

  /// Dispose resources
  void dispose() {
    _subscription.cancel();
  }
}
