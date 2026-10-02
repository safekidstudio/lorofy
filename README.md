# 🦉 Lorofy - Gamified Focus Timer & App Blocker

<p align="center">
  <img src="assets/logos/logo.png" alt="Lorofy Logo" width="120" height="120" />
</p>

<p align="center">
  <b>Transform focus sessions into engaging experiences alongside your interactive Mascot companion!</b><br>
  Boost productivity, build discipline, and eliminate social media distractions.
</p>

<p align="center">
  <a href="https://play.google.com/store/apps/details?id=com.lorofy.app"><img src="https://img.shields.io/badge/Google%20Play-Live%20Now-brightgreen.svg?logo=googleplay&logoColor=white" alt="Google Play Store"/></a>
  <a href="#-tech-stack"><img src="https://img.shields.io/badge/Flutter-3.x-blue.svg" alt="Flutter"/></a>
  <a href="#-tech-stack"><img src="https://img.shields.io/badge/Backend-Java%20Spring%20Boot-orange.svg" alt="Spring Boot"/></a>
  <a href="#-tech-stack"><img src="https://img.shields.io/badge/Database-PostgreSQL-blue.svg" alt="PostgreSQL"/></a>
  <a href="#-tech-stack"><img src="https://img.shields.io/badge/State-Riverpod%203.x-purple.svg" alt="Riverpod"/></a>
</p>

<p align="center">
  👉 <b><a href="https://play.google.com/store/apps/details?id=com.lorofy.app">Get Lorofy on Google Play Store</a></b>
</p>

---

## 🌟 About Lorofy

**Lorofy** is a next-generation productivity application combining the **Pomodoro technique**, **Smart App Whitelist & Blocker**, and **Gamification** featuring an interactive real-time Mascot companion.

Lorofy helps students and professionals build consistent study habits, foster self-discipline, and protect focus sessions from annoying notifications and social media distractions.

---

## ✨ Key Features (Completed & Released)

### ⏱️ 1. Advanced Pomodoro Engine
- **Flexible Session Configuration:** Customize Focus duration, Short Breaks, Long Breaks, and total Rounds.
- **Deep Focus / Strict Mode:** Block distracting apps and display warning confirmation with point penalties upon premature give-up.
- **Category Customization:** Categorize focus sessions (Studying, Work, Reading, Creativity, etc.).

### 🛡️ 2. Smart App Whitelist & Blocker
- **Custom App Whitelist:** Allow essential study apps (Dictionaries, Calculators, Notion, etc.) during active sessions.
- **Installed App Scanner:** Automatically scan and display installed apps on Android & iOS with intuitive controls.
- **Permission Flow:** Smooth onboarding for `UsageStatsManager` and system access permissions.

### 🦉 3. Interactive Mascot System
- **Real-Time Mascot Reactions:** Dynamic animations (powered by Rive & Lottie) responding to user focus state (Focusing, Resting, Celebrating, or Disappointed on give-up).
- **Mascot Selection:** Choose your favorite companion mascot to accompany your journey.

### 🎶 4. Ambient Soundscapes & Sound Player
- **Focus Soundscapes:** Calming audio tracks (Rain, Ocean Waves, Cafe Ambiance, Forest Sounds) to optimize brainwave focus.
- **Explore Tab:** Discover curated playlists and control background audio independently.

### 🏆 5. Gamification, Streak & Leaderboard
- **Streak Tracking:** Count consecutive focus days with rewarding celebration pages.
- **Lorofy Rank Points:** Earn reward points after successfully completing sessions.
- **Global Leaderboard:** Compare daily and weekly focus time and rankings with the community.

### 👤 6. Authentication, Profile & Analytics
- **Multi-Platform Auth:** Secure Email OTP login/registration, Google Sign-In, and JWT authentication.
- **Interactive Onboarding:** Seamless step-by-step introduction designed with Cupertino iOS aesthetics.
- **Comprehensive Analytics:** Interactive charts (`fl_chart`) tracking focus minutes and activity logs.

