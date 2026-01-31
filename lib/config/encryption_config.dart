class EncryptionConfig {
  // AES-256-GCM encryption configuration
  static const int keyLength = 32; // 256 bits
  static const int ivLength = 16; // 128 bits
  static const int saltLength = 32;
  static const int iterationCount = 10000; // PBKDF2 iterations
  
  // Secure storage keys
  static const String encryptionKeyStorageKey = 'user_encryption_key';
  static const String saltStorageKey = 'user_salt';
  
  // Key derivation algorithm
  static const String kdfAlgorithm = 'PBKDF2';
}
