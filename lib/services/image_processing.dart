import 'dart:typed_data';
import 'package:image/image.dart' as img;
import '../models/image_filter.dart';
import '../utils/image_utils.dart' as utils;
import 'dart:math' as math;

Uint8List processImage(
  Uint8List imageBytes, {
  required ImageFilter filter,
  double brightness = 0.0,
  double contrast = 1.0,
  double saturation = 1.0,
  double warmth = 0.0,
  double vignette = 0.0,
}) {
  final originalImage = img.decodeImage(imageBytes);
  if (originalImage == null) return imageBytes;

  img.Image image = img.Image.from(originalImage);

  // Apply base filter
  switch (filter) {
    case ImageFilter.blackAndWhite:
      img.grayscale(image);
      break;
    case ImageFilter.sepia:
      applySepia(image);
      break;
    case ImageFilter.vintage:
      applyVintage(image);
      break;
    case ImageFilter.dramatic:
      applyDramatic(image);
      break;
    case ImageFilter.moody:
      applyMoody(image);
      break;
    case ImageFilter.cool:
      applyCool(image);
      break;
    case ImageFilter.warm:
      applyWarm(image);
      break;
    case ImageFilter.original:
      break;
  }

  applyBrightnessContrast(image, brightness, contrast);
  applySaturation(image, saturation);
  applyWarmth(image, warmth);
  if (vignette > 0) applyVignette(image, vignette);

  return Uint8List.fromList(img.encodePng(image));
}

Future<Uint8List> applyFilterPreview(
    Uint8List imageBytes, ImageFilter filter) async {
  final originalImage = img.decodeImage(imageBytes);
  if (originalImage == null) return imageBytes;

  final resizedImage = img.copyResize(originalImage, width: 100);
  img.Image filteredImage = img.Image.from(resizedImage);

  switch (filter) {
    case ImageFilter.blackAndWhite:
      img.grayscale(filteredImage);
      break;
    case ImageFilter.sepia:
      applySepia(filteredImage);
      break;
    case ImageFilter.vintage:
      applyVintage(filteredImage);
      break;
    case ImageFilter.dramatic:
      applyDramatic(filteredImage);
      break;
    case ImageFilter.moody:
      applyMoody(filteredImage);
      break;
    case ImageFilter.cool:
      applyCool(filteredImage);
      break;
    case ImageFilter.warm:
      applyWarm(filteredImage);
      break;
    case ImageFilter.original:
      break;
  }

  return Future.value(Uint8List.fromList(img.encodePng(filteredImage)));
}

void applySepia(img.Image image) {
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

void applyVintage(img.Image image) {
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

void applyDramatic(img.Image image) {
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

void applyMoody(img.Image image) {
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

void applyCool(img.Image image) {
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

void applyWarm(img.Image image) {
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

void applyBrightnessContrast(
    img.Image image, double brightness, double contrast) {
  final brightnessAmount = (brightness * 255).toInt();
  final contrastAmount = contrast;

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

void applySaturation(img.Image image, double saturation) {
  if (saturation == 1.0) return;

  for (int x = 0; x < image.width; x++) {
    for (int y = 0; y < image.height; y++) {
      final pixel = image.getPixel(x, y);
      final hsl =
          utils.rgbToHsl(pixel.r.toInt(), pixel.g.toInt(), pixel.b.toInt());
      final s = (hsl[1] * saturation).clamp(0.0, 1.0);
      final rgb = utils.hslToRgb(hsl[0], s, hsl[2]);
      image.setPixel(x, y, img.ColorRgb8(rgb[0], rgb[1], rgb[2]));
    }
  }
}

void applyWarmth(img.Image image, double warmth) {
  if (warmth == 0.0) return;

  for (int x = 0; x < image.width; x++) {
    for (int y = 0; y < image.height; y++) {
      final pixel = image.getPixel(x, y);
      int r = pixel.r.toInt();
      int b = pixel.b.toInt();

      if (warmth > 0) {
        r = (r + warmth * 50).clamp(0, 255).toInt();
        b = (b - warmth * 30).clamp(0, 255).toInt();
      } else {
        r = (r + warmth * 30).clamp(0, 255).toInt();
        b = (b - warmth * 50).clamp(0, 255).toInt();
      }

      image.setPixel(x, y, img.ColorRgb8(r, pixel.g.toInt(), b));
    }
  }
}

void applyVignette(img.Image image, double strength) {
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
