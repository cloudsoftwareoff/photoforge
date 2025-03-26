import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

void main() {
  runApp(const AdvancedPhotoEditorApp());
}

class AdvancedPhotoEditorApp extends StatelessWidget {
  const AdvancedPhotoEditorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pro Photo Editor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.deepPurple,
        colorScheme: ColorScheme.dark(
          primary: Colors.deepPurple,
          secondary: Colors.purpleAccent,
          surface: Colors.grey[900]!,
          background: Colors.grey[900]!,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        sliderTheme: SliderThemeData(
          activeTrackColor: Colors.deepPurple,
          inactiveTrackColor: Colors.deepPurple.shade800,
          thumbColor: Colors.deepPurpleAccent,
          overlayColor: Colors.deepPurple.withAlpha(0x29),
          valueIndicatorColor: Colors.deepPurple,
          activeTickMarkColor: Colors.deepPurpleAccent,
          inactiveTickMarkColor: Colors.deepPurple.shade800,
        ),
      ),
      home: const PhotoEditorScreen(),
    );
  }
}

class PhotoEditorScreen extends StatefulWidget {
  const PhotoEditorScreen({Key? key}) : super(key: key);

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

  Uint8List _applyFilter(
    Uint8List imageBytes, {
    required ImageFilter filter,
    double brightness = 0.0,
    double contrast = 1.0,
    double saturation = 1.0,
    double warmth = 0.0,
    double vignette = 0.0,
  }) {
    // Decode the image
    img.Image? originalImage = img.decodeImage(imageBytes);
    if (originalImage == null) return imageBytes;

    img.Image image = img.Image.from(originalImage);

    // Apply base filter
    switch (filter) {
      case ImageFilter.blackAndWhite:
        img.grayscale(image);
        break;
      case ImageFilter.sepia:
        _applySepia(image);
        break;
      case ImageFilter.vintage:
        _applyVintage(image);
        break;
      case ImageFilter.dramatic:
        _applyDramatic(image);
        break;
      case ImageFilter.moody:
        _applyMoody(image);
        break;
      case ImageFilter.cool:
        _applyCool(image);
        break;
      case ImageFilter.warm:
        _applyWarm(image);
        break;
      case ImageFilter.original:
        break;
    }

    // Apply brightness and contrast
    _applyBrightnessContrast(image, brightness, contrast);

    // Apply saturation
    _applySaturation(image, saturation);

    // Apply warmth
    _applyWarmth(image, warmth);

    // Apply vignette
    if (vignette > 0) {
      _applyVignette(image, vignette);
    }

    return Uint8List.fromList(img.encodePng(image));
  }

  void _applySepia(img.Image image) {
    for (int x = 0; x < image.width; x++) {
      for (int y = 0; y < image.height; y++) {
        final pixel = image.getPixel(x, y);
        final r = pixel.r;
        final g = pixel.g;
        final b = pixel.b;

        final tr = (0.393 * r + 0.769 * g + 0.189 * b).clamp(0, 255).toInt();
        final tg = (0.349 * r + 0.686 * g + 0.168 * b).clamp(0, 255).toInt();
        final tb = (0.272 * r + 0.534 * g + 0.131 * b).clamp(0, 255).toInt();

        image.setPixel(x, y, img.ColorRgb8(tr, tg, tb));
      }
    }
  }

  void _applyVintage(img.Image image) {
    for (int x = 0; x < image.width; x++) {
      for (int y = 0; y < image.height; y++) {
        final pixel = image.getPixel(x, y);
        final r = (pixel.r * 0.9).clamp(0, 255).toInt();
        final g = (pixel.g * 0.8).clamp(0, 255).toInt();
        final b = (pixel.b * 0.6).clamp(0, 255).toInt();
        image.setPixel(x, y, img.ColorRgb8(r, g, b));
      }
    }
  }

  void _applyDramatic(img.Image image) {
    for (int x = 0; x < image.width; x++) {
      for (int y = 0; y < image.height; y++) {
        final pixel = image.getPixel(x, y);
        final r = ((pixel.r - 128) * 1.5 + 128).clamp(0, 255).toInt();
        final g = ((pixel.g - 128) * 1.5 + 128).clamp(0, 255).toInt();
        final b = ((pixel.b - 128) * 1.5 + 128).clamp(0, 255).toInt();
        image.setPixel(x, y, img.ColorRgb8(r, g, b));
      }
    }
  }

