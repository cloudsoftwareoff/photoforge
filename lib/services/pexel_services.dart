import 'dart:convert';
import 'package:http/http.dart' as http;

class PexelsService {
  static const String _apiKey =
      "mDjhVzh0uFAoHKaw3jdIAQzx4amAMr5cRAe79IBvuhvi3AB8SVZLIWtV";
  static const String _baseUrl = "https://api.pexels.com/v1";

  static Future<String> searchImage(String query) async {
    final response = await http.get(
      Uri.parse("$_baseUrl/search?query=$query&per_page=1"),
      headers: {"Authorization": _apiKey},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['photos'][0]['src']['large']; // Returns image URL
    } else {
      throw Exception('Failed to load image: ${response.statusCode}');
    }
  }
}
