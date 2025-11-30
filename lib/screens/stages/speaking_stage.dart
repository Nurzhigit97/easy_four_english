import 'package:flutter/material.dart';
import '../../models/text_model.dart';
import '../../database/database_helper.dart';
import '../../models/speaking_answer_model.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class SpeakingStage extends StatefulWidget {
  final TextModel text;

  const SpeakingStage({super.key, required this.text});

  @override
  State<SpeakingStage> createState() => _SpeakingStageState();
}

class _SpeakingStageState extends State<SpeakingStage> {
  final TextEditingController _answerController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isRecording = false;
  bool _isListening = false;
  bool _speechAvailable = false;
  String _recognizedText = '';
  List<SpeakingAnswerModel> _previousAnswers = [];

  @override
  void initState() {
    super.initState();
    _loadPreviousAnswers();
    _initializeSpeech();
  }

  Future<void> _initializeSpeech() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        setState(() {
          _isListening = status == 'listening';
        });
      },
      onError: (error) {
        setState(() {
          _isRecording = false;
          _isListening = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ошибка распознавания речи: ${error.errorMsg}'),
            ),
          );
        }
      },
    );
    setState(() {
      _speechAvailable = available;
    });
  }

  Future<bool> _requestPermissions() async {
    final status = await Permission.microphone.request();
    if (status.isGranted) {
      return true;
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Необходимо разрешение на использование микрофона'),
          ),
        );
      }
      return false;
    }
  }

  Future<void> _startListening() async {
    if (!_speechAvailable) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Распознавание речи недоступно на этом устройстве'),
          ),
        );
      }
      return;
    }

    final hasPermission = await _requestPermissions();
    if (!hasPermission) return;

    setState(() {
      _isRecording = true;
      _recognizedText = '';
    });

    await _speech.listen(
      onResult: (result) {
        setState(() {
          _recognizedText = result.recognizedWords;

          if (result.finalResult) {
            // Когда распознавание завершено, добавляем текст в поле ввода
            if (_recognizedText.isNotEmpty) {
              final currentText = _answerController.text;
              if (currentText.isNotEmpty && !currentText.endsWith(' ')) {
                _answerController.text = '$currentText $_recognizedText';
              } else {
                _answerController.text = currentText + _recognizedText;
              }
              _answerController.selection = TextSelection.fromPosition(
                TextPosition(offset: _answerController.text.length),
              );
            }
            _recognizedText = '';
          }
        });
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      localeId: 'ru_RU', // Можно изменить на нужный язык
      cancelOnError: true,
      partialResults: true,
    );
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    setState(() {
      _isRecording = false;
      _isListening = false;
      if (_recognizedText.isNotEmpty) {
        final currentText = _answerController.text;
        if (currentText.isNotEmpty && !currentText.endsWith(' ')) {
          _answerController.text = '$currentText $_recognizedText';
        } else {
          _answerController.text = currentText + _recognizedText;
        }
        _answerController.selection = TextSelection.fromPosition(
          TextPosition(offset: _answerController.text.length),
        );
        _recognizedText = '';
      }
    });
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
    _speech.stop();
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
                  onPressed: _isRecording ? _stopListening : _startListening,
                  icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                  label: Text(
                    _isRecording ? 'Остановить запись' : 'Записать голос',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isRecording ? Colors.red : Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
            if (_isRecording || _isListening) ...[
              const SizedBox(height: 16),
              Card(
                color: Colors.orange.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.orange,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Идет запись...',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (_recognizedText.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                _recognizedText,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
