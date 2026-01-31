# AI Journal App - Folder Structure

## Complete Project Organization

```
AI_Journal/
├── android/                          # Android-specific configuration
├── ios/                              # iOS-specific configuration (future)
├── lib/                              # Main application code
│   ├── main.dart                     # App entry point
│   │
│   ├── config/                       # Configuration files
│   │   ├── supabase_config.dart      # Supabase initialization
│   │   ├── encryption_config.dart    # Encryption settings
│   │   └── theme_config.dart         # App themes (light/dark)
│   │
│   ├── core/                         # Core utilities and services
│   │   ├── constants/
│   │   │   ├── app_constants.dart    # App-wide constants
│   │   │   └── api_constants.dart    # API endpoints and keys
│   │   ├── utils/
│   │   │   ├── encryption_utils.dart # Encryption helpers
│   │   │   ├── date_utils.dart       # Date formatting utilities
│   │   │   └── validators.dart       # Input validation
│   │   └── services/
│   │       ├── encryption_service.dart   # AES-256 encryption/decryption
│   │       ├── storage_service.dart      # Secure local storage
│   │       └── analytics_service.dart    # App analytics
│   │
│   ├── features/                     # Feature modules
│   │   │
│   │   ├── auth/                     # STAGE 1: Authentication
│   │   │   ├── models/
│   │   │   │   └── user_model.dart
│   │   │   ├── providers/
│   │   │   │   └── auth_provider.dart
│   │   │   ├── screens/
│   │   │   │   ├── login_screen.dart
│   │   │   │   ├── signup_screen.dart
│   │   │   │   ├── forgot_password_screen.dart
│   │   │   │   └── onboarding_screen.dart
│   │   │   ├── widgets/
│   │   │   │   ├── auth_button.dart
│   │   │   │   ├── auth_text_field.dart
│   │   │   │   └── social_auth_button.dart
│   │   │   └── services/
│   │   │       └── auth_service.dart
│   │   │
│   │   ├── journal/                  # STAGE 2: Core Journaling
│   │   │   ├── models/
│   │   │   │   ├── journal_entry_model.dart
│   │   │   │   └── entry_metadata_model.dart
│   │   │   ├── providers/
│   │   │   │   └── journal_provider.dart
│   │   │   ├── screens/
│   │   │   │   ├── journal_home_screen.dart      # Timeline view
│   │   │   │   ├── create_entry_screen.dart      # Write/edit entries
│   │   │   │   ├── entry_detail_screen.dart      # View single entry
│   │   │   │   └── calendar_view_screen.dart     # Calendar with entries
│   │   │   ├── widgets/
│   │   │   │   ├── entry_card.dart               # Entry preview card
│   │   │   │   ├── rich_text_editor.dart         # Text editor
│   │   │   │   ├── voice_input_button.dart       # STT button
│   │   │   │   └── image_picker_widget.dart      # Image upload
│   │   │   └── services/
│   │   │       ├── journal_service.dart          # CRUD operations
│   │   │       └── stt_service.dart              # Speech-to-text
│   │   │
│   │   ├── ai_insights/              # STAGE 3: AI Features
│   │   │   ├── models/
│   │   │   │   ├── sentiment_model.dart
│   │   │   │   ├── insight_model.dart
│   │   │   │   └── recap_model.dart
│   │   │   ├── providers/
│   │   │   │   └── ai_provider.dart
│   │   │   ├── screens/
│   │   │   │   ├── insights_screen.dart              # LLM insights
│   │   │   │   ├── sentiment_analysis_screen.dart    # Mood trends
│   │   │   │   └── memory_recap_screen.dart          # Snapchat-style recap
│   │   │   ├── widgets/
│   │   │   │   ├── sentiment_chart.dart
│   │   │   │   ├── insight_card.dart
│   │   │   │   └── recap_carousel.dart
│   │   │   └── services/
│   │   │       ├── llm_service.dart              # LLM API integration
│   │   │       └── sentiment_service.dart        # Sentiment analysis
│   │   │
│   │   ├── social/                   # STAGE 4: Social Features
│   │   │   ├── models/
│   │   │   │   └── streak_model.dart
│   │   │   ├── providers/
│   │   │   │   └── streak_provider.dart
│   │   │   ├── screens/
│   │   │   │   ├── streak_screen.dart            # Streak display
│   │   │   │   └── share_preview_screen.dart     # Share preview
│   │   │   ├── widgets/
│   │   │   │   ├── streak_counter.dart
│   │   │   │   ├── streak_calendar.dart
│   │   │   │   └── share_card_generator.dart     # Generate share images
│   │   │   └── services/
│   │   │       └── streak_service.dart
│   │   │
│   │   ├── dashboard/                # STAGE 4: Analytics
│   │   │   ├── models/
│   │   │   │   └── analytics_model.dart
│   │   │   ├── providers/
│   │   │   │   └── dashboard_provider.dart
│   │   │   ├── screens/
│   │   │   │   └── dashboard_screen.dart
│   │   │   ├── widgets/
│   │   │   │   ├── stats_card.dart
│   │   │   │   ├── writing_frequency_chart.dart
│   │   │   │   └── mood_trend_chart.dart
│   │   │   └── services/
│   │   │       └── dashboard_service.dart
│   │   │
│   │   └── settings/                 # STAGE 4: Settings
│   │       ├── screens/
│   │       │   └── settings_screen.dart
│   │       └── widgets/
│   │           ├── theme_toggle.dart
│   │           └── export_data_button.dart
│   │
│   └── shared/                       # Shared components
│       ├── widgets/
│       │   ├── custom_button.dart
│       │   ├── custom_text_field.dart
│       │   ├── loading_indicator.dart
│       │   └── error_widget.dart
│       └── navigation/
│           └── app_router.dart
│
├── test/                             # Unit and widget tests
│   ├── features/
│   │   ├── auth/
│   │   ├── journal/
│   │   ├── ai_insights/
│   │   └── social/
│   └── core/
│       └── services/
│
├── integration_test/                 # Integration tests
│   └── app_test.dart
│
├── assets/                           # Static assets
│   ├── images/
│   ├── icons/
│   └── fonts/
│
├── pubspec.yaml                      # Dependencies
├── analysis_options.yaml             # Linting rules
└── README.md                         # Project documentation
```

## Folder Organization by Stage

### Stage 1: Authentication & Foundation
```
lib/
├── config/
├── core/
└── features/auth/
```

### Stage 2: Core Journaling
```
lib/features/journal/
```

### Stage 3: AI Features
```
lib/features/ai_insights/
```

### Stage 4: Social & Analytics
```
lib/features/
├── social/
├── dashboard/
└── settings/
```

## Key Principles

- **Feature-based organization**: Each major feature has its own folder
- **Separation of concerns**: Models, screens, widgets, and services are separated
- **Scalability**: Easy to add new features without restructuring
- **Testability**: Clear structure for unit and integration tests
- **Stage-aligned**: Folders map directly to development stages
