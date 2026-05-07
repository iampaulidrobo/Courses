import 'dart:async';

import 'package:flutter/material.dart';

import '../models/session_stats.dart';
import '../models/session_summary.dart';
import '../services/session_store.dart';
import '../widgets/create_session_dialog.dart';
import '../widgets/rename_session_dialog.dart';
import 'session_page.dart';

class EstimatePage extends StatefulWidget {
  final String displayName;
  final String userScopeId;

  const EstimatePage({
    super.key,
    required this.displayName,
    required this.userScopeId,
  });

  @override
  State<EstimatePage> createState() => _EstimatePageState();
}

class _EstimatePageState extends State<EstimatePage> {
  late final SessionStore store;
  Future<List<SessionSummary>>? _sessionsFuture;
  SessionSummary? _selectedSession;
  SessionStats? _selectedStats;
  bool _taglineVisible = true;
  Timer? _blinkTimer;

  @override
  void initState() {
    super.initState();
    store = SessionStore(widget.userScopeId);
    _refresh();
    _startBlink();
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    super.dispose();
  }

  void _startBlink() {
    _blinkTimer?.cancel();
    _blinkTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      if (!mounted) return;
      setState(() => _taglineVisible = false);
      await Future.delayed(const Duration(milliseconds: 250));
      if (!mounted) return;
      setState(() => _taglineVisible = true);
    });
  }

  void _refresh() {
    setState(() {
      _sessionsFuture = store.listSessions();
    });
  }

  Future<void> _selectSession(SessionSummary session) async {
    setState(() {
      _selectedSession = session;
      _selectedStats = null;
    });
    final stats = await store.sessionStats(session);
    if (!mounted) return;
    if (_selectedSession?.path != session.path) return;
    setState(() => _selectedStats = stats);
  }

  Future<void> _createSession() async {
    final result = await showDialog<CreateSessionResult>(
      context: context,
      builder: (_) => const CreateSessionDialog(),
    );
    if (result == null) return;

    try {
      await store.createSession(
        name: result.name,
        durationSeconds: result.durationSeconds,
        maxRecordings: result.maxRecordings,
      );
      _refresh();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session could not be created. Try a different name.')),
        );
      }
    }
  }

  Future<void> _renameSession(SessionSummary session) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => RenameSessionDialog(initialName: session.meta.name),
    );
    if (name == null) return;
    try {
      await store.renameSession(session, name);
      _refresh();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rename failed.')),
        );
      }
    }
  }

  Future<void> _deleteSession(SessionSummary session) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete session'),
        content: Text('Delete "${session.meta.name}" permanently?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (ok == true) {
      await store.deleteSession(session);
      if (_selectedSession?.path == session.path) {
        _selectedSession = null;
        _selectedStats = null;
      }
      _refresh();
    }
  }

  String _dateOnly(DateTime d) {
    final dt = DateTime(d.year, d.month, d.day);
    return '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  String _countText(int value) => value == 1 ? '1 day' : '$value days';

  Color _progressColor(SessionSummary s) {
    if (s.progress >= 1.0) return Colors.green;
    if (s.progress >= 0.6) return Colors.blue;
    if (s.progress >= 0.3) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: const Color(0xFFF2E8D5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Namaste, ${widget.displayName}',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    AnimatedOpacity(
                      opacity: _taglineVisible ? 1 : 0.08,
                      duration: const Duration(milliseconds: 260),
                      child: Text(
                        'sense the fence || fence the sense',
                        style: TextStyle(
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                          color: Colors.brown.shade800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    FutureBuilder<List<SessionSummary>>(
                      future: _sessionsFuture,
                      builder: (context, snapshot) {
                        final sessions = snapshot.data ?? const <SessionSummary>[];
                        if (snapshot.hasData && sessions.isNotEmpty && _selectedSession == null) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted && _selectedSession == null && sessions.isNotEmpty) {
                              _selectSession(sessions.first);
                            }
                          });
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (!snapshot.hasData)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 24),
                                child: Center(child: CircularProgressIndicator()),
                              )
                            else if (sessions.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(child: Text('No sessions yet')),
                              )
                            else
                              ...sessions.map((session) {
                                final selected = _selectedSession?.path == session.path;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Card(
                                    color: selected ? Colors.white : Colors.white.withOpacity(0.88),
                                    elevation: selected ? 4 : 1,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                      side: BorderSide(
                                        color: selected ? Colors.black : Colors.transparent,
                                        width: selected ? 1.1 : 0,
                                      ),
                                    ),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(18),
                                      onTap: () => _selectSession(session),
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    session.meta.name,
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.w800,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                                PopupMenuButton<String>(
                                                  onSelected: (value) {
                                                    if (value == 'open') {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (_) => SessionPage(
                                                            session: session,
                                                            userScopeId: widget.userScopeId,
                                                          ),
                                                        ),
                                                      ).then((_) => _refresh());
                                                    } else if (value == 'rename') {
                                                      _renameSession(session);
                                                    } else if (value == 'delete') {
                                                      _deleteSession(session);
                                                    }
                                                  },
                                                  itemBuilder: (context) => const [
                                                    PopupMenuItem(value: 'open', child: Text('Open')),
                                                    PopupMenuItem(value: 'rename', child: Text('Rename')),
                                                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(999),
                                              child: LinearProgressIndicator(
                                                minHeight: 10,
                                                value: session.progress,
                                                backgroundColor: Colors.black12,
                                                valueColor: AlwaysStoppedAnimation<Color>(_progressColor(session)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            const SizedBox(height: 8),
                            if (_selectedSession != null) ...[
                              Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _selectedSession!.meta.name,
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Created on ${_dateOnly(_selectedSession!.meta.createdAt)}',
                                        style: TextStyle(color: Colors.grey.shade800),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Videos recorded: ${_selectedSession!.videoCount}/${_selectedSession!.meta.maxRecordings}',
                                        style: TextStyle(color: Colors.grey.shade800),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Recorded days: ${_selectedStats == null ? '...' : _countText(_selectedStats!.recordedDays)}',
                                        style: TextStyle(color: Colors.grey.shade800),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Current streak: ${_selectedStats == null ? '...' : _countText(_selectedStats!.currentStreak)}',
                                        style: TextStyle(color: Colors.grey.shade800),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Longest streak: ${_selectedStats == null ? '...' : _countText(_selectedStats!.longestStreak)}',
                                        style: TextStyle(color: Colors.grey.shade800),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: 20,
          bottom: 20,
          child: FloatingActionButton(
            onPressed: _createSession,
            backgroundColor: Colors.black,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
