enum ImageFilter {
  original,
  blackAndWhite,
  sepia,
  vintage,
  dramatic,
  moody,
  cool,
  warm;

  String get name {
    switch (this) {
      case ImageFilter.blackAndWhite:
        return 'B&W';
      case ImageFilter.sepia:
        return 'Sepia';
      case ImageFilter.vintage:
        return 'Vintage';
      case ImageFilter.dramatic:
        return 'Dramatic';
      case ImageFilter.moody:
        return 'Moody';
      case ImageFilter.cool:
        return 'Cool';
      case ImageFilter.warm:
        return 'Warm';
      case ImageFilter.original:
        return 'Original';
    }
  }
}