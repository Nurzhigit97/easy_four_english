import 'package:flutter/material.dart';
import '../models/text_model.dart';

class AddEditTextDialog extends StatefulWidget {
  final TextModel? text;

  const AddEditTextDialog({
    super.key,
    this.text,
  });

  @override
  State<AddEditTextDialog> createState() => _AddEditTextDialogState();
}

class _AddEditTextDialogState extends State<AddEditTextDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.text?.title ?? '');
    _descriptionController = TextEditingController(text: widget.text?.description ?? '');
    _contentController = TextEditingController(text: widget.text?.content ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop(
        TextModel(
          id: widget.text?.id,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          content: _contentController.text.trim(),
          createdAt: widget.text?.createdAt,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.text == null ? 'Добавить текст' : 'Редактировать текст'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Заголовок',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Введите заголовок';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Описание',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Введите описание';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Содержание текста',
                  border: OutlineInputBorder(),
                ),
                maxLines: 8,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Введите содержание текста';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text('Сохранить'),
        ),
      ],
    );
  }
}

