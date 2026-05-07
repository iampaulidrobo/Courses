import 'package:flutter/material.dart';

import '../models/local_user.dart';

class AuthScreen extends StatefulWidget {
  final Future<void> Function(LocalUser user) onGuestLogin;

  const AuthScreen({
    super.key,
    required this.onGuestLogin,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _nameController = TextEditingController();
  bool _busy = false;
  String _message = '';

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _continueLocally() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _message = 'Enter a display name.');
      return;
    }

    setState(() {
      _busy = true;
      _message = '';
    });

    final scope = name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
    final user = LocalUser(
      displayName: name,
      loginMode: 'Local mode',
      scopeId: scope.isEmpty ? 'guest' : 'guest_$scope',
    );

    try {
      await widget.onGuestLogin(user);
    } catch (e) {
      if (mounted) {
        setState(() => _message = 'Could not continue: $e');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2E8D5),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Card(
                elevation: 10,
                shadowColor: Colors.black26,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),
                      Center(
                        child: ClipOval(
                          child: Image.asset(
                            'assets/logo.png',
                            width: 92,
                            height: 92,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(Icons.self_improvement, size: 80),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'ApnaFlow',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Local release mode',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Display name',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: _busy ? null : _continueLocally,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(double.infinity, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(_busy ? 'Entering...' : 'Continue'),
                      ),
                      if (_message.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          _message,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
