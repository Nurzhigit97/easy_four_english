import 'package:flutter/material.dart';
import '../models/text_model.dart';
import '../widgets/stage_card.dart';
import 'stages/reading_stage.dart';
import 'stages/listening_stage.dart';
import 'stages/speaking_stage.dart';
import 'stages/writing_stage.dart';

class TextDetailScreen extends StatelessWidget {
  final TextModel text;

  const TextDetailScreen({
    super.key,
    required this.text,
  });

  void _navigateToStage(BuildContext context, StageType stageType) {
    Widget screen;
    switch (stageType) {
      case StageType.reading:
        screen = ReadingStage(text: text);
        break;
      case StageType.listening:
        screen = ListeningStage(text: text);
        break;
      case StageType.speaking:
        screen = SpeakingStage(text: text);
        break;
      case StageType.writing:
        screen = WritingStage(text: text);
        break;
    }

    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(text.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Описание',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        text.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Этапы изучения',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
                children: [
                  StageCard(
                    stageType: StageType.reading,
                    onTap: () => _navigateToStage(context, StageType.reading),
                  ),
                  StageCard(
                    stageType: StageType.listening,
                    onTap: () => _navigateToStage(context, StageType.listening),
                  ),
                  StageCard(
                    stageType: StageType.speaking,
                    onTap: () => _navigateToStage(context, StageType.speaking),
                  ),
                  StageCard(
                    stageType: StageType.writing,
                    onTap: () => _navigateToStage(context, StageType.writing),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

