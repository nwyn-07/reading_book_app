import 'dart:convert';

class JwtDecoder {
  JwtDecoder._();

  /// Decode payload JWT
  static Map<String, dynamic> decode(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('Invalid JWT');
    }

    final payload = _decodeBase64(parts[1]);
    final Map<String, dynamic> payloadMap = json.decode(payload);

    return payloadMap;
  }

  /// Check token expired
  static bool isExpired(String token) {
    try {
      final payload = decode(token);

      if (!payload.containsKey('exp')) return true;

      final exp = payload['exp'];
      final expiryDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);

      return DateTime.now().isAfter(expiryDate);
    } catch (_) {
      return true;
    }
  }

  static String _decodeBase64(String input) {
    var output = input.replaceAll('-', '+').replaceAll('_', '/');

    switch (output.length % 4) {
      case 0:
        break;
      case 2:
        output += '==';
        break;
      case 3:
        output += '=';
        break;
      default:
        throw Exception('Illegal base64url string');
    }

    return utf8.decode(base64Url.decode(output));
  }
}
