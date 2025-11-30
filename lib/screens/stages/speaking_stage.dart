import 'package:flutter/material.dart';
import '../../models/text_model.dart';
import '../../database/database_helper.dart';
import '../../models/speaking_answer_model.dart';

class SpeakingStage extends StatefulWidget {
  final TextModel text;

  const SpeakingStage({super.key, required this.text});

  @override
  State<SpeakingStage> createState() => _SpeakingStageState();
}

class _SpeakingStageState extends State<SpeakingStage> {
  final TextEditingController _answerController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  bool _isRecording = false;
  List<SpeakingAnswerModel> _previousAnswers = [];

  @override
  void initState() {
    super.initState();
    _loadPreviousAnswers();
  }

  Future<void> _loadPreviousAnswers() async {
    if (widget.text.id == null) return;
    final answers = await _dbHelper.getSpeakingAnswersByTextId(widget.text.id!);
    setState(() {
      _previousAnswers = answers;
    });
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Speaking'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.mic, color: Colors.orange, size: 32),
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
                            'Что вы поняли из текста?',
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
              'Опишите своими словами, что вы поняли:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _answerController,
                  maxLines: 10,
                  decoration: const InputDecoration(
                    hintText: 'Введите ваш ответ здесь...',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isRecording = !_isRecording;
                    });
                    // TODO: Implement voice recording
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Функция записи голоса будет реализована позже',
                        ),
                      ),
                    );
                  },
                  icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                  label: Text(_isRecording ? 'Остановить' : 'Записать голос'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (_answerController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Пожалуйста, введите ответ'),
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

                  final answer = SpeakingAnswerModel(
                    textId: widget.text.id!,
                    answer: _answerController.text.trim(),
                  );

                  await _dbHelper.insertSpeakingAnswer(answer);
                  _answerController.clear();
                  _loadPreviousAnswers();

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ответ сохранен')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Сохранить ответ'),
              ),
            ),
            if (_previousAnswers.isNotEmpty) ...[
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.history, color: Colors.orange),
                  const SizedBox(width: 8),
                  Text(
                    'Предыдущие ответы (${_previousAnswers.length})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ..._previousAnswers.map(
                (answer) => Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(
                      answer.answer,
                      style: const TextStyle(fontSize: 14),
                    ),
                    subtitle: Text(
                      '${answer.createdAt.day}.${answer.createdAt.month}.${answer.createdAt.year} ${answer.createdAt.hour}:${answer.createdAt.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        if (answer.id != null) {
                          await _dbHelper.deleteSpeakingAnswer(answer.id!);
                          _loadPreviousAnswers();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Ответ удален')),
                            );
                          }
                        }
                      },
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
