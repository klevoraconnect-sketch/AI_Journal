class ApiConstants {
  // Supabase Tables
  static const String journalEntriesTable = 'journal_entries';
  static const String entryImagesTable = 'entry_images';
  static const String userProfilesTable = 'user_profiles';
  
  // Supabase Storage Buckets
  static const String imagesBucket = 'entry-images';
  
  // API Timeouts
  static const Duration defaultTimeout = Duration(seconds: 30);
  static const Duration uploadTimeout = Duration(minutes: 2);
  
  // Rate Limiting
  static const int maxRequestsPerMinute = 60;
  
  // LLM Configuration
  static const String defaultLlmModel = 'gemini-pro';
  static const int maxLlmTokens = 2048;
  static const double llmTemperature = 0.7;
}
