import 'dart:math' as math;
import 'package:image/image.dart' as img;

List<double> rgbToHsl(int r, int g, int b) {
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

List<int> hslToRgb(double h, double s, double l) {
  double r, g, b;

  if (s == 0.0) {
    r = g = b = l;
  } else {
    final q = l < 0.5 ? l * (1.0 + s) : l + s - l * s;
    final p = 2.0 * l - q;

    r = hueToRgb(p, q, h + 1.0 / 3.0);
    g = hueToRgb(p, q, h);
    b = hueToRgb(p, q, h - 1.0 / 3.0);
  }

  return [
    (r * 255).round().clamp(0, 255),
    (g * 255).round().clamp(0, 255),
    (b * 255).round().clamp(0, 255)
  ];
}

double hueToRgb(double p, double q, double t) {
  if (t < 0.0) t += 1.0;
  if (t > 1.0) t -= 1.0;
  if (t < 1.0 / 6.0) return p + (q - p) * 6.0 * t;
  if (t < 1.0 / 2.0) return q;
  if (t < 2.0 / 3.0) return p + (q - p) * (2.0 / 3.0 - t) * 6.0;
  return p;
}