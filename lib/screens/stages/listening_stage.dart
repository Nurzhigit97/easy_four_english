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
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(_speechRate);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);

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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Ошибка воспроизведения: $msg')));
      }
    });

    setState(() {
      _isInitialized = true;
    });
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
