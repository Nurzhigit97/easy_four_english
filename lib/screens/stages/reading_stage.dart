import 'package:flutter/material.dart';
import '../../models/text_model.dart';
import '../../models/dictionary_model.dart';
import '../../models/word_model.dart';
import '../../database/database_helper.dart';

class ReadingStage extends StatefulWidget {
  final TextModel text;

  const ReadingStage({super.key, required this.text});

  @override
  State<ReadingStage> createState() => _ReadingStageState();
}

class _ReadingStageState extends State<ReadingStage> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<String> _selectedWords = [];

  void _removeWord(String word) {
    setState(() {
      _selectedWords.remove(word);
    });
  }

  Future<void> _showSelectedTextDialog(String selectedText) async {
    await showDialog(
      context: context,
      builder: (context) => _SelectedTextDialog(
        selectedText: selectedText,
        onAddToList: (text) {
          if (text.isNotEmpty && !_selectedWords.contains(text)) {
            setState(() {
              _selectedWords.add(text);
            });
            Navigator.of(context).pop();
          }
        },
        onAddToDictionary: (text) async {
          if (text.isNotEmpty) {
            // Добавляем в список, если еще не добавлено
            if (!_selectedWords.contains(text)) {
              setState(() {
                _selectedWords.add(text);
              });
            }
            Navigator.of(context).pop();
            // Сразу открываем диалог сохранения
            await _saveWordsToDictionary();
          }
        },
      ),
    );
  }

  Future<void> _saveWordsToDictionary() async {
    if (_selectedWords.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Выберите слова для сохранения')),
      );
      return;
    }

    if (!mounted) return;

    // Используем название текста как название словаря
    final dictionaryTitle = widget.text.title;

    // Проверяем, существует ли словарь с таким названием
    DictionaryModel? dictionary = await _dbHelper.getDictionaryByTitle(
      dictionaryTitle,
    );

    // Если словарь не существует, создаем его
    if (dictionary == null) {
      final newDictionary = DictionaryModel(title: dictionaryTitle);
      final dictionaryId = await _dbHelper.insertDictionary(newDictionary);
      dictionary = newDictionary.copyWith(id: dictionaryId);
    }

    // Создаем слова для сохранения
    final words = _selectedWords.map((word) {
      return WordModel(
        dictionaryId: dictionary!.id!,
        word: word,
        context: widget.text.content,
      );
    }).toList();

    await _dbHelper.insertWords(words);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${_selectedWords.length} слов(а) сохранено в словарь "${dictionary.title}"',
          ),
        ),
      );
      setState(() {
        _selectedWords.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reading'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          if (_selectedWords.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.bookmark_add),
              tooltip: 'Сохранить в словарь',
              onPressed: _saveWordsToDictionary,
            ),
        ],
      ),
      body: Column(
        children: [
          // Выбранные слова
          if (_selectedWords.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.blue.shade50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Выбранные слова:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _selectedWords.map((word) {
                      return Chip(
                        label: Text(word),
                        onDeleted: () => _removeWord(word),
                        deleteIcon: const Icon(Icons.close, size: 18),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          // Текст для чтения
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.menu_book,
                            color: Colors.blue,
                            size: 32,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.text.title,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Выделите слова для добавления в словарь',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Текст для чтения:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: SelectableText(
                        widget.text.content,
                        style: const TextStyle(fontSize: 16, height: 1.6),
                        onSelectionChanged: (selection, cause) async {
                          if (selection.isValid && !selection.isCollapsed) {
                            // Пользователь выделил новый текст
                            final selectedText = widget.text.content
                                .substring(selection.start, selection.end)
                                .trim();
                            if (selectedText.isNotEmpty) {
                              // Показываем диалог с выбранным текстом
                              await _showSelectedTextDialog(selectedText);
                            }
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectedTextDialog extends StatelessWidget {
  final String selectedText;
  final Function(String) onAddToList;
  final Function(String) onAddToDictionary;

  const _SelectedTextDialog({
    required this.selectedText,
    required this.onAddToList,
    required this.onAddToDictionary,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.text_fields, color: Colors.green, size: 24),
          const SizedBox(width: 8),
          const Text(
            'Выбрано:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.maxFinite,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Text(
              selectedText,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () => onAddToList(selectedText),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('В список'),
                style: OutlinedButton.styleFrom(foregroundColor: Colors.green),
              ),
              ElevatedButton.icon(
                onPressed: () => onAddToDictionary(selectedText),
                icon: const Icon(Icons.bookmark_add, size: 18),
                label: const Text('В словарь'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DictionarySelectionDialog extends StatefulWidget {
  final List<DictionaryModel> dictionaries;

  const _DictionarySelectionDialog({required this.dictionaries});

  @override
  State<_DictionarySelectionDialog> createState() =>
      _DictionarySelectionDialogState();
}

class _DictionarySelectionDialogState
    extends State<_DictionarySelectionDialog> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final TextEditingController _titleController = TextEditingController();
  bool _isCreatingNew = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _createNewDictionary() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Введите название словаря')));
      return;
    }

    final dictionary = DictionaryModel(title: _titleController.text.trim());
    final id = await _dbHelper.insertDictionary(dictionary);
    final newDictionary = dictionary.copyWith(id: id);

    if (mounted) {
      Navigator.of(context).pop(newDictionary);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Выберите словарь'),
      content: SizedBox(
        width: double.maxFinite,
        child: _isCreatingNew
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Название словаря',
                      border: OutlineInputBorder(),
                    ),
                    autofocus: true,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isCreatingNew = false;
                            _titleController.clear();
                          });
                        },
                        child: const Text('Отмена'),
                      ),
                      ElevatedButton(
                        onPressed: _createNewDictionary,
                        child: const Text('Создать'),
                      ),
                    ],
                  ),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.dictionaries.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Нет словарей. Создайте новый.'),
                    )
                  else
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        itemCount: widget.dictionaries.length,
                        itemBuilder: (context, index) {
                          final dict = widget.dictionaries[index];
                          return ListTile(
                            leading: const Icon(Icons.book),
                            title: Text(dict.title),
                            onTap: () => Navigator.of(context).pop(dict),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _isCreatingNew = true;
                      });
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Создать новый словарь'),
                  ),
                ],
              ),
      ),
    );
  }
}
