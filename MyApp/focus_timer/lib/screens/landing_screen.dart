import 'package:flutter/material.dart';

class LandingScreen extends StatefulWidget {
  final VoidCallback onSwipeUpComplete;

  const LandingScreen({super.key, required this.onSwipeUpComplete});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  double _dragDistance = 0.0;
  bool _dismissed = false;

  void _dismiss() {
    if (_dismissed) return;
    setState(() => _dismissed = true);
    Future.delayed(const Duration(milliseconds: 280), widget.onSwipeUpComplete);
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final threshold = height * 0.14;
    final progress = (_dragDistance.abs() / threshold).clamp(0.0, 1.0);

    return AnimatedOpacity(
      opacity: _dismissed ? 0 : 1,
      duration: const Duration(milliseconds: 260),
      child: AnimatedSlide(
        offset: _dismissed ? const Offset(0, -1) : Offset.zero,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onVerticalDragUpdate: (details) {
            setState(() {
              _dragDistance += details.delta.dy;
            });
          },
          onVerticalDragEnd: (_) {
            if (_dragDistance < -threshold) {
              _dismiss();
            } else {
              setState(() => _dragDistance = 0.0);
            }
          },
          child: Container(
            color: const Color(0xFF0C55D9),
            child: SafeArea(
              child: Stack(
                children: [
                  Positioned(
                    left: -80,
                    top: 60,
                    child: _Orb(size: 180, opacity: 0.16),
                  ),
                  Positioned(
                    right: -40,
                    top: 180,
                    child: _Orb(size: 140, opacity: 0.12),
                  ),
                  Center(
                    child: Transform.translate(
                      offset: Offset(0, -progress * 18),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 128,
                            height: 128,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withOpacity(0.35), width: 1.2),
                            ),
                            child: Center(
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/logo.png',
                                  fit: BoxFit.cover,
                                  width: 116,
                                  height: 116,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.self_improvement,
                                    color: Colors.white,
                                    size: 54,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            'ApnaFlow',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 42,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Swipe up to enter',
                            style: TextStyle(color: Colors.white70, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 30,
                    child: Column(
                      children: [
                        Container(
                          width: 110,
                          height: 7,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.65),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Pull upward',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Orb extends StatelessWidget {
  final double size;
  final double opacity;

  const _Orb({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(opacity),
        shape: BoxShape.circle,
      ),
    );
  }
}
