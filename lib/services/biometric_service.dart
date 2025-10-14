import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

class BiometricService {
  static final BiometricService _instance = BiometricService._internal();
  factory BiometricService() => _instance;
  BiometricService._internal();

  final LocalAuthentication _localAuth = LocalAuthentication();

  /// Check if biometric authentication is available
  Future<bool> isBiometricAvailable() async {
    try {
      final bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();

      return canCheckBiometrics && isDeviceSupported;
    } catch (e) {
      print('Biometric availability check failed: $e');
      return false;
    }
  }

  /// Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      print('Failed to get available biometrics: $e');
      return [];
    }
  }

  /// Authenticate using biometrics
  Future<bool> authenticate({
    String? reason = 'Authenticate to access your account',
    bool useErrorDialogs = true,
    bool stickyAuth = false,
    bool sensitiveTransaction = true,
  }) async {
    try {
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: reason ?? 'Authenticate to access your account',
        options: AuthenticationOptions(
          useErrorDialogs: useErrorDialogs,
          stickyAuth: stickyAuth,
          sensitiveTransaction: sensitiveTransaction,
          biometricOnly: true,
        ),
      );

      print('Biometric authentication result: $didAuthenticate');
      return didAuthenticate;
    } catch (e) {
      print('Biometric authentication failed: $e');

      // Handle specific error cases
      if (e.toString().contains(auth_error.notAvailable)) {
        throw BiometricException('Biometric authentication is not available on this device');
      } else if (e.toString().contains(auth_error.notEnrolled)) {
        throw BiometricException('No biometrics enrolled on this device');
      } else if (e.toString().contains(auth_error.lockedOut)) {
        throw BiometricException('Too many failed attempts. Biometric authentication is locked');
      } else if (e.toString().contains(auth_error.permanentlyLockedOut)) {
        throw BiometricException('Biometric authentication is permanently locked. Please use PIN/pattern/password');
      } else if (e.toString().contains('platformAuthRequired')) {
        throw BiometricException('Platform authentication required');
      } else {
        throw BiometricException('Authentication failed: ${e.toString()}');
      }
    }
  }

  /// Check if user has enrolled biometrics
  Future<bool> hasEnrolledBiometrics() async {
    try {
      final List<BiometricType> availableBiometrics = await getAvailableBiometrics();
      return availableBiometrics.isNotEmpty;
    } catch (e) {
      print('Failed to check enrolled biometrics: $e');
      return false;
    }
  }

  /// Get biometric type name for display
  String getBiometricTypeName(BiometricType type) {
    switch (type) {
      case BiometricType.face:
        return 'Face ID';
      case BiometricType.fingerprint:
        return 'Fingerprint';
      case BiometricType.iris:
        return 'Iris';
      case BiometricType.weak:
        return 'Biometric';
      case BiometricType.strong:
        return 'Strong Biometric';
      default:
        return 'Biometric';
    }
  }
}

class BiometricException implements Exception {
  final String message;
  BiometricException(this.message);

  @override
  String toString() => 'BiometricException: $message';
}
