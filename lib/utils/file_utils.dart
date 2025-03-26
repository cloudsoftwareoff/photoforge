import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

Future<String> saveImageToGallery(Uint8List imageBytes) async {
  // Check and request permissions
  final status = await checkStoragePermission();
  
  if (!status) {
    throw Exception('Storage permission denied');
  }

  // Get directory
  final directory = await getDownloadDirectory();

  // Create PhotoForge subdirectory if not exists
  final saveDir = Directory('${directory.path}/PhotoForge');
  if (!await saveDir.exists()) {
    await saveDir.create(recursive: true);
  }

  // Save file
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final file = File('${saveDir.path}/edited_$timestamp.png');
  await file.writeAsBytes(imageBytes);

  // For Android: Notify gallery
  if (Platform.isAndroid) {
    await _androidScanFile(file);
  }

  return file.path;
}

Future<bool> checkStoragePermission() async {
  if (Platform.isAndroid) {
    final status = await Permission.storage.request();
    
    return status.isGranted;
  } else if (Platform.isIOS) {
    // iOS uses Photos permission for gallery access
    final status = await Permission.photos.request();
    return status.isGranted;
  }
  return true;
}

Future<Directory> getDownloadDirectory() async {
  if (Platform.isAndroid) {
    // Use Pictures directory instead of Download for better organization
    return await getExternalStorageDirectory() ??
        Directory('/storage/emulated/0/Pictures');
  } else if (Platform.isIOS) {
    return await getApplicationDocumentsDirectory();
  }
  return (await getDownloadsDirectory())!;
}

// Android specific: Make file visible in gallery
Future<void> _androidScanFile(File file) async {
  if (Platform.isAndroid) {
    await Process.run('am', [
      'broadcast',
      '-a',
      'android.intent.action.MEDIA_SCANNER_SCAN_FILE',
      '-d',
      'file://${file.path}'
    ]);
  }
}
