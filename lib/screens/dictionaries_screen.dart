import 'package:flutter/material.dart';
import '../models/dictionary_model.dart';
import '../database/database_helper.dart';
import '../widgets/dictionary_card.dart';
import 'dictionary_detail_screen.dart';

class DictionariesScreen extends StatefulWidget {
  const DictionariesScreen({super.key});

  @override
  State<DictionariesScreen> createState() => DictionariesScreenState();
}

class DictionariesScreenState extends State<DictionariesScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<DictionaryModel> _dictionaries = [];
  Map<int, int> _dictionaryWordCounts = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDictionaries();
  }

  Future<void> _loadDictionaries() async {
    setState(() => _isLoading = true);
    final dictionaries = await _dbHelper.getAllDictionaries();

    // Получаем количество слов для каждого словаря
    final wordCounts = <int, int>{};
    for (final dict in dictionaries) {
      if (dict.id != null) {
        final words = await _dbHelper.getWordsByDictionaryId(dict.id!);
        wordCounts[dict.id!] = words.length;
      }
    }

    setState(() {
      _dictionaries = dictionaries;
      _dictionaryWordCounts = wordCounts;
      _isLoading = false;
    });
  }

  Future<void> _deleteDictionary(DictionaryModel dictionary) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить словарь?'),
        content: Text(
          'Вы уверены, что хотите удалить "${dictionary.title}"? Все слова в словаре также будут удалены.',
        ),
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

    if (confirm == true && dictionary.id != null) {
      await _dbHelper.deleteDictionary(dictionary.id!);
      _loadDictionaries();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Словарь удален')));
      }
    }
  }

  void _navigateToDictionary(DictionaryModel dictionary) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) =>
                DictionaryDetailScreen(dictionary: dictionary),
          ),
        )
        .then((_) => _loadDictionaries());
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_dictionaries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.book_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Нет словарей',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Словари будут создаваться автоматически\nпри сохранении слов из текстов',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDictionaries,
      child: ListView.builder(
        itemCount: _dictionaries.length,
        itemBuilder: (context, index) {
          final dictionary = _dictionaries[index];
          final wordCount = dictionary.id != null
              ? _dictionaryWordCounts[dictionary.id] ?? 0
              : 0;
          return DictionaryCard(
            dictionary: dictionary,
            wordCount: wordCount,
            onTap: () => _navigateToDictionary(dictionary),
            onDelete: () => _deleteDictionary(dictionary),
          );
        },
      ),
    );
  }
}
