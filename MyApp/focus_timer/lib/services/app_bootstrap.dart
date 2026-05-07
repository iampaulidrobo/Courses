import 'package:flutter/material.dart';

import '../models/local_user.dart';
import '../screens/auth_screen.dart';
import '../screens/home_shell.dart';
import 'profile_store.dart';

class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key});

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  bool _booted = false;
  LocalUser? _currentUser;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _currentUser = await ProfileStore.loadUser();
    if (mounted) {
      setState(() => _booted = true);
    }
  }

  Future<void> _signIn(LocalUser user) async {
    await ProfileStore.saveUser(user);
    if (mounted) {
      setState(() => _currentUser = user);
    }
  }

  Future<void> _signOut() async {
    await ProfileStore.clearUser();
    if (mounted) {
      setState(() => _currentUser = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_booted) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final user = _currentUser;
    if (user == null) {
      return AuthScreen(onGuestLogin: _signIn);
    }

    return HomeShell(
      displayName: user.displayName,
      userScopeId: user.scopeId,
      authModeLabel: user.loginMode,
      onSignOut: _signOut,
    );
  }
}
