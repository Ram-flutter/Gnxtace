import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gnxtace/screens.dart';
import 'package:gnxtace/theme/app_theme.dart';



void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const ProviderScope(
      child: LumaGalleryApp(),
    ),
  );
}

class LumaGalleryApp extends StatelessWidget {
  const LumaGalleryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'GNXTACE Gallery',

      theme: AppTheme.darkTheme,

      home: const HomeScreen(),
    );
  }
}