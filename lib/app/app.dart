import 'package:flutter/material.dart';
import 'theme.dart';
import '../screens/photo_editor_screen.dart';

class PhotoForgeApp extends StatelessWidget {
  const PhotoForgeApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photo Forge',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      home: const PhotoEditorScreen(),
    );
  }
}