  void _applyMoody(img.Image image) {
    for (int x = 0; x < image.width; x++) {
      for (int y = 0; y < image.height; y++) {
        final pixel = image.getPixel(x, y);
        final r = (pixel.r * 0.7).clamp(0, 255).toInt();
        final g = (pixel.g * 0.7).clamp(0, 255).toInt();
        final b = (pixel.b * 0.9).clamp(0, 255).toInt();
        image.setPixel(x, y, img.ColorRgb8(r, g, b));
      }
    }
  }

  void _applyCool(img.Image image) {
    for (int x = 0; x < image.width; x++) {
      for (int y = 0; y < image.height; y++) {
        final pixel = image.getPixel(x, y);
        final r = (pixel.r * 0.8).clamp(0, 255).toInt();
        final g = (pixel.g * 0.9).clamp(0, 255).toInt();
        final b = pixel.b.toInt();
        image.setPixel(x, y, img.ColorRgb8(r, g, b));
      }
    }
  }

  void _applyWarm(img.Image image) {
    for (int x = 0; x < image.width; x++) {
      for (int y = 0; y < image.height; y++) {
        final pixel = image.getPixel(x, y);
        final r = pixel.r.toInt();
        final g = (pixel.g * 0.9).clamp(0, 255).toInt();
        final b = (pixel.b * 0.8).clamp(0, 255).toInt();
        image.setPixel(x, y, img.ColorRgb8(r, g, b));
      }
    }
  }

  void _applyBrightnessContrast(
      img.Image image, double brightness, double contrast) {
    final brightnessAmount = (brightness * 255).toInt();
    final contrastAmount = contrast;

    // Apply brightness
    if (brightnessAmount != 0) {
      for (int y = 0; y < image.height; y++) {
        for (int x = 0; x < image.width; x++) {
          final pixel = image.getPixel(x, y);
          final r = (pixel.r + brightnessAmount).clamp(0, 255).toInt();
          final g = (pixel.g + brightnessAmount).clamp(0, 255).toInt();
          final b = (pixel.b + brightnessAmount).clamp(0, 255).toInt();
          image.setPixel(x, y, img.ColorRgb8(r, g, b));
        }
      }
    }

    // Apply contrast
    if (contrastAmount != 1.0) {
      final factor = (259 * (contrastAmount * 100 + 255)) /
          (255 * (259 - contrastAmount * 100));
      for (int y = 0; y < image.height; y++) {
        for (int x = 0; x < image.width; x++) {
          final pixel = image.getPixel(x, y);
          final r = (factor * (pixel.r - 128) + 128).clamp(0, 255).toInt();
          final g = (factor * (pixel.g - 128) + 128).clamp(0, 255).toInt();
          final b = (factor * (pixel.b - 128) + 128).clamp(0, 255).toInt();
          image.setPixel(x, y, img.ColorRgb8(r, g, b));
        }
      }
    }
  }

  void _applySaturation(img.Image image, double saturation) {
    if (saturation == 1.0) return;

    for (int x = 0; x < image.width; x++) {
      for (int y = 0; y < image.height; y++) {
        final pixel = image.getPixel(x, y);
        final hsl =
            _rgbToHsl(pixel.r.toInt(), pixel.g.toInt(), pixel.b.toInt());
        final s = (hsl[1] * saturation).clamp(0.0, 1.0);
        final rgb = _hslToRgb(hsl[0], s, hsl[2]);
        image.setPixel(x, y, img.ColorRgb8(rgb[0], rgb[1], rgb[2]));
      }
    }
  }

  void _applyWarmth(img.Image image, double warmth) {
    if (warmth == 0.0) return;

    for (int x = 0; x < image.width; x++) {
      for (int y = 0; y < image.height; y++) {
        final pixel = image.getPixel(x, y);
        int r = pixel.r.toInt();
        int b = pixel.b.toInt();

        if (warmth > 0) {
          // Add warmth (increase red, decrease blue)
          r = (r + warmth * 50).clamp(0, 255).toInt();
          b = (b - warmth * 30).clamp(0, 255).toInt();
        } else {
          // Add coolness (decrease red, increase blue)
          r = (r + warmth * 30).clamp(0, 255).toInt();
          b = (b - warmth * 50).clamp(0, 255).toInt();
        }

        image.setPixel(x, y, img.ColorRgb8(r, pixel.g.toInt(), b));
      }
    }
  }

