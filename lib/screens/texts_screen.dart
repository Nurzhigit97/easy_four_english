import 'package:flutter/material.dart';
import '../models/text_model.dart';
import '../database/database_helper.dart';
import '../widgets/text_card.dart';
import '../widgets/add_edit_text_dialog.dart';
import 'text_detail_screen.dart';

class TextsScreen extends StatefulWidget {
  const TextsScreen({super.key});

  @override
  State<TextsScreen> createState() => TextsScreenState();
}

class TextsScreenState extends State<TextsScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<TextModel> _texts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTexts();
  }

  Future<void> _loadTexts() async {
    setState(() => _isLoading = true);
    final texts = await _dbHelper.getAllTexts();
    setState(() {
      _texts = texts;
      _isLoading = false;
    });
  }

  void addText() => _addText();

  Future<void> _addText() async {
    final result = await showDialog<TextModel>(
      context: context,
      builder: (context) => const AddEditTextDialog(),
    );

    if (result != null) {
      await _dbHelper.insertText(result);
      _loadTexts();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Текст успешно добавлен')));
      }
    }
  }

  Future<void> _editText(TextModel text) async {
    final result = await showDialog<TextModel>(
      context: context,
      builder: (context) => AddEditTextDialog(text: text),
    );

    if (result != null) {
      await _dbHelper.updateText(result);
      _loadTexts();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Текст успешно обновлен')));
      }
    }
  }

  Future<void> _deleteText(TextModel text) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить текст?'),
        content: Text('Вы уверены, что хотите удалить "${text.title}"?'),
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

    if (confirm == true && text.id != null) {
      await _dbHelper.deleteText(text.id!);
      _loadTexts();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Текст успешно удален')));
      }
    }
  }

  void _navigateToDetail(TextModel text) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(builder: (context) => TextDetailScreen(text: text)),
        )
        .then((_) => _loadTexts());
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_texts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_book, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Нет текстов',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Нажмите + чтобы добавить первый текст',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTexts,
      child: ListView.builder(
        itemCount: _texts.length,
        itemBuilder: (context, index) {
          final text = _texts[index];
          return TextCard(
            text: text,
            onTap: () => _navigateToDetail(text),
            onEdit: () => _editText(text),
            onDelete: () => _deleteText(text),
          );
        },
      ),
    );
  }
}
