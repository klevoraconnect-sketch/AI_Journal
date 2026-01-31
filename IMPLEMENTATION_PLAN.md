# AI Journal App - Implementation Plan

## Overview

Building a privacy-focused AI Journal Android app using Flutter with end-to-end encryption, AI-powered insights, and social sharing features. The app ensures user privacy by encrypting all journal entries before sending to LLM services.

## Technology Stack

### Core Technologies
- **Framework**: Flutter (Dart)
- **Database**: Supabase (PostgreSQL)
- **Storage**: Supabase Storage (encrypted)
- **Authentication**: Supabase Auth
- **Platform**: Android (primary), with cross-platform support

### Key Dependencies
- `supabase_flutter` - Supabase client
- `flutter_secure_storage` - Secure local storage for encryption keys
- `encrypt` - AES encryption for journal entries
- `flutter_ai_toolkit` - AI chat widgets with built-in voice input
- `firebase_ai` - Firebase AI Logic SDK for LLM integration
- `firebase_core` - Firebase initialization
- `image_picker` - Image upload from gallery/camera
- `fl_chart` - Data visualization for analytics
- `share_plus` - Social media sharing
- `intl` - Date/time formatting
- `cached_network_image` - Image caching
- `provider` or `riverpod` - State management

---

## Project Folder Structure

```
lib/
├── main.dart
├── config/
│   ├── supabase_config.dart
│   ├── encryption_config.dart
│   └── theme_config.dart
├── core/
│   ├── constants/
│   │   ├── app_constants.dart
│   │   └── api_constants.dart
│   ├── utils/
│   │   ├── encryption_utils.dart
│   │   ├── date_utils.dart
│   │   └── validators.dart
│   └── services/
│       ├── encryption_service.dart
│       ├── storage_service.dart
│       └── analytics_service.dart
├── features/
│   ├── auth/
│   │   ├── models/
│   │   │   └── user_model.dart
│   │   ├── providers/
│   │   │   └── auth_provider.dart
│   │   ├── screens/
│   │   │   ├── login_screen.dart
│   │   │   ├── signup_screen.dart
│   │   │   ├── forgot_password_screen.dart
│   │   │   └── onboarding_screen.dart
│   │   ├── widgets/
│   │   │   ├── auth_button.dart
│   │   │   ├── auth_text_field.dart
│   │   │   └── social_auth_button.dart
│   │   └── services/
│   │       └── auth_service.dart
│   ├── journal/
│   │   ├── models/
│   │   │   ├── journal_entry_model.dart
│   │   │   └── entry_metadata_model.dart
│   │   ├── providers/
│   │   │   └── journal_provider.dart
│   │   ├── screens/
│   │   │   ├── journal_home_screen.dart
│   │   │   ├── create_entry_screen.dart
│   │   │   ├── entry_detail_screen.dart
│   │   │   └── calendar_view_screen.dart
│   │   ├── widgets/
│   │   │   ├── entry_card.dart
│   │   │   ├── rich_text_editor.dart
│   │   │   ├── voice_input_button.dart
│   │   │   └── image_picker_widget.dart
│   │   └── services/
│   │       ├── journal_service.dart
│   │       └── stt_service.dart
│   ├── ai_insights/
│   │   ├── models/
│   │   │   ├── sentiment_model.dart
│   │   │   ├── insight_model.dart
│   │   │   └── recap_model.dart
│   │   ├── providers/
│   │   │   └── ai_provider.dart
│   │   ├── screens/
│   │   │   ├── insights_screen.dart
│   │   │   ├── sentiment_analysis_screen.dart
│   │   │   └── memory_recap_screen.dart
│   │   ├── widgets/
│   │   │   ├── sentiment_chart.dart
│   │   │   ├── insight_card.dart
│   │   │   └── recap_carousel.dart
│   │   └── services/
│   │       ├── llm_service.dart
│   │       └── sentiment_service.dart
│   ├── social/
│   │   ├── models/
│   │   │   └── streak_model.dart
│   │   ├── providers/
│   │   │   └── streak_provider.dart
│   │   ├── screens/
│   │   │   ├── streak_screen.dart
│   │   │   └── share_preview_screen.dart
│   │   ├── widgets/
│   │   │   ├── streak_counter.dart
│   │   │   ├── streak_calendar.dart
│   │   │   └── share_card_generator.dart
│   │   └── services/
│   │       └── streak_service.dart
│   └── dashboard/
│       ├── models/
│       │   └── analytics_model.dart
│       ├── providers/
│       │   └── dashboard_provider.dart
│       ├── screens/
│       │   └── dashboard_screen.dart
│       ├── widgets/
│       │   ├── stats_card.dart
│       │   ├── writing_frequency_chart.dart
│       │   └── mood_trend_chart.dart
│       └── services/
│           └── dashboard_service.dart
└── shared/
    ├── widgets/
    │   ├── custom_button.dart
    │   ├── custom_text_field.dart
    │   ├── loading_indicator.dart
    │   └── error_widget.dart
    └── navigation/
        └── app_router.dart
```

