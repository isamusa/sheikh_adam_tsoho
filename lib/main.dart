// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'screens/main_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'screens/theme_provider.dart'; // Import ThemeProvider

import 'package:just_audio_background/just_audio_background.dart';
import 'providers/audio_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.example.sheikh_adam_tsoho.audio',
    androidNotificationChannelName: 'Audio Playback',
    androidNotificationOngoing: true,
    androidStopForegroundOnPause: true,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AudioProvider()),
      ],
      child: const ScholarsSermonsApp(),
    ),
  );
}

class ScholarsSermonsApp extends StatelessWidget {
  const ScholarsSermonsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Al-Marhum Sheikh Adamu Tsoho Jos',
      themeMode: Provider.of<ThemeProvider>(context).themeMode,
      theme: ThemeProvider.lightTheme,
      darkTheme: ThemeProvider.darkTheme,
      home: const MainScreen(),
    );
  }
}
