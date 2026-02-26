import 'package:flutter_libphonenumber/flutter_libphonenumber.dart' as libphone;

/// A utility class for phone number validation using flutter_libphonenumber.
/// This class provides both initialization and validation functionality.
class PhoneNumberValidator {
  static final PhoneNumberValidator _instance = PhoneNumberValidator._internal();
  factory PhoneNumberValidator() => _instance;
  PhoneNumberValidator._internal();

  bool _isInitialized = false;
  final Map<String, bool> _validationCache = {};

  /// Initialize the phone number library. Should be called during app startup.
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      await libphone.init();
      _isInitialized = true;
    } catch (e) {
      // Initialization failed, but we can still use basic validation
      _isInitialized = false;
    }
  }

  /// Check if the library is initialized
  bool get isInitialized => _isInitialized;

  /// Clear the validation cache
  void clearCache() {
    _validationCache.clear();
  }

  /// Synchronously check if a phone number is valid.
  /// Uses cached results if available, otherwise triggers async validation.
  bool isValidSync(String phoneText) {
    // Remove common formatting characters for validation
    final cleanedNumber = phoneText.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // Basic length check - valid phone numbers are typically 7-15 digits
    final digitsOnly = cleanedNumber.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.length < 7 || digitsOnly.length > 15) {
      return false;
    }

    // Check if it's cached as valid
    if (_validationCache.containsKey(cleanedNumber)) {
      return _validationCache[cleanedNumber]!;
    }

    // Trigger async validation and cache the result
    _validateAsync(cleanedNumber);

    // Default to true for first render, will update on next build if invalid
    return true;
  }

  /// Async validation that updates the cache
  Future<bool> _validateAsync(String phone) async {
    if (_validationCache.containsKey(phone)) {
      return _validationCache[phone]!;
    }

    if (!_isInitialized) {
      // If not initialized, assume valid
      return true;
    }

    try {
      // Try to parse as Chinese number first (most common case)
      final result = await libphone.parse(phone, region: 'CN');
      final isValid = result['type'] != null;
      _validationCache[phone] = isValid;
      return isValid;
    } catch (e) {
      // If parsing fails, try without region
      try {
        final result = await libphone.parse(phone);
        final isValid = result['type'] != null;
        _validationCache[phone] = isValid;
        return isValid;
      } catch (e) {
        _validationCache[phone] = false;
        return false;
      }
    }
  }

  /// Async validate a phone number
  Future<bool> isValid(String phoneText) async {
    final cleanedNumber = phoneText.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // Basic length check
    final digitsOnly = cleanedNumber.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.length < 7 || digitsOnly.length > 15) {
      return false;
    }

    return _validateAsync(cleanedNumber);
  }
}
