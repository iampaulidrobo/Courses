import 'package:flutter/material.dart';

import 'estimate_page.dart';
import 'landing_screen.dart';
import 'update_page.dart';

class HomeShell extends StatefulWidget {
  final String displayName;
  final String userScopeId;
  final String authModeLabel;
  final Future<void> Function() onSignOut;

  const HomeShell({
    super.key,
    required this.displayName,
    required this.userScopeId,
    required this.authModeLabel,
    required this.onSignOut,
  });

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  bool _introVisible = true;

  @override
  Widget build(BuildContext context) {
    final pages = [
      EstimatePage(
        displayName: widget.displayName,
        userScopeId: widget.userScopeId,
      ),
      UpdatePage(
        displayName: widget.displayName,
        userScopeId: widget.userScopeId,
      ),
    ];

    return Scaffold(
      body: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipOval(
                    child: Image.asset(
                      'assets/logo.png',
                      height: 28,
                      width: 28,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.self_improvement, size: 22),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('ApnaFlow'),
                ],
              ),
              actions: [
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) async {
                    if (value == 'logout') {
                      await widget.onSignOut();
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'logout',
                      child: Text('Sign out (${widget.authModeLabel})'),
                    ),
                  ],
                ),
              ],
            ),
            body: pages[_index],
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _index,
              onTap: (i) => setState(() => _index = i),
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.schedule), label: 'Estimate'),
                BottomNavigationBarItem(icon: Icon(Icons.update), label: 'Update'),
              ],
            ),
          ),
          if (_introVisible)
            LandingScreen(
              onSwipeUpComplete: () {
                if (mounted) setState(() => _introVisible = false);
              },
            ),
        ],
      ),
    );
  }
}