  void _applyVignette(img.Image image, double strength) {
    final centerX = image.width / 2;
    final centerY = image.height / 2;
    final maxDist = math.sqrt(centerX * centerX + centerY * centerY);
    final amount = strength * 2.0;

    for (int x = 0; x < image.width; x++) {
      for (int y = 0; y < image.height; y++) {
        final dx = centerX - x;
        final dy = centerY - y;
        final distance = math.sqrt(dx * dx + dy * dy);
        final vignette = 1.0 - (distance / maxDist) * amount;

        final pixel = image.getPixel(x, y);
        final r = (pixel.r * vignette).clamp(0, 255).toInt();
        final g = (pixel.g * vignette).clamp(0, 255).toInt();
        final b = (pixel.b * vignette).clamp(0, 255).toInt();

        image.setPixel(x, y, img.ColorRgb8(r, g, b));
      }
    }
  }

  List<double> _rgbToHsl(int r, int g, int b) {
    final red = r / 255.0;
    final green = g / 255.0;
    final blue = b / 255.0;

    final max = [red, green, blue].reduce(math.max);
    final min = [red, green, blue].reduce(math.min);
    double h, s, l = (max + min) / 2;

    if (max == min) {
      h = s = 0.0;
    } else {
      final d = max - min;
      s = l > 0.5 ? d / (2.0 - max - min) : d / (max + min);

      if (max == red) {
        h = (green - blue) / d + (green < blue ? 6.0 : 0.0);
      } else if (max == green) {
        h = (blue - red) / d + 2.0;
      } else {
        h = (red - green) / d + 4.0;
      }

      h /= 6.0;
    }

    return [h, s, l];
  }

  List<int> _hslToRgb(double h, double s, double l) {
    double r, g, b;

    if (s == 0.0) {
      r = g = b = l;
    } else {
      final q = l < 0.5 ? l * (1.0 + s) : l + s - l * s;
      final p = 2.0 * l - q;

      r = _hueToRgb(p, q, h + 1.0 / 3.0);
      g = _hueToRgb(p, q, h);
      b = _hueToRgb(p, q, h - 1.0 / 3.0);
    }

    return [
      (r * 255).round().clamp(0, 255),
      (g * 255).round().clamp(0, 255),
      (b * 255).round().clamp(0, 255)
    ];
  }

  double _hueToRgb(double p, double q, double t) {
    if (t < 0.0) t += 1.0;
    if (t > 1.0) t -= 1.0;
    if (t < 1.0 / 6.0) return p + (q - p) * 6.0 * t;
    if (t < 1.0 / 2.0) return q;
    if (t < 2.0 / 3.0) return p + (q - p) * (2.0 / 3.0 - t) * 6.0;
    return p;
  }

