import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

/// Client for calling the external inference backend hosted on Hugging Face.
class InferenceService {
  static const String _baseUrl = 'https://simo2valid-frontend-cnn.hf.space';

  /// Sends a recorded video to the backend and returns the translation.
  /// Throws on network or server error.
  static Future<String> translateVideo(File videoFile) async {
    // Try Gradio API endpoint
    final uri = Uri.parse('$_baseUrl/api/predict');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('file', videoFile.path));

    try {
      final response = await http.Response.fromStream(await request.send());

      if (response.statusCode == 200) {
        final translation = _parseTranslation(response.body);
        if (translation != null) return translation;
      }
    } catch (_) {
      // If first endpoint fails, try alternative
    }

    // Try alternative endpoint structure
    final altUri = Uri.parse('$_baseUrl/run/predict');
    final altRequest = http.MultipartRequest('POST', altUri)
      ..files.add(await http.MultipartFile.fromPath('file', videoFile.path));

    final altResponse = await http.Response.fromStream(await altRequest.send());

    if (altResponse.statusCode == 200) {
      final translation = _parseTranslation(altResponse.body);
      return translation ?? 'Unknown';
    }

    throw Exception(
        'Inference failed: ${altResponse.statusCode} ${altResponse.reasonPhrase}');
  }

  static String? _parseTranslation(String body) {
    try {
      final decoded = jsonDecode(body) as Map<String, dynamic>;

      // Try various response formats
      if (decoded['translation'] is String) {
        return decoded['translation'] as String;
      }
      if (decoded['data'] is List && (decoded['data'] as List).isNotEmpty) {
        return (decoded['data'] as List).first.toString();
      }
      if (decoded['prediction'] is String) {
        return decoded['prediction'] as String;
      }
      if (decoded['output'] is String) {
        return decoded['output'] as String;
      }
    } catch (_) {
      // ignore parse errors
    }
    return null;
  }
}
