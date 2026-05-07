import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../models/session_stats.dart';
import '../models/session_summary.dart';
import '../services/session_store.dart';

class UpdatePage extends StatefulWidget {
  final String displayName;
  final String userScopeId;

  const UpdatePage({
    super.key,
    required this.displayName,
    required this.userScopeId,
  });

  @override
  State<UpdatePage> createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  late final SessionStore store;
  Future<List<SessionSummary>>? _sessionsFuture;
  SessionSummary? _selected;
  SessionStats? _selectedStats;
  Map<DateTime, int> _selectedCounts = {};
  bool _loadingCalendar = false;
  DateTime focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    store = SessionStore(widget.userScopeId);
    _reload();
  }

  void _reload() {
    setState(() {
      _sessionsFuture = store.listSessions();
    });
  }

  DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

  bool _beforeCreated(DateTime d, SessionSummary s) {
    final selected = _day(d);
    final created = _day(s.meta.createdAt);
    return selected.isBefore(created);
  }

  Future<void> _loadSelected(SessionSummary session) async {
    setState(() {
      _loadingCalendar = true;
      _selected = session;
      _selectedStats = null;
    });

    final grouped = await store.groupedVideos(session);
    final map = <DateTime, int>{};
    for (final entry in grouped.entries) {
      map[_day(entry.key)] = entry.value.length;
    }
    final stats = await store.sessionStats(session);

    if (!mounted) return;
    setState(() {
      _selectedCounts = map;
      _selectedStats = stats;
      _loadingCalendar = false;
    });
  }

  String _dateOnly(DateTime d) {
    final dt = DateTime(d.year, d.month, d.day);
    return '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  String _countText(int value) => value == 1 ? '1 day' : '$value days';

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFDCE7FF),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Update',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: FutureBuilder<List<SessionSummary>>(
              future: _sessionsFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final sessions = snapshot.data!;
                if (sessions.isEmpty) {
                  return const Center(child: Text('No sessions found'));
                }

                if (_selected == null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted && _selected == null && sessions.isNotEmpty) {
                      _loadSelected(sessions.first);
                    }
                  });
                }

                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  children: [
                    Text(
                      'Available sessions',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 10),
                    ...sessions.map((s) {
                      final selected = _selected?.meta.folderName == s.meta.folderName;
                      return Card(
                        color: selected ? Colors.white : Colors.white.withOpacity(0.92),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                          side: BorderSide(
                            color: selected ? Colors.black : Colors.transparent,
                            width: selected ? 1.1 : 0,
                          ),
                        ),
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          title: Text(
                            s.meta.name,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          trailing: Icon(
                            selected ? Icons.radio_button_checked : Icons.radio_button_off,
                            color: selected ? Colors.black : Colors.grey,
                          ),
                          onTap: () => _loadSelected(s),
                        ),
                      );
                    }),
                    const SizedBox(height: 8),
                    if (_selected != null) ...[
                      Text(
                        _selected!.meta.name,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 8),
                      if (_loadingCalendar)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Card(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: TableCalendar(
                                  firstDay: _day(_selected!.meta.createdAt),
                                  lastDay: DateTime.utc(2035, 12, 31),
                                  focusedDay: focusedDay,
                                  availableCalendarFormats: const {
                                    CalendarFormat.month: 'Month',
                                  },
                                  calendarFormat: CalendarFormat.month,
                                  headerStyle: const HeaderStyle(
                                    formatButtonVisible: false,
                                    titleCentered: true,
                                  ),
                                  calendarStyle: const CalendarStyle(outsideDaysVisible: false),
                                  enabledDayPredicate: (day) => !_beforeCreated(day, _selected!),
                                  calendarBuilders: CalendarBuilders(
                                    disabledBuilder: (context, day, _) => const SizedBox.shrink(),
                                    defaultBuilder: (context, day, _) {
                                      final d = _day(day);
                                      if (_beforeCreated(d, _selected!)) {
                                        return const SizedBox.shrink();
                                      }
                                      final count = _selectedCounts[d] ?? 0;
                                      if (count > 0) {
                                        return Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Container(
                                              decoration: const BoxDecoration(
                                                color: Colors.orange,
                                                shape: BoxShape.circle,
                                              ),
                                              alignment: Alignment.center,
                                              child: Text(
                                                '${day.day}',
                                                style: const TextStyle(color: Colors.white),
                                              ),
                                            ),
                                            Positioned(
                                              top: 4,
                                              right: 6,
                                              child: Text(
                                                '$count',
                                                style: const TextStyle(fontSize: 10, color: Colors.white),
                                              ),
                                            ),
                                          ],
                                        );
                                      }
                                      return Center(child: Text('${day.day}'));
                                    },
                                  ),
                                  onDaySelected: (selected, _) {
                                    if (_selected == null) return;
                                    if (_beforeCreated(selected, _selected!)) return;
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Card(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Session details',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text('Created on: ${_dateOnly(_selected!.meta.createdAt)}'),
                                    const SizedBox(height: 6),
                                    Text('Recorded days: ${_selectedStats == null ? '...' : _countText(_selectedStats!.recordedDays)}'),
                                    const SizedBox(height: 6),
                                    Text('Current streak: ${_selectedStats == null ? '...' : _countText(_selectedStats!.currentStreak)}'),
                                    const SizedBox(height: 6),
                                    Text('Longest streak: ${_selectedStats == null ? '...' : _countText(_selectedStats!.longestStreak)}'),
                                    const SizedBox(height: 6),
                                    Text('Videos recorded: ${_selected!.videoCount}/${_selected!.meta.maxRecordings}'),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
