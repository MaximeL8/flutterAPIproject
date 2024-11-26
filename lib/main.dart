import 'package:flutter/material.dart';
import 'deeplapi.dart';

void main() {
  runApp(TranslationApp());
}

class TranslationApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TranslationScreen(),
    );
  }
}

class TranslationScreen extends StatefulWidget {
  @override
  _TranslationScreenState createState() => _TranslationScreenState();
}

class _TranslationScreenState extends State<TranslationScreen> {
  final TextEditingController _inputController = TextEditingController();
  String _outputText = "Traduction";
  String _sourceLang = "FR";
  String _targetLang = "EN";

  final List<String> _languages = ["FR", "EN", "BR", "ES", "DE"];

  final DeeplApiService _deeplApiService = DeeplApiService();

  void _swapLanguages() {
    setState(() {
      final temp = _sourceLang;
      _sourceLang = _targetLang;
      _targetLang = temp;
      _outputText = ""; // Efface le texte traduit lorsqu'on échange les langues.
    });
  }

  Future<void> _translateText() async {
    try {
      final translation = await _deeplApiService.translateText(
        _inputController.text,
        _targetLang,
      );
      setState(() {
        _outputText = translation;
      });
    } catch (e) {
      setState(() {
        _outputText = "Erreur : ${e.toString()}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Traducteur"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sélecteurs de langue
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  value: _sourceLang,
                  items: _languages
                      .map((lang) =>
                          DropdownMenuItem(value: lang, child: Text(lang)))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _sourceLang = value!;
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.swap_horiz),
                  onPressed: _swapLanguages,
                ),
                DropdownButton<String>(
                  value: _targetLang,
                  items: _languages
                      .map((lang) =>
                          DropdownMenuItem(value: lang, child: Text(lang)))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _targetLang = value!;
                    });
                  },
                ),
              ],
            ),

            SizedBox(height: 16),

            // Zone de texte d'entrée
            Expanded(
              child: TextField(
                controller: _inputController,
                maxLines: null,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Saisissez votre texte",
                  alignLabelWithHint: true,
                ),
              ),
            ),

            SizedBox(height: 16),

            ElevatedButton(
              onPressed: _translateText,
              child: Text("Traduire"),
            ),

            SizedBox(height: 16),

            // Zone de texte de sortie
            Expanded(
              child: Container(
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Text(
                  _outputText,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