  Future<void> _saveImage() async {
    if (_processedImage == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final directory = await getDownloadDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${directory.path}/edited_image_$timestamp.png');

      await file.writeAsBytes(_processedImage!);
      _showSuccessSnackbar('Image saved to Gallery');
    } catch (e) {
      _showErrorSnackbar('Failed to save image: ${e.toString()}');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
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

  void _applyChanges() {
    if (_imageFile == null) return;

    setState(() {
      _isProcessing = true;
    });

    // Process in a separate isolate to avoid UI jank
    Future.delayed(Duration.zero, () {
      final result = _applyFilter(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pro Photo Editor'),
        centerTitle: true,
        actions: [
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
                        return _FilterItem(
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
                  _buildSlider(
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
                  _buildSlider(
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
                  _buildSlider(
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
                  _buildSlider(
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
                  _buildSlider(
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

  Widget _buildSlider({
    required IconData icon,
    required String label,
    required double value,
    required void Function(double) onChanged,
    required double min,
    required double max,
    int divisions = 10,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.white70),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                value.toStringAsFixed(2),
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
          Slider(
            value: value,
            onChanged: onChanged,
            min: min,
            max: max,
            divisions: divisions,
            label: value.toStringAsFixed(2),
          ),
        ],
      ),
    );
  }
}

class _FilterItem extends StatelessWidget {
  final ImageFilter filter;
  final bool isSelected;
  final Uint8List imageBytes;
  final VoidCallback onTap;

  const _FilterItem({
    required this.filter,
    required this.isSelected,
    required this.imageBytes,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.secondary
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: FutureBuilder<Uint8List>(
                future: _applyFilterPreview(imageBytes, filter),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return InkWell(
                      onTap: onTap,
                      child: Image.memory(
                        snapshot.data!,
                        fit: BoxFit.cover,
                        gaplessPlayback: true,
                      ),
                    );
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            filter.name.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              color: isSelected
                  ? Theme.of(context).colorScheme.secondary
                  : Colors.white70,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Future<Uint8List> _applyFilterPreview(
      Uint8List imageBytes, ImageFilter filter) async {
    final originalImage = img.decodeImage(imageBytes);
    if (originalImage == null) return imageBytes;

    // Create a smaller version for the preview
    final resizedImage = img.copyResize(originalImage, width: 100);

    // Apply the filter to the resized image
    img.Image filteredImage = img.Image.from(resizedImage);

    switch (filter) {
      case ImageFilter.blackAndWhite:
        img.grayscale(filteredImage);
        break;
      case ImageFilter.sepia:
        for (int x = 0; x < filteredImage.width; x++) {
          for (int y = 0; y < filteredImage.height; y++) {
            final pixel = filteredImage.getPixel(x, y);
            final r = pixel.r;
            final g = pixel.g;
            final b = pixel.b;

            final tr =
                (0.393 * r + 0.769 * g + 0.189 * b).clamp(0, 255).toInt();
            final tg =
                (0.349 * r + 0.686 * g + 0.168 * b).clamp(0, 255).toInt();
            final tb =
                (0.272 * r + 0.534 * g + 0.131 * b).clamp(0, 255).toInt();

            filteredImage.setPixel(x, y, img.ColorRgb8(tr, tg, tb));
          }
        }
        break;
      case ImageFilter.vintage:
        for (int x = 0; x < filteredImage.width; x++) {
          for (int y = 0; y < filteredImage.height; y++) {
            final pixel = filteredImage.getPixel(x, y);
            final r = (pixel.r * 0.9).clamp(0, 255).toInt();
            final g = (pixel.g * 0.8).clamp(0, 255).toInt();
            final b = (pixel.b * 0.6).clamp(0, 255).toInt();
            filteredImage.setPixel(x, y, img.ColorRgb8(r, g, b));
          }
        }
        break;
      case ImageFilter.dramatic:
        for (int x = 0; x < filteredImage.width; x++) {
          for (int y = 0; y < filteredImage.height; y++) {
            final pixel = filteredImage.getPixel(x, y);
            final r = ((pixel.r - 128) * 1.5 + 128).clamp(0, 255).toInt();
            final g = ((pixel.g - 128) * 1.5 + 128).clamp(0, 255).toInt();
            final b = ((pixel.b - 128) * 1.5 + 128).clamp(0, 255).toInt();
            filteredImage.setPixel(x, y, img.ColorRgb8(r, g, b));
          }
        }
        break;
      case ImageFilter.moody:
        for (int x = 0; x < filteredImage.width; x++) {
          for (int y = 0; y < filteredImage.height; y++) {
            final pixel = filteredImage.getPixel(x, y);
            final r = (pixel.r * 0.7).clamp(0, 255).toInt();
            final g = (pixel.g * 0.7).clamp(0, 255).toInt();
            final b = (pixel.b * 0.9).clamp(0, 255).toInt();
            filteredImage.setPixel(x, y, img.ColorRgb8(r, g, b));
          }
        }
        break;
      case ImageFilter.cool:
        for (int x = 0; x < filteredImage.width; x++) {
          for (int y = 0; y < filteredImage.height; y++) {
            final pixel = filteredImage.getPixel(x, y);
            final r = (pixel.r * 0.8).clamp(0, 255).toInt();
            final g = (pixel.g * 0.9).clamp(0, 255).toInt();
            final b = pixel.b.toInt();
            filteredImage.setPixel(x, y, img.ColorRgb8(r, g, b));
          }
        }
        break;
      case ImageFilter.warm:
        for (int x = 0; x < filteredImage.width; x++) {
          for (int y = 0; y < filteredImage.height; y++) {
            final pixel = filteredImage.getPixel(x, y);
            final r = pixel.r.toInt();
            final g = (pixel.g * 0.9).clamp(0, 255).toInt();
            final b = (pixel.b * 0.8).clamp(0, 255).toInt();
            filteredImage.setPixel(x, y, img.ColorRgb8(r, g, b));
          }
        }
        break;
      case ImageFilter.original:
        break;
    }

    return Uint8List.fromList(img.encodePng(filteredImage));
  }
}

enum ImageFilter {
  original,
  blackAndWhite,
  sepia,
  vintage,
  dramatic,
  moody,
  cool,
  warm
}

// Utility function to get download directory
Future<Directory> getDownloadDirectory() async {
  if (Platform.isAndroid) {
    return Directory('/storage/emulated/0/Download');
  } else if (Platform.isIOS) {
    final directory = await getApplicationDocumentsDirectory();
    return directory;
  } else {
    final directory = await getDownloadsDirectory();
    return directory!;
  }
}
