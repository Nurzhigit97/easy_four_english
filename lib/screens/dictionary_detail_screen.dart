import 'package:flutter/material.dart';
import 'package:translator/translator.dart';
import '../models/dictionary_model.dart';
import '../models/word_model.dart';
import '../database/database_helper.dart';

class DictionaryDetailScreen extends StatefulWidget {
  final DictionaryModel dictionary;

  const DictionaryDetailScreen({super.key, required this.dictionary});

  @override
  State<DictionaryDetailScreen> createState() => _DictionaryDetailScreenState();
}

class _DictionaryDetailScreenState extends State<DictionaryDetailScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final GoogleTranslator _translator = GoogleTranslator();
  List<WordModel> _words = [];
  bool _isLoading = true;
  String? _selectedWord;
  Map<String, String> _translatedWords = {}; // Кэш для переведенных значений

  @override
  void initState() {
    super.initState();
    _loadAndTranslateWords();
  }

  Future<void> _loadAndTranslateWords() async {
    final words = await _dbHelper.getWordsByDictionaryId(widget.dictionary.id!);
    final translationFutures = words.map((word) async {
      final translated = await _translateWord(word.word, 'ru');
      return {word.word: translated};
    });
    final translatedMap = await Future.wait(translationFutures);
    setState(() {
      _words = words;
      _translatedWords = translatedMap.fold(
        {},
        (map, entry) => map..addAll(entry),
      );
      _isLoading = false;
    });
  }

  Future<String> _translateWord(String word, String targetLanguage) async {
    try {
      final translation = await _translator.translate(
        word,
        from: 'en',
        to: targetLanguage,
      );
      return translation.text;
    } catch (e) {
      // В случае ошибки возвращаем исходный текст
      return word;
    }
  }

  Future<void> _deleteWord(WordModel word) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить слово?'),
        content: Text('Вы уверены, что хотите удалить "${word.word}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirm == true && word.id != null) {
      await _dbHelper.deleteWord(word.id!);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Слово удалено')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.dictionary.title),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _words.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.book_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Словарь пуст',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Добавьте слова из текстов',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadAndTranslateWords,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _words.length,
                itemBuilder: (context, index) {
                  final word = _words[index];
                  final isSelected = _selectedWord == word.word;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: isSelected ? 4 : 2,
                    color: isSelected ? Colors.blue.shade50 : null,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedWord = isSelected ? null : word.word;
                        });
                      },
                      onLongPress: () {
                        // _addWordToDictionary(word.word);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                      children: [
                                        TextSpan(text: word.word),
                                        if (_translatedWords[word.word] !=
                                            null) ...[
                                          const TextSpan(
                                            text: ' - ',
                                            style: TextStyle(
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                          TextSpan(
                                            text: _translatedWords[word.word]!,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.normal,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                                // if (isSelected)
                                //   IconButton(
                                //     icon: const Icon(
                                //       Icons.bookmark_add,
                                //       color: Colors.blue,
                                //     ),
                                //     tooltip: 'Добавить в другой словарь',
                                //     onPressed: () =>
                                //         // _addWordToDictionary(word.word),
                                //   ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                  ),
                                  tooltip: 'Удалить',
                                  onPressed: () => _deleteWord(word),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

class _DictionarySelectionDialog extends StatelessWidget {
  final List<DictionaryModel> dictionaries;
  final String title;

  const _DictionarySelectionDialog({
    required this.dictionaries,
    this.title = 'Выберите словарь',
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: double.maxFinite,
        child: dictionaries.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Нет доступных словарей'),
              )
            : SizedBox(
                height: 200,
                child: ListView.builder(
                  itemCount: dictionaries.length,
                  itemBuilder: (context, index) {
                    final dict = dictionaries[index];
                    return ListTile(
                      leading: const Icon(Icons.book),
                      title: Text(dict.title),
                      onTap: () => Navigator.of(context).pop(dict),
                    );
                  },
                ),
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
      ],
    );
  }
}
