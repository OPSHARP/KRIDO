# 🎮 KRIDO — Kids Educational Mini-Game Collection

A cheerful, offline-first Flutter app packed with educational mini-games for children ages 3–8. Learn numbers, letters, shapes, animals, music, and more through short, forgiving play sessions.

## ✨ Features

- **28+ Educational Mini-Games** — Number circles, letter tracing, animal jigsaws, spelling puzzles, color mixing lab, musical xylophone, and many more.
- **Offline-First** — No internet required. All content is bundled.
- **Child-Safe (COPPA Compliant)** — No logins, no social features, no user data collection, no behavioral ads.
- **Multiple Profiles** — Up to 4 local player profiles with avatars.
- **Session Timer** — Parent-selectable play duration (5, 10, 15, 20 minutes or unlimited).
- **Progress Tracking** — Stars, stickers, and achievement awards stored locally.
- **Text-to-Speech** — Voice narration for instructions and encouragement.
- **Portrait-Locked** — Optimized for one-handed phone use by kids.

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter (Dart) |
| State Management | Riverpod |
| Local Database | sqflite |
| Audio | audioplayers, flutter_tts |
| Ads (optional) | Google Mobile Ads (child-directed) |
| Fonts | Google Fonts |

## 🚀 Getting Started

### Prerequisites

- Flutter SDK `^3.13.0`
- Android SDK (compileSdk 36)
- A device or emulator

### Run the app

```bash
# Clone the repo
git clone https://github.com/OPSHARP/KRIDO.git
cd KRIDO

# Get dependencies
flutter pub get

# Run on connected device / emulator
flutter run
```

### Production Build (with your own AdMob IDs)

```bash
flutter build apk --release \
  --dart-define=ADMOB_APP_ID=ca-app-pub-YOUR_ID~YOUR_APP \
  --dart-define=ADMOB_BANNER_ID=ca-app-pub-YOUR_ID/YOUR_BANNER \
  --dart-define=ADMOB_REWARDED_ID=ca-app-pub-YOUR_ID/YOUR_REWARDED \
  --dart-define=ADMOB_NATIVE_ID=ca-app-pub-YOUR_ID/YOUR_NATIVE
```

> **Note:** By default, the app uses Google's official **test ad unit IDs** so it runs safely out of the box. Replace them with your own AdMob IDs for production via `--dart-define`.

### Android Signing

1. Copy `android/key.properties.example` → `android/key.properties`
2. Fill in your actual keystore path and credentials.
3. Place your `.jks` keystore file in the `android/` directory.

## 📁 Project Structure

```
lib/
├── main.dart                 # App entry point
├── app/                      # App-level config (theme, routing)
├── core/                     # Shared services (ads, audio, database)
├── domain/                   # Data models & business logic
├── features/                 # UI screens (hub, profile, parent area)
└── games/
    ├── game_factory.dart     # Dynamic game loader
    ├── registry.dart         # Game metadata registry
    └── modules/              # Individual game implementations
        ├── g001_number_pebble_circle/
        ├── g002_count_orchard/
        ├── g011_find_the_letter/
        ├── g051_animal_jigsaw/
        ├── g079_letter_tracing/
        ├── g080_musical_xylophone/
        └── ... (28+ games)
```

## 📜 License

This project is released under the [MIT License](LICENSE).

## 🤝 Contributing

Contributions are welcome! Feel free to open issues or submit pull requests.

## 📧 Contact

For questions or feedback, open an issue on this repository.
