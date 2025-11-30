import 'package:flutter/material.dart';
import '../../models/text_model.dart';
import '../../database/database_helper.dart';
import '../../models/writing_answer_model.dart';

class WritingStage extends StatefulWidget {
  final TextModel text;

  const WritingStage({super.key, required this.text});

  @override
  State<WritingStage> createState() => _WritingStageState();
}

class _WritingStageState extends State<WritingStage> {
  final TextEditingController _writingController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<WritingAnswerModel> _previousWritings = [];

  @override
  void initState() {
    super.initState();
    _loadPreviousWritings();
  }

  Future<void> _loadPreviousWritings() async {
    if (widget.text.id == null) return;
    final writings = await _dbHelper.getWritingAnswersByTextId(widget.text.id!);
    setState(() {
      _previousWritings = writings;
    });
  }

  @override
  void dispose() {
    _writingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Writing'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Colors.purple.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.edit, color: Colors.purple, size: 32),
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
                            'Напишите сочинение или пересказ',
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
              'Напишите ваш текст:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _writingController,
                  maxLines: 15,
                  decoration: const InputDecoration(
                    hintText: 'Начните писать здесь...',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (_writingController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Пожалуйста, введите текст'),
                      ),
                    );
                    return;
                  }
                  if (widget.text.id == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ошибка: текст не найден')),
                    );
                    return;
                  }

                  final writing = WritingAnswerModel(
                    textId: widget.text.id!,
                    writing: _writingController.text.trim(),
                  );

                  await _dbHelper.insertWritingAnswer(writing);
                  _writingController.clear();
                  _loadPreviousWritings();

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Текст сохранен')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Сохранить текст'),
              ),
            ),
            if (_previousWritings.isNotEmpty) ...[
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.history, color: Colors.purple),
                  const SizedBox(width: 8),
                  Text(
                    'Предыдущие тексты (${_previousWritings.length})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ..._previousWritings.map(
                (writing) => Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${writing.createdAt.day}.${writing.createdAt.month}.${writing.createdAt.year} ${writing.createdAt.hour}:${writing.createdAt.minute.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                if (writing.id != null) {
                                  await _dbHelper.deleteWritingAnswer(
                                    writing.id!,
                                  );
                                  _loadPreviousWritings();
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Текст удален'),
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          writing.writing,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
