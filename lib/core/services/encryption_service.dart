import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt_pkg;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import '../../config/encryption_config.dart';

class EncryptionService {
  static final EncryptionService _instance = EncryptionService._internal();
  factory EncryptionService() => _instance;
  EncryptionService._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  encrypt_pkg.Key? _encryptionKey;

  /// Initialize encryption key for the user
  /// If key doesn't exist, generate a new one
  Future<void> initializeKey({String? userPassword}) async {
    try {
      // Try to retrieve existing key
      final storedKey = await _secureStorage.read(
        key: EncryptionConfig.encryptionKeyStorageKey,
      );

      if (storedKey != null) {
        _encryptionKey = encrypt_pkg.Key.fromBase64(storedKey);
      } else if (userPassword != null) {
        // Generate new key from password
        await _generateAndStoreKey(userPassword);
      } else {
        // Generate random key if no password provided
        await _generateRandomKey();
      }
    } catch (e) {
      throw Exception('Failed to initialize encryption key: $e');
    }
  }

  /// Generate encryption key from user password using PBKDF2
  Future<void> _generateAndStoreKey(String password) async {
    try {
      // Generate random salt
      final random = Random.secure();
      final salt = List<int>.generate(
        EncryptionConfig.saltLength,
        (i) => random.nextInt(256),
      );

      // Derive key using PBKDF2
      final derivedKey = _deriveKey(password, salt);

      // Store key and salt
      _encryptionKey = encrypt_pkg.Key(Uint8List.fromList(derivedKey));
      await _secureStorage.write(
        key: EncryptionConfig.encryptionKeyStorageKey,
        value: _encryptionKey!.base64,
      );
      await _secureStorage.write(
        key: EncryptionConfig.saltStorageKey,
        value: base64Encode(salt),
      );
    } catch (e) {
      throw Exception('Failed to generate key from password: $e');
    }
  }

  /// Generate random encryption key
  Future<void> _generateRandomKey() async {
    try {
      final random = Random.secure();
      final keyBytes = List<int>.generate(
        EncryptionConfig.keyLength,
        (i) => random.nextInt(256),
      );

      _encryptionKey = encrypt_pkg.Key(Uint8List.fromList(keyBytes));
      await _secureStorage.write(
        key: EncryptionConfig.encryptionKeyStorageKey,
        value: _encryptionKey!.base64,
      );
    } catch (e) {
      throw Exception('Failed to generate random key: $e');
    }
  }

  /// Derive key from password using PBKDF2
  List<int> _deriveKey(String password, List<int> salt) {
    final passwordBytes = utf8.encode(password);
    List<int> derivedKey = passwordBytes;

    // Simple PBKDF2 implementation
    for (var i = 0; i < EncryptionConfig.iterationCount; i++) {
      final hmac = Hmac(sha256, derivedKey);
      final digest = hmac.convert(salt);
      derivedKey = List<int>.from(digest.bytes);
    }

    return derivedKey.sublist(0, EncryptionConfig.keyLength);
  }

  /// Encrypt text data
  String encryptText(String plainText) {
    if (_encryptionKey == null) {
      throw Exception('Encryption key not initialized');
    }

    try {
      final iv = encrypt_pkg.IV.fromSecureRandom(EncryptionConfig.ivLength);
      final encrypter = encrypt_pkg.Encrypter(
        encrypt_pkg.AES(_encryptionKey!, mode: encrypt_pkg.AESMode.gcm),
      );

      final encrypted = encrypter.encrypt(plainText, iv: iv);

      // Combine IV and encrypted data
      final combined = '${iv.base64}:${encrypted.base64}';
      return combined;
    } catch (e) {
      throw Exception('Failed to encrypt text: $e');
    }
  }

  /// Decrypt text data
  String decryptText(String encryptedText) {
    if (_encryptionKey == null) {
      throw Exception('Encryption key not initialized');
    }

    try {
      // Split IV and encrypted data
      final parts = encryptedText.split(':');
      if (parts.length != 2) {
        throw Exception('Invalid encrypted text format');
      }

      final iv = encrypt_pkg.IV.fromBase64(parts[0]);
      final encrypted = encrypt_pkg.Encrypted.fromBase64(parts[1]);

      final encrypter = encrypt_pkg.Encrypter(
        encrypt_pkg.AES(_encryptionKey!, mode: encrypt_pkg.AESMode.gcm),
      );

      return encrypter.decrypt(encrypted, iv: iv);
    } catch (e) {
      throw Exception('Failed to decrypt text: $e');
    }
  }

  /// Encrypt binary data (for images)
  Uint8List encryptBytes(Uint8List plainBytes) {
    if (_encryptionKey == null) {
      throw Exception('Encryption key not initialized');
    }

    try {
      final iv = encrypt_pkg.IV.fromSecureRandom(EncryptionConfig.ivLength);
      final encrypter = encrypt_pkg.Encrypter(
        encrypt_pkg.AES(_encryptionKey!, mode: encrypt_pkg.AESMode.gcm),
      );

      final encrypted = encrypter.encryptBytes(plainBytes, iv: iv);

      // Combine IV and encrypted data
      final combined = Uint8List.fromList([...iv.bytes, ...encrypted.bytes]);
      return combined;
    } catch (e) {
      throw Exception('Failed to encrypt bytes: $e');
    }
  }

  /// Decrypt binary data (for images)
  Uint8List decryptBytes(Uint8List encryptedBytes) {
    if (_encryptionKey == null) {
      throw Exception('Encryption key not initialized');
    }

    try {
      // Extract IV and encrypted data
      final iv = encrypt_pkg.IV(
        Uint8List.fromList(
          encryptedBytes.sublist(0, EncryptionConfig.ivLength),
        ),
      );
      final encrypted = encrypt_pkg.Encrypted(
        Uint8List.fromList(
          encryptedBytes.sublist(EncryptionConfig.ivLength),
        ),
      );

      final encrypter = encrypt_pkg.Encrypter(
        encrypt_pkg.AES(_encryptionKey!, mode: encrypt_pkg.AESMode.gcm),
      );

      return Uint8List.fromList(encrypter.decryptBytes(encrypted, iv: iv));
    } catch (e) {
      throw Exception('Failed to decrypt bytes: $e');
    }
  }

  /// Clear encryption key (on logout)
  Future<void> clearKey() async {
    _encryptionKey = null;
    await _secureStorage.delete(key: EncryptionConfig.encryptionKeyStorageKey);
    await _secureStorage.delete(key: EncryptionConfig.saltStorageKey);
  }

  /// Check if encryption key is initialized
  bool get isKeyInitialized => _encryptionKey != null;
}