---

## Stage 1: Authentication & Foundation

### Features to Implement

#### 1.1 Supabase Setup
- Create Supabase project
- Configure authentication providers (Email, Google OAuth)
- Set up database tables
- Configure storage buckets for encrypted images

#### 1.2 Authentication Screens

**[NEW] [login_screen.dart](file:///c:/Users/SWANAND/Desktop/AIBoomi/AI_Journal/lib/features/auth/screens/login_screen.dart)**
- Email/password login form
- Google OAuth button
- "Forgot Password" link
- Navigation to signup screen
- Form validation
- Loading states and error handling

**[NEW] [signup_screen.dart](file:///c:/Users/SWANAND/Desktop/AIBoomi/AI_Journal/lib/features/auth/screens/signup_screen.dart)**
- User registration form (email, password, confirm password)
- Terms and conditions checkbox
- Google OAuth option
- Form validation (password strength, email format)
- Navigation to login screen

**[NEW] [forgot_password_screen.dart](file:///c:/Users/SWANAND/Desktop/AIBoomi/AI_Journal/lib/features/auth/screens/forgot_password_screen.dart)**
- Email input for password reset
- Send reset email functionality
- Success/error feedback

**[NEW] [onboarding_screen.dart](file:///c:/Users/SWANAND/Desktop/AIBoomi/AI_Journal/lib/features/auth/screens/onboarding_screen.dart)**
- Welcome screens explaining app features
- Privacy and encryption information
- Skip/Next navigation

#### 1.3 Authentication Service

**[NEW] [auth_service.dart](file:///c:/Users/SWANAND/Desktop/AIBoomi/AI_Journal/lib/features/auth/services/auth_service.dart)**
- Sign up with email/password
- Sign in with email/password
- Sign in with Google OAuth
- Sign out
- Password reset
- Session management
- Token refresh handling

#### 1.4 Encryption Foundation

**[NEW] [encryption_service.dart](file:///c:/Users/SWANAND/Desktop/AIBoomi/AI_Journal/lib/core/services/encryption_service.dart)**
- Generate user-specific encryption key on first login
- Store encryption key securely using `flutter_secure_storage`
- AES-256 encryption/decryption methods
- Key derivation from user password (PBKDF2)

#### 1.5 Configuration Files

**[NEW] [supabase_config.dart](file:///c:/Users/SWANAND/Desktop/AIBoomi/AI_Journal/lib/config/supabase_config.dart)**
- Supabase URL and anon key
- Initialize Supabase client

**[NEW] [theme_config.dart](file:///c:/Users/SWANAND/Desktop/AIBoomi/AI_Journal/lib/config/theme_config.dart)**
- Light and dark theme definitions
- Color schemes
- Typography styles

---

## Stage 2: Core Journaling Features

### Features to Implement

#### 2.1 Database Schema (Supabase)

**journal_entries table:**
```sql
- id (uuid, primary key)
- user_id (uuid, foreign key to auth.users)
- encrypted_content (text)
- encrypted_title (text)
- sentiment_score (float, nullable)
- mood (text, nullable)
- created_at (timestamp)
- updated_at (timestamp)
- has_images (boolean)
- word_count (integer)
```

**entry_images table:**
```sql
- id (uuid, primary key)
- entry_id (uuid, foreign key to journal_entries)
- encrypted_image_url (text)
- created_at (timestamp)
```

#### 2.2 Journal Entry Screens

**[NEW] [journal_home_screen.dart](file:///c:/Users/SWANAND/Desktop/AIBoomi/AI_Journal/lib/features/journal/screens/journal_home_screen.dart)**
- Timeline view of journal entries
- Pull-to-refresh
- Search bar
- Floating action button to create new entry
- Filter by date/mood

**[NEW] [create_entry_screen.dart](file:///c:/Users/SWANAND/Desktop/AIBoomi/AI_Journal/lib/features/journal/screens/create_entry_screen.dart)**
- Rich text editor for journal content
- Title input field
- Voice-to-text button
- Image upload button (camera/gallery)
- Save/Cancel actions
- Auto-save draft functionality
- Character/word count display

**[NEW] [entry_detail_screen.dart](file:///c:/Users/SWANAND/Desktop/AIBoomi/AI_Journal/lib/features/journal/screens/entry_detail_screen.dart)**
- Display decrypted journal entry
- Show attached images
- Edit/Delete options
- Share options (encrypted export)
- Timestamp display

#### 2.3 Journal Services

**[NEW] [journal_service.dart](file:///c:/Users/SWANAND/Desktop/AIBoomi/AI_Journal/lib/features/journal/services/journal_service.dart)**
- Create entry (encrypt before saving)
- Fetch entries (decrypt after fetching)
- Update entry
- Delete entry
- Search entries (client-side on decrypted text)
- Upload encrypted images to Supabase Storage

**[NEW] [voice_input_service.dart](file:///c:/Users/SWANAND/Desktop/AIBoomi/AI_Journal/lib/features/journal/services/voice_input_service.dart)**
- Integrate Flutter AI Toolkit's voice input feature
- Handle microphone permissions
- Convert speech to text using built-in STT
- Process voice input for journal entries
- Error handling and fallback

#### 2.4 Widgets

**[NEW] [rich_text_editor.dart](file:///c:/Users/SWANAND/Desktop/AIBoomi/AI_Journal/lib/features/journal/widgets/rich_text_editor.dart)**
- Multi-line text input
- Formatting options (bold, italic, lists)
- Auto-save functionality

**[NEW] [voice_input_button.dart](file:///c:/Users/SWANAND/Desktop/AIBoomi/AI_Journal/lib/features/journal/widgets/voice_input_button.dart)**
- Microphone button with animation
- Recording indicator
- Transcription display

**[NEW] [image_picker_widget.dart](file:///c:/Users/SWANAND/Desktop/AIBoomi/AI_Journal/lib/features/journal/widgets/image_picker_widget.dart)**
- Camera/gallery selection
- Image preview
- Multiple image support
- Compression before encryption

---

## Stage 3: AI-Powered Features

### Features to Implement

#### 3.1 LLM Integration with Encryption

**[NEW] [llm_service.dart](file:///c:/Users/SWANAND/Desktop/AIBoomi/AI_Journal/lib/features/ai_insights/services/llm_service.dart)**
- Initialize Firebase AI with Flutter AI Toolkit
- Use FirebaseProvider with Gemini model (prototyping) or Vertex AI (production)
- Decrypt journal entry locally before sending to LLM
- Generate insights, writing prompts, summaries using LlmChatView
- Parse LLM responses and extract insights
- Error handling and rate limiting

> [!IMPORTANT]
> **Privacy Architecture**: Journal entries are encrypted in the database. Before sending to LLM, entries are decrypted client-side, sent to LLM API over HTTPS, and responses are processed locally. No encrypted data is sent to LLM services.

#### 3.2 Sentiment Analysis

**[NEW] [sentiment_service.dart](file:///c:/Users/SWANAND/Desktop/AIBoomi/AI_Journal/lib/features/ai_insights/services/sentiment_service.dart)**
- Analyze sentiment using LLM or local ML model
- Calculate sentiment score (-1 to 1)
- Categorize mood (happy, sad, neutral, anxious, etc.)
- Store sentiment data with entry

**[NEW] [sentiment_analysis_screen.dart](file:///c:/Users/SWANAND/Desktop/AIBoomi/AI_Journal/lib/features/ai_insights/screens/sentiment_analysis_screen.dart)**
- Display sentiment trends over time
- Line chart showing mood patterns
- Weekly/monthly aggregations
- Mood distribution pie chart

#### 3.3 AI Insights

**[NEW] [insights_screen.dart](file:///c:/Users/SWANAND/Desktop/AIBoomi/AI_Journal/lib/features/ai_insights/screens/insights_screen.dart)**
- Display AI-generated insights
- Personalized writing prompts
- Recurring themes detection
- Emotional patterns analysis
- Refresh button to regenerate insights

#### 3.4 Memory Recap (Snapchat-style)

**[NEW] [memory_recap_screen.dart](file:///c:/Users/SWANAND/Desktop/AIBoomi/AI_Journal/lib/features/ai_insights/screens/memory_recap_screen.dart)**
- Weekly/monthly recap summaries
- Highlight significant moments
- Photo collage from entries
- Shareable recap cards
- "On This Day" feature (past year entries)

**[NEW] [recap_carousel.dart](file:///c:/Users/SWANAND/Desktop/AIBoomi/AI_Journal/lib/features/ai_insights/widgets/recap_carousel.dart)**
- Swipeable recap cards
- Animated transitions
- Background music option (optional)

---

## Stage 4: Social & Analytics Features

### Features to Implement

#### 4.1 Streak Tracking

**[NEW] [streak_service.dart](file:///c:/Users/SWANAND/Desktop/AIBoomi/AI_Journal/lib/features/social/services/streak_service.dart)**
- Calculate current streak
- Track longest streak
- Check daily entry completion
- Send streak reminders (local notifications)

**[NEW] [streak_screen.dart](file:///c:/Users/SWANAND/Desktop/AIBoomi/AI_Journal/lib/features/social/screens/streak_screen.dart)**
- Display current streak count
- Show streak calendar
- Longest streak badge
- Motivational messages
- Share streak button

#### 4.2 Social Sharing

**[NEW] [share_card_generator.dart](file:///c:/Users/SWANAND/Desktop/AIBoomi/AI_Journal/lib/features/social/widgets/share_card_generator.dart)**
- Generate beautiful streak cards
- Customizable templates
- User stats (total entries, streak, days active)
- Privacy-safe (no journal content)
- Export as image

**[NEW] [share_preview_screen.dart](file:///c:/Users/SWANAND/Desktop/AIBoomi/AI_Journal/lib/features/social/screens/share_preview_screen.dart)**
- Preview shareable card
- Edit card design
- Share to social media platforms
- Save to gallery

#### 4.3 Analytics Dashboard

**[NEW] [dashboard_screen.dart](file:///c:/Users/SWANAND/Desktop/AIBoomi/AI_Journal/lib/features/dashboard/screens/dashboard_screen.dart)**
- Writing statistics overview
- Total entries count
- Average words per entry
- Most active days/times
- Mood distribution
- Writing frequency chart

**[NEW] [writing_frequency_chart.dart](file:///c:/Users/SWANAND/Desktop/AIBoomi/AI_Journal/lib/features/dashboard/widgets/writing_frequency_chart.dart)**
- Bar chart showing entries per week/month
- Heatmap calendar view

**[NEW] [mood_trend_chart.dart](file:///c:/Users/SWANAND/Desktop/AIBoomi/AI_Journal/lib/features/dashboard/widgets/mood_trend_chart.dart)**
- Line chart showing sentiment over time
- Color-coded mood indicators

#### 4.4 Additional Features

**[NEW] [settings_screen.dart](file:///c:/Users/SWANAND/Desktop/AIBoomi/AI_Journal/lib/features/settings/screens/settings_screen.dart)**
- Dark mode toggle
- Notification preferences
- Export data (encrypted JSON)
- Backup to cloud
- Delete account
- Privacy policy

**[NEW] [calendar_view_screen.dart](file:///c:/Users/SWANAND/Desktop/AIBoomi/AI_Journal/lib/features/journal/screens/calendar_view_screen.dart)**
- Monthly calendar view
- Dots indicating entries on specific days
- Tap to view entries for that day

---

## Security & Privacy Implementation

### Encryption Flow

1. **User Registration**: Generate unique encryption key using PBKDF2 from user password
2. **Key Storage**: Store encryption key in `flutter_secure_storage` (Android Keystore)
3. **Entry Creation**: 
   - User writes journal entry
   - Encrypt content using AES-256-GCM
   - Store encrypted content in Supabase
4. **Entry Retrieval**:
   - Fetch encrypted content from Supabase
   - Decrypt locally using stored key
   - Display to user
5. **LLM Processing**:
   - Decrypt entry locally
   - Send plaintext to LLM API over HTTPS
   - Process response locally
   - Never store LLM responses in encrypted form

### Security Best Practices

- Use `flutter_secure_storage` for encryption keys
- Implement biometric authentication (fingerprint/face)
- Add app lock with PIN/password
- Clear clipboard after copying sensitive data
- Implement certificate pinning for API calls
- Use Supabase Row Level Security (RLS) policies

---

## Verification Plan

### Stage 1 Verification

#### Automated Tests
```bash
# Run unit tests for authentication service
flutter test test/features/auth/services/auth_service_test.dart

# Run widget tests for login screen
flutter test test/features/auth/screens/login_screen_test.dart
```

#### Manual Testing
1. **Sign Up Flow**:
   - Open app → Navigate to Sign Up
   - Enter valid email and password → Verify account creation
   - Check Supabase dashboard for new user entry

2. **Login Flow**:
   - Enter registered credentials → Verify successful login
   - Test "Remember Me" functionality
   - Test invalid credentials → Verify error message

3. **Google OAuth**:
   - Click "Sign in with Google" → Complete OAuth flow
   - Verify user is logged in and redirected to home screen

4. **Password Reset**:
   - Click "Forgot Password" → Enter email
   - Check email for reset link → Complete password reset

### Stage 2 Verification

#### Automated Tests
```bash
# Run encryption service tests
flutter test test/core/services/encryption_service_test.dart

# Run journal service tests
flutter test test/features/journal/services/journal_service_test.dart
```

#### Manual Testing
1. **Create Entry**:
   - Click FAB → Write journal entry → Save
   - Verify entry appears in timeline
   - Check Supabase database → Verify content is encrypted

2. **Speech-to-Text**:
   - Click microphone button → Speak
   - Verify transcription appears in text field
   - Test with different accents/languages

3. **Image Upload**:
   - Add image from gallery → Verify preview
   - Save entry → Verify image is encrypted and stored
   - Retrieve entry → Verify image decrypts correctly

4. **Search**:
   - Search for keyword in entries
   - Verify search works on decrypted content

### Stage 3 Verification

#### Automated Tests
```bash
# Run LLM service tests (with mocked API)
flutter test test/features/ai_insights/services/llm_service_test.dart

# Run sentiment analysis tests
flutter test test/features/ai_insights/services/sentiment_service_test.dart
```

#### Manual Testing
1. **Sentiment Analysis**:
   - Create entries with different moods
   - Navigate to Sentiment Analysis screen
   - Verify sentiment scores are calculated
   - Check trend chart displays correctly

2. **AI Insights**:
   - Navigate to Insights screen
   - Verify insights are generated from journal entries
   - Test refresh functionality

3. **Memory Recap**:
   - Navigate to Memory Recap
   - Verify weekly/monthly summaries are generated
   - Test "On This Day" feature with old entries

### Stage 4 Verification

#### Automated Tests
```bash
# Run streak service tests
flutter test test/features/social/services/streak_service_test.dart

# Run dashboard analytics tests
flutter test test/features/dashboard/services/dashboard_service_test.dart
```

#### Manual Testing
1. **Streak Tracking**:
   - Write entries on consecutive days
   - Verify streak counter increments
   - Skip a day → Verify streak resets

2. **Social Sharing**:
   - Navigate to Streak screen → Click Share
   - Verify shareable card is generated
   - Test sharing to different platforms

3. **Analytics Dashboard**:
   - Navigate to Dashboard
   - Verify all statistics are calculated correctly
   - Check charts render properly
   - Test different date ranges

4. **Dark Mode**:
   - Toggle dark mode in settings
   - Verify all screens adapt to dark theme

### Integration Testing
```bash
# Run full integration tests
flutter test integration_test/app_test.dart
```

### Performance Testing
- Test app with 1000+ journal entries
- Measure encryption/decryption speed
- Monitor memory usage during image uploads
- Test offline functionality

---

## Dependencies to Add

Update `pubspec.yaml` with:

```yaml
dependencies:
  # Core
  supabase_flutter: ^2.0.0
  flutter_secure_storage: ^9.0.0
  encrypt: ^5.0.3
  
  # AI Features (Flutter AI Toolkit)
  flutter_ai_toolkit: ^0.1.0
  firebase_ai: ^0.1.0
  firebase_core: ^3.0.0
  
  # Media & UI
  image_picker: ^1.0.7
  fl_chart: ^0.66.0
  share_plus: ^7.2.0
  cached_network_image: ^3.3.1
  
  # State & Utils
  provider: ^6.1.1
  intl: ^0.19.0
  
  # Security & Auth
  local_auth: ^2.1.8
  google_sign_in: ^6.2.1
  
  # Notifications
  flutter_local_notifications: ^17.0.0
  path_provider: ^2.1.2
```

---

## Next Steps

1. Review this implementation plan
2. Set up Supabase project and obtain credentials
3. Begin Stage 1 implementation (Authentication & Foundation)
4. Proceed sequentially through stages 2-4
5. Conduct thorough testing at each stage
