import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

class ImageUtils {
  static Future<File?> cropImage({
    required File sourceFile,
    required ValueChanged<String> onError,
    required VoidCallback onStart,
    required VoidCallback onComplete,
    Color? toolbarColor,
    Color? toolbarWidgetColor,
  }) async {
    onStart();
    
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: sourceFile.path,
       // cropStsyle: CropStyle.rectangle, // or CropStyle.circle for circular crops
        aspectRatio: const CropAspectRatio(ratioX: 1.0, ratioY: 1.0), // Default square
        // aspectRatioPresets: [
        //   CropAspectRatioPreset.original,
        //   CropAspectRatioPreset.square,
        //   CropAspectRatioPreset.ratio3x2,
        //   CropAspectRatioPreset.ratio4x3,
        //   CropAspectRatioPreset.ratio16x9,
        // ],
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: toolbarColor ?? Colors.deepPurple,
            toolbarWidgetColor: toolbarWidgetColor ?? Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            title: 'Crop Image',
            aspectRatioLockEnabled: false,
          ),
          // WebUiSettings(
          //   context: context, // You'll need to pass context if supporting web
          // ),
        ],
      );

      return croppedFile != null ? File(croppedFile.path) : null;
    } catch (e) {
      onError('Failed to crop image: ${e.toString()}');
      return null;
    } finally {
      onComplete();
    }
  }
}