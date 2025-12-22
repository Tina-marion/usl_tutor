import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

/// Client for calling the external inference backend hosted on Render.
class InferenceService {
  static const String _baseUrl = 'https://cnn-backend-604g.onrender.com';

  /// Sends a recorded video to the backend and returns the translation.
  /// Throws on network or server error.
  static Future<String> translateVideo(File videoFile) async {
    final uri = Uri.parse('$_baseUrl/predict');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('file', videoFile.path));

    final response = await http.Response.fromStream(await request.send());

    if (response.statusCode == 200) {
      final translation = _parseTranslation(response.body);
      return translation ?? 'Unknown';
    }

    throw Exception(
        'Inference failed: ${response.statusCode} ${response.reasonPhrase}');
  }

  static String? _parseTranslation(String body) {
    try {
      final decoded = jsonDecode(body) as Map<String, dynamic>;
      final translation = decoded['translation'];
      if (translation is String) return translation;
    } catch (_) {
      // ignore parse errors
    }
    return null;
  }
}
