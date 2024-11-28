import 'dart:convert';
import 'package:http/http.dart' as http;

class DeeplApiService {
  final String _baseUrl = "https://api-free.deepl.com/v2/translate";
  final String _authKey = "76bd4b61-320d-4f29-b9b7-b54daaa7a049:fx";

  Future<String> translateText(String text, String targetLang) async {
    final uri = Uri.parse(_baseUrl);
    final response = await http.post(
      uri,
      headers: {
        "Authorization": "DeepL-Auth-Key $_authKey",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "text": [text],
        "target_lang": targetLang,
      }),
    );

    if (response.statusCode == 200) {
      // Decode response body as UTF-8
      final decodedResponse = utf8.decode(response.bodyBytes);
      final jsonResponse = jsonDecode(decodedResponse);

      // Access the translated text
      return jsonResponse['translations'][0]['text'];
    } else {
      // Handle errors and log for debugging
      final decodedError = utf8.decode(response.bodyBytes);
      throw Exception("Failed to translate: $decodedError");
    }
  }
}
