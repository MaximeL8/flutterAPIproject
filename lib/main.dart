import 'package:flutter/material.dart';
import 'deeplapi.dart';

void main() {
  runApp(const TranslationApp());
}

class TranslationApp extends StatelessWidget {
  const TranslationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TranslationScreen(),
    );
  }
}

class TranslationScreen extends StatefulWidget {
  const TranslationScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TranslationScreenState createState() => _TranslationScreenState();
}

class TranslationHistory {
  final String inputText;
  final String outputText;
  final String sourceLang;
  final String targetLang;
  final DateTime timestamp;

  TranslationHistory({
    required this.inputText,
    required this.outputText,
    required this.sourceLang,
    required this.targetLang,
    required this.timestamp,
  });
}

class _TranslationScreenState extends State<TranslationScreen> {
  final TextEditingController _inputController = TextEditingController();
  String _outputText = "Traduction";
  String _sourceLang = "FR";
  String _targetLang = "EN";

  List<String> _languages = [];
  final DeeplApiService _deeplApiService = DeeplApiService();
  List<TranslationHistory> _history = [];

  @override
  void initState() {
    super.initState();
    _loadLanguages();
  }

  Future<void> _loadLanguages() async {
    try {
      final languages = await _deeplApiService.getSupportedLanguages();
      setState(() {
        _languages = languages;
        _sourceLang = languages.contains("FR") ? "FR" : languages.first;
        _targetLang = languages.contains("EN") ? "EN" : languages.first;
      });
    } catch (e) {
      setState(() {
        _outputText = "Erreur : Impossible de charger les langues.";
      });
    }
  }

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
        _history.insert(0, TranslationHistory(
        inputText: _inputController.text,
        outputText: translation,
        sourceLang: _sourceLang,
        targetLang: _targetLang,
        timestamp: DateTime.now(),
        ));
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
        title: const Text("Traducteur"),
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
                  value: _languages.isEmpty ? null : _sourceLang,
                  items: _languages
                      .map((lang) => DropdownMenuItem(value: lang, child: Text(lang)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _sourceLang = value;
                      });
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.swap_horiz),
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

            const SizedBox(height: 16),
            
            // Zone de texte d'entrée
            
            Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _inputController,
                        maxLines: null,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Saisissez votre texte",
                          alignLabelWithHint: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    

                    const SizedBox(height: 16),


            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Text(
                  _outputText,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            

            const SizedBox(height: 16),
                  ],
                ),
            
            const SizedBox(height: 16),

            Expanded(
              child: ListView.builder(
                itemCount: _history.length,
                itemBuilder: (context, index) {
                  final item = _history[index];
                  return ListTile(
                    title: Text("${item.inputText} → ${item.outputText}"),
                    subtitle: Text("From ${item.sourceLang} to ${item.targetLang}"),
                    trailing: Text(
                      "${item.timestamp.hour}:${item.timestamp.minute} ${item.timestamp.day}/${item.timestamp.month}/${item.timestamp.year}",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  );
                },
              ),
              
            ),
            // Conditional Clear History Button
            if (_history.isNotEmpty)
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _history.clear();
                  });
                },
                child: const Text("Effacer l'historique"),
              ),




            // Zone de texte de sortie
            ElevatedButton(
              onPressed: _translateText,
              child: const Text("Traduire"),
            ),
          ],
        ),
      ),
    );
  }
}
