import 'package:flutter/material.dart';

enum StageType {
  reading,
  listening,
  speaking,
  writing,
}

class StageCard extends StatelessWidget {
  final StageType stageType;
  final VoidCallback onTap;

  const StageCard({
    super.key,
    required this.stageType,
    required this.onTap,
  });

  String get _title {
    switch (stageType) {
      case StageType.reading:
        return 'Reading';
      case StageType.listening:
        return 'Listening';
      case StageType.speaking:
        return 'Speaking';
      case StageType.writing:
        return 'Writing';
    }
  }

  String get _subtitle {
    switch (stageType) {
      case StageType.reading:
        return 'Чтение текста';
      case StageType.listening:
        return 'Прослушивание';
      case StageType.speaking:
        return 'Что поняли';
      case StageType.writing:
        return 'Написание';
    }
  }

  IconData get _icon {
    switch (stageType) {
      case StageType.reading:
        return Icons.menu_book;
      case StageType.listening:
        return Icons.headphones;
      case StageType.speaking:
        return Icons.mic;
      case StageType.writing:
        return Icons.edit;
    }
  }

  Color get _color {
    switch (stageType) {
      case StageType.reading:
        return Colors.blue;
      case StageType.listening:
        return Colors.green;
      case StageType.speaking:
        return Colors.orange;
      case StageType.writing:
        return Colors.purple;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _color.withValues(alpha: 0.8),
                _color,
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _icon,
                size: 48,
                color: Colors.white,
              ),
              const SizedBox(height: 16),
              Text(
                _title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

