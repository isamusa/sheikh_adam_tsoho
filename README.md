# Sheikh Adamu Tsoho Jos - Sermon App

A premium Flutter application dedicated to streaming and organizing the sermons of Al-Marhum Sheikh Adamu Tsoho Jos (رحمه الله).

## Features

- **Global Audio Playback**: Listen to sermons in the background while navigating the app, complete with a persistent mini-player.
- **Dynamic "Mafi Sabunta"**: The app dynamically tracks your recently played sermons locally for quick access.
- **Offline YouTube Playback**: The "Bankwana" video reel allows you to stream unlisted YouTube videos while automatically downloading them in the background for true offline playback next time.
- **Auto-Download Audio**: Sermons are automatically downloaded to local storage upon streaming, saving data for future listens.
- **Premium UI / UX**: A highly polished, modern interface with parallax scrolling, glassmorphism, and beautiful typography (`GoogleFonts.playfairDisplay`, `Lora`, `Inter`).
- **Hausa First**: The entire app is translated and styled natively for Hausa speakers.

## Getting Started

1. Ensure you have Flutter installed.
2. Clone the repository.
3. Run `flutter pub get` to install dependencies.
4. Run the app using `flutter run` on your preferred emulator or physical device.

## Core Packages Used

- `just_audio` & `just_audio_background` (Background audio streaming)
- `video_player` & `chewie` (Video playback)
- `youtube_explode_dart` (YouTube stream extraction)
- `shared_preferences` (Local storage for history)
- `cloud_firestore` & `firebase_core` (Backend)

## Versioning
Current version: `2.0.0+4`
