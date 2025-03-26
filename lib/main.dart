import 'package:flutter/material.dart';
import 'package:photoforge/screens/ai_generator.dart';
import 'package:photoforge/screens/photo_editor_screen.dart';
import 'app/app.dart';

void main() {
  runApp(AdvancedPhotoEditorApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PhotoForge',
      theme: ThemeData.dark(),
      home: const AIGeneratorScreen(), // Or your home screen
    );
  }
}
