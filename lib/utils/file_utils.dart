import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

Future<String> saveImageToGallery(Uint8List imageBytes) async {
  final directory = await getDownloadDirectory();
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final file = File('${directory.path}/edited_image_$timestamp.png');
  await file.writeAsBytes(imageBytes);
  return file.path;
}

Future<Directory> getDownloadDirectory() async {
  if (Platform.isAndroid) {
    return Directory('/storage/emulated/0/Download');
  } else if (Platform.isIOS) {
    return await getApplicationDocumentsDirectory();
  }
  return (await getDownloadsDirectory())!;
}