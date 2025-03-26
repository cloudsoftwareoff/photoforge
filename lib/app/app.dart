import 'package:flutter/material.dart';
import 'theme.dart';
import '../screens/photo_editor_screen.dart';

class AdvancedPhotoEditorApp extends StatelessWidget {
  const AdvancedPhotoEditorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pro Photo Editor',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      home: const PhotoEditorScreen(),
    );
  }
}