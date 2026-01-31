class AppConstants {
  // App Info
  static const String appName = 'AI Journal';
  static const String appVersion = '1.0.0';
  
  // Encryption
  static const int maxEncryptionRetries = 3;
  
  // Journal
  static const int maxTitleLength = 100;
  static const int maxContentLength = 50000;
  static const int autoSaveIntervalSeconds = 30;
  
  // Images
  static const int maxImagesPerEntry = 10;
  static const int imageCompressionQuality = 85;
  static const int maxImageSizeBytes = 5 * 1024 * 1024; // 5MB
  
  // Streaks
  static const int streakGracePeriodHours = 24;
  
  // AI Features
  static const int maxInsightsPerRequest = 5;
  static const int sentimentAnalysisMinWords = 10;
  
  // Pagination
  static const int entriesPerPage = 20;
  static const int insightsPerPage = 10;
}
