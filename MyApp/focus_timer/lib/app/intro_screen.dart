import 'package:flutter/material.dart';

class IntroScreen extends StatefulWidget {
  final String displayName;
  final VoidCallback onEnter;

  const IntroScreen({
    super.key,
    required this.displayName,
    required this.onEnter,
  });

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  bool _hintVisible = true;

  void _enter() {
    widget.onEnter();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onVerticalDragEnd: (details) {
          final velocity = details.primaryVelocity ?? 0;
          if (velocity < -400) {
            _enter();
          }
        },
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1F64FF), Color(0xFF0E2FA6)],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.self_improvement, color: Colors.white, size: 84),
                    const SizedBox(height: 20),
                    const Text(
                      'KalLog',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 42,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Welcome, ${widget.displayName}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 28),
                    AnimatedOpacity(
                      opacity: _hintVisible ? 1 : 0.4,
                      duration: const Duration(milliseconds: 350),
                      child: const Text(
                        'Swipe up to enter',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    IconButton(
                      onPressed: () {
                        setState(() => _hintVisible = !_hintVisible);
                      },
                      icon: const Icon(Icons.keyboard_arrow_up, color: Colors.white, size: 34),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
