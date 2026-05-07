import 'package:flutter/material.dart';

class CreateSessionResult {
  final String name;
  final int durationSeconds;
  final int maxRecordings;

  CreateSessionResult({
    required this.name,
    required this.durationSeconds,
    required this.maxRecordings,
  });
}

class CreateSessionDialog extends StatefulWidget {
  const CreateSessionDialog({super.key});

  @override
  State<CreateSessionDialog> createState() => _CreateSessionDialogState();
}

class _CreateSessionDialogState extends State<CreateSessionDialog> {
  final _name = TextEditingController();
  final _max = TextEditingController(text: '10');
  final _customDuration = TextEditingController();
  int _duration = 60;
  bool _custom = false;

  final options = const {
    '3 sec': 3,
    '5 sec': 5,
    '10 sec': 10,
    '1 min': 60,
    '2 min': 120,
    '5 min': 300,
    'Custom': -1,
  };

  @override
  void dispose() {
    _name.dispose();
    _max.dispose();
    _customDuration.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _name.text.trim();
    if (name.isEmpty) return;

    int duration = _duration;
    if (_custom) {
      final val = int.tryParse(_customDuration.text.trim());
      if (val == null || val < 1 || val > 3600) return;
      duration = val;
    }

    final max = int.tryParse(_max.text.trim()) ?? 10;
    if (max < 1) return;

    Navigator.pop(
      context,
      CreateSessionResult(
        name: name,
        durationSeconds: duration,
        maxRecordings: max,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create session'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _name,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Session name'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: _duration,
              decoration: const InputDecoration(labelText: 'Duration'),
              items: options.entries
                  .map((e) => DropdownMenuItem(value: e.value, child: Text(e.key)))
                  .toList(),
              onChanged: (v) {
                if (v == null) return;
                setState(() {
                  _duration = v;
                  _custom = v == -1;
                });
              },
            ),
            if (_custom) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _customDuration,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Custom duration in seconds',
                ),
              ),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: _max,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Maximum recordings'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Create'),
        ),
      ],
    );
  }
}
