import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';

class PinAuthService {
  PinAuthService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const _pinKey = 'ziso_pin_hash';

  final FlutterSecureStorage _storage;

  Future<bool> hasPin() async {
    final value = await _storage.read(key: _pinKey);
    return value != null;
  }

  Future<void> setPin(String pin) async {
    final hash = _hashPin(pin);
    await _storage.write(key: _pinKey, value: hash);
  }

  Future<bool> verifyPin(String pin) async {
    final expected = await _storage.read(key: _pinKey);
    if (expected == null) {
      return false;
    }
    return _hashPin(pin) == expected;
  }

  Future<void> clearPin() async {
    await _storage.delete(key: _pinKey);
  }

  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
