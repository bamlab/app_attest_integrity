import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Utility functions for cryptographic operations.
class CryptoUtils {
  CryptoUtils._();

  /// Computes SHA256 hash of the input string and returns raw bytes.
  static List<int> sha256Hash(String input) {
    return sha256.convert(utf8.encode(input)).bytes;
  }

  /// Computes SHA256 hash of the input string and returns base64 encoded string.
  static String sha256HashBase64(String input) {
    return base64.encode(sha256Hash(input));
  }

  /// Encodes bytes to base64 string.
  static String toBase64(List<int> bytes) {
    return base64.encode(bytes);
  }
}
