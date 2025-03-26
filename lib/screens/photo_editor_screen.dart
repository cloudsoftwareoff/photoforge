import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photoforge/services/crop_image.dart';
import '../widgets/filter_item.dart';
import '../widgets/adjustment_slider.dart';
import '../models/image_filter.dart';
import '../services/image_processing.dart';
import '../utils/file_utils.dart';

class PhotoEditorScreen extends StatefulWidget {
  const PhotoEditorScreen({super.key});

  @override
  _PhotoEditorScreenState createState() => _PhotoEditorScreenState();
}

class _PhotoEditorScreenState extends State<PhotoEditorScreen> {
  File? _imageFile;
  Uint8List? _processedImage;
  ImageFilter _currentFilter = ImageFilter.original;
  double _brightnessValue = 0.0;
  double _contrastValue = 1.0;
  double _saturationValue = 1.0;
  double _warmthValue = 0.0;
  double _vignetteValue = 0.0;
  bool _isProcessing = false;

  final _picker = ImagePicker();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _isProcessing = true;
        });

        final file = File(pickedFile.path);
        final bytes = await file.readAsBytes();

        setState(() {
          _imageFile = file;
          _processedImage = bytes;
          _brightnessValue = 0.0;
          _contrastValue = 1.0;
          _saturationValue = 1.0;
          _warmthValue = 0.0;
          _vignetteValue = 0.0;
          _currentFilter = ImageFilter.original;
          _isProcessing = false;
        });
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      _showErrorSnackbar('Failed to load image: ${e.toString()}');
    }
  }
Future<void> _cropImage() async {
  if (_imageFile == null) return;

  final croppedFile = await ImageUtils.cropImage(
    sourceFile: _imageFile!,
    onError: _showErrorSnackbar,
    onStart: () => setState(() => _isProcessing = true),
    onComplete: () => setState(() => _isProcessing = false),
    toolbarColor: Theme.of(context).primaryColor,
    toolbarWidgetColor: Colors.white,
  );

  if (croppedFile != null) {
    final bytes = await croppedFile.readAsBytes();
    setState(() {
      _imageFile = croppedFile;
      _processedImage = bytes;
      _resetAdjustments(); // Reset filters after crop
    });
  }
}
  Future<void> _saveImage() async {
    if (_processedImage == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final status = await checkStoragePermission();
      final filePath = await saveImageToGallery(_processedImage!);
      _showSuccessSnackbar('Image saved to $filePath');
    } catch (e) {
      _showErrorSnackbar('Failed to save image: ${e.toString()}');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _applyChanges() {
    if (_imageFile == null) return;

    setState(() {
      _isProcessing = true;
    });

    Future.delayed(Duration.zero, () {
      final result = processImage(
        _imageFile!.readAsBytesSync(),
        filter: _currentFilter,
        brightness: _brightnessValue,
        contrast: _contrastValue,
        saturation: _saturationValue,
        warmth: _warmthValue,
        vignette: _vignetteValue,
      );

      setState(() {
        _processedImage = result;
        _isProcessing = false;
      });
    });
  }

  void _resetAdjustments() {
    setState(() {
      _brightnessValue = 0.0;
      _contrastValue = 1.0;
      _saturationValue = 1.0;
      _warmthValue = 0.0;
      _vignetteValue = 0.0;
      _currentFilter = ImageFilter.original;
    });
    _applyChanges();
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade800,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade800,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showImageSourceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photo Forge'),
        centerTitle: true,
    actions: [
          if (_imageFile != null)
            IconButton(
              icon: const Icon(Icons.crop),
              onPressed: _isProcessing ? null : _cropImage,
              tooltip: 'Crop Image',
            ),
          if (_imageFile != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _resetAdjustments,
              tooltip: 'Reset Adjustments',
            ),
          if (_imageFile != null)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _isProcessing ? null : _saveImage,
              tooltip: 'Save Image',
            ),
        ],
      ),
      body: Column(
        children: [
          // Image Preview
          Expanded(
            flex: 3,
            child: _processedImage == null
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image_search, size: 100, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Select an image to get started',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : Stack(
                    children: [
                      InteractiveViewer(
                        maxScale: 3.0,
                        child: Image.memory(
                          _processedImage!,
                          fit: BoxFit.contain,
                          gaplessPlayback: true,
                        ),
                      ),
                      if (_isProcessing)
                        const Center(
                          child: CircularProgressIndicator(),
                        ),
                    ],
                  ),
          ),

          // Filter Selection
          if (_imageFile != null) ...[
            SizedBox(
              height: 150,
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'FILTERS',
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      itemCount: ImageFilter.values.length,
                      itemBuilder: (context, index) {
                        final filter = ImageFilter.values[index];
                        return FilterItem(
                          filter: filter,
                          isSelected: _currentFilter == filter,
                          imageBytes: _imageFile!.readAsBytesSync(),
                          onTap: () {
                            setState(() {
                              _currentFilter = filter;
                            });
                            _applyChanges();
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
          ],

          // Adjustment Sliders
          if (_imageFile != null) ...[
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  AdjustmentSlider(
                    icon: Icons.brightness_6,
                    label: 'Brightness',
                    value: _brightnessValue,
                    onChanged: (value) {
                      setState(() {
                        _brightnessValue = value;
                      });
                      _applyChanges();
                    },
                    min: -1.0,
                    max: 1.0,
                    divisions: 20,
                  ),
                  AdjustmentSlider(
                    icon: Icons.contrast,
                    label: 'Contrast',
                    value: _contrastValue,
                    onChanged: (value) {
                      setState(() {
                        _contrastValue = value;
                      });
                      _applyChanges();
                    },
                    min: 0.0,
                    max: 2.0,
                    divisions: 20,
                  ),
                  AdjustmentSlider(
                    icon: Icons.color_lens,
                    label: 'Saturation',
                    value: _saturationValue,
                    onChanged: (value) {
                      setState(() {
                        _saturationValue = value;
                      });
                      _applyChanges();
                    },
                    min: 0.0,
                    max: 2.0,
                    divisions: 20,
                  ),
                  AdjustmentSlider(
                    icon: Icons.whatshot,
                    label: 'Warmth',
                    value: _warmthValue,
                    onChanged: (value) {
                      setState(() {
                        _warmthValue = value;
                      });
                      _applyChanges();
                    },
                    min: -1.0,
                    max: 1.0,
                    divisions: 20,
                  ),
                  AdjustmentSlider(
                    icon: Icons.vignette,
                    label: 'Vignette',
                    value: _vignetteValue,
                    onChanged: (value) {
                      setState(() {
                        _vignetteValue = value;
                      });
                      _applyChanges();
                    },
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      floatingActionButton: _imageFile == null
          ? FloatingActionButton.extended(
              onPressed: () => _showImageSourceDialog(context),
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('Add Photo'),
              elevation: 4,
            )
          : null,
      bottomNavigationBar: _imageFile != null
          ? BottomAppBar(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                    onPressed: () => _pickImage(ImageSource.gallery),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                    onPressed: () => _pickImage(ImageSource.camera),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
