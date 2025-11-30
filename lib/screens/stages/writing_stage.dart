import 'package:flutter/material.dart';
import '../../models/text_model.dart';

class WritingStage extends StatefulWidget {
  final TextModel text;

  const WritingStage({
    super.key,
    required this.text,
  });

  @override
  State<WritingStage> createState() => _WritingStageState();
}

class _WritingStageState extends State<WritingStage> {
  final TextEditingController _writingController = TextEditingController();

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
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
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
                onPressed: () {
                  if (_writingController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Пожалуйста, введите текст'),
                      ),
                    );
                    return;
                  }
                  // TODO: Save writing
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Текст сохранен'),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Сохранить текст'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

