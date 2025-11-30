import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../models/text_model.dart';

class ListeningStage extends StatefulWidget {
  final TextModel text;

  const ListeningStage({super.key, required this.text});

  @override
  State<ListeningStage> createState() => _ListeningStageState();
}

class _ListeningStageState extends State<ListeningStage> {
  FlutterTts flutterTts = FlutterTts();
  bool _isPlaying = false;
  bool _isInitialized = false;
  double _speechRate = 0.5;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    try {
      // Получаем список доступных голосов
      List<dynamic> voices = await flutterTts.getVoices;

      // Ищем лучший голос для английского языка
      // Приоритет: enhanced/premium голоса, затем женские голоса (обычно более приятные)
      dynamic bestVoice;

      if (voices.isNotEmpty) {
        // Фильтруем голоса для английского языка
        List<dynamic> englishVoices = voices.where((voice) {
          final locale = voice['locale']?.toString().toLowerCase() ?? '';
          return locale.startsWith('en');
        }).toList();

        if (englishVoices.isNotEmpty) {
          // Ищем enhanced/premium голоса
          bestVoice = englishVoices.firstWhere((voice) {
            final name = voice['name']?.toString().toLowerCase() ?? '';
            return name.contains('enhanced') ||
                name.contains('premium') ||
                name.contains('neural') ||
                name.contains('wave');
          }, orElse: () => null);

          // Если не нашли enhanced, ищем женские голоса (обычно более приятные)
          if (bestVoice == null) {
            bestVoice = englishVoices.firstWhere((voice) {
              final name = voice['name']?.toString().toLowerCase() ?? '';
              return name.contains('female') ||
                  name.contains('samantha') ||
                  name.contains('karen') ||
                  name.contains('susan') ||
                  name.contains('victoria');
            }, orElse: () => englishVoices.first);
          }

          // Если все еще не нашли, берем первый английский голос
          if (bestVoice == null) {
            bestVoice = englishVoices.first;
          }

          // Устанавливаем выбранный голос
          if (bestVoice != null && bestVoice['name'] != null) {
            await flutterTts.setVoice({
              'name': bestVoice['name'],
              'locale': bestVoice['locale'],
            });
          }
        }
      }

      // Устанавливаем язык
      await flutterTts.setLanguage("en-US");

      // Настраиваем параметры для лучшего качества
      await flutterTts.setSpeechRate(_speechRate);
      await flutterTts.setVolume(1.0);
      // Pitch 1.1-1.2 делает голос более приятным и естественным
      await flutterTts.setPitch(1.15);

      // На Android: пытаемся использовать лучший движок
      try {
        String? engine = await flutterTts.getDefaultEngine;
        if (engine != null) {
          await flutterTts.setEngine(engine);
        }
      } catch (e) {
        // Игнорируем ошибки выбора движка
      }

      flutterTts.setCompletionHandler(() {
        setState(() {
          _isPlaying = false;
        });
      });

      flutterTts.setErrorHandler((msg) {
        setState(() {
          _isPlaying = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ошибка воспроизведения: $msg')),
          );
        }
      });

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      // Если что-то пошло не так, используем базовые настройки
      await flutterTts.setLanguage("en-US");
      await flutterTts.setSpeechRate(_speechRate);
      await flutterTts.setVolume(1.0);
      await flutterTts.setPitch(1.15);

      flutterTts.setCompletionHandler(() {
        setState(() {
          _isPlaying = false;
        });
      });

      flutterTts.setErrorHandler((msg) {
        setState(() {
          _isPlaying = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ошибка воспроизведения: $msg')),
          );
        }
      });

      setState(() {
        _isInitialized = true;
      });
    }
  }

  Future<void> _togglePlayback() async {
    if (!_isInitialized) return;

    if (_isPlaying) {
      await flutterTts.stop();
      setState(() {
        _isPlaying = false;
      });
    } else {
      await flutterTts.speak(widget.text.content);
      setState(() {
        _isPlaying = true;
      });
    }
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Listening'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.headphones, color: Colors.green, size: 32),
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
                            'Прослушайте текст',
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
            Center(
              child: Column(
                children: [
                  Card(
                    elevation: 4,
                    shape: const CircleBorder(),
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green,
                      ),
                      child: IconButton(
                        icon: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          size: 48,
                          color: Colors.white,
                        ),
                        onPressed: _isInitialized ? _togglePlayback : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            'Скорость воспроизведения: ${(_speechRate * 100).toInt()}%',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Slider(
                            value: _speechRate,
                            min: 0.25,
                            max: 1.0,
                            divisions: 15,
                            label: '${(_speechRate * 100).toInt()}%',
                            onChanged: (value) async {
                              setState(() {
                                _speechRate = value;
                              });
                              await flutterTts.setSpeechRate(value);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Текст для прослушивания:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  widget.text.content,
                  style: const TextStyle(fontSize: 16, height: 1.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
