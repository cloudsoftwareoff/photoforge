import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/pexel_services.dart';

class AIGeneratorScreen extends StatefulWidget {
  const AIGeneratorScreen({Key? key}) : super(key: key);

  @override
  _AIGeneratorScreenState createState() => _AIGeneratorScreenState();
}

class _AIGeneratorScreenState extends State<AIGeneratorScreen> {
  String? _generatedImageUrl;
  bool _isLoading = false;
  final _promptController = TextEditingController();

  Future<void> _generateImage() async {
    if (_promptController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _generatedImageUrl = null;
    });

    try {
      final imageUrl = await PexelsService.searchImage(_promptController.text);
      setState(() => _generatedImageUrl = imageUrl);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: _generateImage,
          ),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Style Image Generator')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _promptController,
              decoration: InputDecoration(
                labelText: 'Describe your image',
                hintText: 'e.g. "majestic mountain sunset"',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _generateImage,
                ),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 10),
                  Text('Searching Pexels...'),
                ],
              )
            else if (_generatedImageUrl != null)
              Expanded(
                child: CachedNetworkImage(
                  imageUrl: _generatedImageUrl!,
                  placeholder: (context, url) =>
                      const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                  fit: BoxFit.contain,
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }
}