---

## 🚀 Tech Stack

### Client (Mobile App)
| Category | Technology / Package | Role |
|---|---|---|
| **Framework** | **Flutter 3.x / Dart 3.x** | Sound null-safety, cross-platform iOS & Android |
| **State Management** | **Riverpod 3.x** (`riverpod_generator`) | Reactive state management & Dependency Injection |
| **Routing** | **GoRouter 17.x** | Declarative navigation with custom Cupertino transitions |
| **Networking** | **Dio 5.x** | REST API HTTP Client with JWT Interceptors & Auto Token Refresh |
| **Storage & Security** | **Flutter Secure Storage** + **Shared Preferences** | Encrypted JWT token storage & app state caching |
| **Animations** | **Rive 0.14** & **Lottie 3.3** | Real-time interactive Mascot animations & victory visual effects |
| **Audio Player** | **Audioplayers 6.7** | Ambient background soundscapes & audio controls |
| **Charts** | **fl_chart 1.2** | Interactive productivity analytics and time distribution charts |
| **App Management** | **installed_apps** & Platform Channels | Scan installed packages and trigger native app blocking |

### Backend & Infrastructure
| Category | Technology | Role |
|---|---|---|
| **Framework** | **Java (Spring Boot 3.x)** | Spring Security, Spring Data JPA, RESTful API services |
| **Database** | **PostgreSQL** | Relational database storing users, focus logs, ranks & configurations |
| **Authentication** | **JWT (JSON Web Token)** | Secure stateless API authentication |
| **Cloud Infrastructure** | Docker / Render / Neon Postgres | Production-ready serverless and containerized deployment |

---

## 🏗️ Architecture

The project follows **Feature-first Clean Architecture** integrated with a **Cupertino Adaptive Design System**:

```text
lib/
├── core/                           # System-wide core configurations
│   ├── config/                     # Environment config via --dart-define-from-file
│   ├── constants/                  # AppConstants & Design Tokens
│   ├── network/                    # Dio Client & Token Interceptors
│   ├── router/                     # GoRouter configuration & Redirect Guards
│   └── theme/                      # Cupertino Themes & Color Palettes
├── features/                       # Feature modules (Feature-first Clean Arch)
│   ├── auth/                       # Login, Register, OTP Verification, Password setup
│   ├── explore/                    # Soundscapes discovery & Leaderboard
│   ├── focus/                      # Core Pomodoro Engine & App Whitelist Blocker
│   ├── home/                       # Main Dashboard Page
│   ├── mascot/                     # Mascot state notifier & Interactive UI
│   ├── profile/                    # User Profile, Activity Logs & Streak Celebration
│   └── settings/                   # Session & Audio settings
└── main.dart                       # Application entry point
```

---

## 🛠️ Installation & Setup Guide

### 1. Prerequisites
- **Flutter SDK**: `>=3.11.4`
- **Dart SDK**: `>=3.0.0`
- **Android Studio** / **Xcode** (for iOS builds)

### 2. Install Dependencies & Code Generation
```bash
# Get packages
flutter pub get

# Generate code for Riverpod & JSON Serializers
dart run build_runner build --delete-conflicting-outputs
```

### 3. Running the App (Development & Production)

#### 🔹 Development Environment (Local BE)
```bash
flutter run --dart-define-from-file=configs/env.dev.json
```

#### 🔸 Production Environment (Cloud BE)
```bash
# Run in Release Mode
flutter run --release --dart-define-from-file=configs/env.json

# Build Android App Bundle (Published on Google Play)
flutter build appbundle --release --dart-define-from-file=configs/env.json

# Build iOS IPA (Ready for App Store Release)
flutter build ipa --release --dart-define-from-file=configs/env.json
```

---

## 📱 Google Play Store

🔗 **Official Download:** [Lorofy on Google Play Store](https://play.google.com/store/apps/details?id=com.lorofy.app)

---

## 📄 License

Copyright © 2026 **Lorofy Team**. All rights reserved.