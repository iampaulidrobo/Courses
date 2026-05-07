import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../models/session_summary.dart';
import '../services/session_store.dart';
import 'recorder_page.dart';

class SessionPage extends StatefulWidget {
  final SessionSummary session;
  final String userScopeId;

  const SessionPage({
    super.key,
    required this.session,
    required this.userScopeId,
  });

  @override
  State<SessionPage> createState() => _SessionPageState();
}

class _SessionPageState extends State<SessionPage> {
  late final SessionStore store;
  Map<DateTime, int> recordedDays = {};
  late DateTime focusedDay;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    store = SessionStore(widget.userScopeId);
    focusedDay = DateTime.now();
    _load();
  }

  DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

  Future<void> _load() async {
    final grouped = await store.groupedVideos(widget.session);
    final map = <DateTime, int>{};
    for (final entry in grouped.entries) {
      map[_day(entry.key)] = entry.value.length;
    }
    if (!mounted) return;
    setState(() {
      recordedDays = map;
      loading = false;
    });
  }

  bool _beforeCreated(DateTime day) {
    final selected = _day(day);
    final created = _day(widget.session.meta.createdAt);
    return selected.isBefore(created);
  }

  Future<void> _openRecorder(DateTime selected) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => RecorderPage(
          session: widget.session,
          userScopeId: widget.userScopeId,
          recordDate: selected,
        ),
      ),
    );

    if (result == true) {
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final createdDay = _day(widget.session.meta.createdAt);

    return Scaffold(
      appBar: AppBar(title: Text(widget.session.meta.name)),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : TableCalendar(
              firstDay: createdDay,
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
              enabledDayPredicate: (day) => !_beforeCreated(day),
              calendarBuilders: CalendarBuilders(
                disabledBuilder: (context, day, _) => const SizedBox.shrink(),
                defaultBuilder: (context, day, _) {
                  final d = _day(day);

                  if (_beforeCreated(d)) {
                    return const SizedBox.shrink();
                  }

                  final count = recordedDays[d] ?? 0;
                  if (count > 0) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                            color: Colors.green,
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
              onDaySelected: (selected, _) async {
                final d = _day(selected);
                if (_beforeCreated(d)) return;
                await _openRecorder(d);
              },
            ),
    );
  }
}
