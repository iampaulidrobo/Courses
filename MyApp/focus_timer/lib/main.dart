import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:path/path.dart' as p;
import 'package:image_picker/image_picker.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const YourYesterdayApp());
}

class YourYesterdayApp extends StatelessWidget {
  const YourYesterdayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeTabs(),
    );
  }
}

class HomeTabs extends StatefulWidget {
  const HomeTabs({super.key});

  @override
  State<HomeTabs> createState() => _HomeTabsState();
}

class _HomeTabsState extends State<HomeTabs> {
  int index = 0;

  final pages = [
    const EstimatePage(),
    const UpdatePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Your Yesterday")),
      body: pages[index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) => setState(() => index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.schedule), label: "Estimate"),
          BottomNavigationBarItem(icon: Icon(Icons.update), label: "Update"),
        ],
      ),
    );
  }
}

// ================= ESTIMATE =================

class EstimatePage extends StatefulWidget {
  const EstimatePage({super.key});

  @override
  State<EstimatePage> createState() => _EstimatePageState();
}

class _EstimatePageState extends State<EstimatePage> {
  final TextEditingController nameController = TextEditingController();

  int durationSeconds = 60;

  final Map<String, int> durationOptions = {
    "1 min": 60,
    "2 min": 120,
    "5 min": 300,
  };

  Future<List<String>> loadSessions() async {
    final dir = Directory("/storage/emulated/0/Movies/YourYesterday");
    if (!await dir.exists()) return [];

    return dir
        .listSync()
        .whereType<Directory>()
        .map((e) => p.basename(e.path))
        .toList();
  }

  void createSession() {
    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Create Session"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: "Session Name"),
                  ),
                  const SizedBox(height: 20),
                  DropdownButton<int>(
                    value: durationSeconds,
                    items: durationOptions.entries
                        .map((e) => DropdownMenuItem(
                              value: e.value,
                              child: Text(e.key),
                            ))
                        .toList(),
                    onChanged: (v) => setStateDialog(() => durationSeconds = v!),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text("Create"),
                  onPressed: () async {
                    if (nameController.text.isEmpty) return;

                    final dir = Directory(
                        "/storage/emulated/0/Movies/YourYesterday/${nameController.text}");

                    await dir.create(recursive: true);

                    Navigator.pop(context);
                    setState(() {});
                  },
                )
              ],
            );
          },
        );
      },
    );
  }

  Future<void> renameSession(String oldName) async {
    final controller = TextEditingController(text: oldName);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Rename Session"),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            child: const Text("Save"),
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isEmpty) return;

              final oldDir = Directory(
                  "/storage/emulated/0/Movies/YourYesterday/$oldName");
              final newDir = Directory(
                  "/storage/emulated/0/Movies/YourYesterday/$newName");

              if (await oldDir.exists()) {
                await oldDir.rename(newDir.path);
              }

              Navigator.pop(context);
              setState(() {});
            },
          )
        ],
      ),
    );
  }

  Future<void> deleteSession(String name) async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Session"),
        content: const Text("Are you sure you want to delete this session?"),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text("Delete"),
            onPressed: () async {
              final dir = Directory(
                  "/storage/emulated/0/Movies/YourYesterday/$name");

              if (await dir.exists()) {
                await dir.delete(recursive: true);
              }

              Navigator.pop(context);
              setState(() {});
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: createSession,
          child: const Text("Create Session"),
        ),
        Expanded(
          child: FutureBuilder(
            future: loadSessions(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
              }

              final sessions = snapshot.data!;

              return ListView.builder(
                itemCount: sessions.length,
                itemBuilder: (_, i) {
                  final name = sessions[i];

                  return ListTile(
                    title: Text(name),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'rename') renameSession(name);
                        if (value == 'delete') deleteSession(name);
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(value: 'rename', child: Text('Rename')),
                        PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SessionPage(sessionName: name, duration: 60),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        )
      ],
    );
  }
}

// ================= SESSION =================

class SessionPage extends StatefulWidget {
  final String sessionName;
  final int duration;

  const SessionPage({super.key, required this.sessionName, required this.duration});

  @override
  State<SessionPage> createState() => _SessionPageState();
}

class _SessionPageState extends State<SessionPage> {
  DateTime today = DateTime.now();
  Map<DateTime, int> recordedDays = {};

  @override
  void initState() {
    super.initState();
    loadRecordedDays();
  }

  Future<void> loadRecordedDays() async {
    final dir = Directory(
        "/storage/emulated/0/Movies/YourYesterday/${widget.sessionName}");

    recordedDays.clear();

    if (!await dir.exists()) return;

    for (var f in dir.listSync()) {
      if (f is File && f.path.endsWith(".mp4")) {
        final name = p.basenameWithoutExtension(f.path);
        final d = DateTime.parse(name.split("_")[0]);

        final key = DateTime(d.year, d.month, d.day);
        recordedDays[key] = (recordedDays[key] ?? 0) + 1;
      }
    }

    setState(() {});
  }

  bool isStreakDay(DateTime day) {
    final prev = day.subtract(const Duration(days: 1));
    return recordedDays.containsKey(day) && recordedDays.containsKey(prev);
  }

  Future<void> openCameraAndSave(DateTime selected) async {
    final picker = ImagePicker();

    final XFile? video = await picker.pickVideo(
      source: ImageSource.camera,
    );

    if (video == null) return;

    final dir = Directory(
        "/storage/emulated/0/Movies/YourYesterday/${widget.sessionName}");

    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    String two(int n) => n.toString().padLeft(2, '0');

    final d = selected;

    final newPath = p.join(
      dir.path,
      "${d.year}-${two(d.month)}-${two(d.day)}_${DateTime.now().millisecondsSinceEpoch}.mp4",
    );

    await File(video.path).copy(newPath);

    await loadRecordedDays();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.sessionName)),
      body: TableCalendar(
        firstDay: DateTime.utc(2023, 1, 1),
        lastDay: DateTime.utc(2035, 12, 31),
        focusedDay: today,
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, _) {
            final d = DateTime(day.year, day.month, day.day);

            if (recordedDays.containsKey(d)) {
              final count = recordedDays[d]!;
              final streak = isStreakDay(d);

              return Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: streak ? Colors.orange : Colors.green,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text("${day.day}", style: const TextStyle(color: Colors.white)),
                  ),
                  Positioned(
                    top: 4,
                    right: 6,
                    child: Text("$count", style: const TextStyle(fontSize: 10, color: Colors.white)),
                  )
                ],
              );
            }

            return Center(child: Text("${day.day}"));
          },
        ),
        onDaySelected: (selected, _) async {
          await openCameraAndSave(selected);
        },
      ),
    );
  }
}

// ================= UPDATE =================

class UpdatePage extends StatefulWidget {
  const UpdatePage({super.key});

  @override
  State<UpdatePage> createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  Future<Map<String, List<File>>> loadVideos() async {
    final base = Directory("/storage/emulated/0/Movies/YourYesterday");

    Map<String, List<File>> result = {};

    if (!await base.exists()) return result;

    for (var session in base.listSync()) {
      if (session is Directory) {
        final name = p.basename(session.path);

        final files = session
            .listSync()
            .whereType<File>()
            .where((file) => file.path.endsWith(".mp4"))
            .toList();

        if (files.isNotEmpty) {
          result[name] = files;
        }
      }
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: loadVideos(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final sessions = snapshot.data!;

        return ListView(
          children: sessions.entries.map((entry) {
            return ExpansionTile(
              title: Text(entry.key),
              children: entry.value.map((file) {
                return ListTile(
                  title: Text(p.basename(file.path)),
                  trailing: const Icon(Icons.play_arrow),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VideoPlayerPage(path: file.path),
                      ),
                    );
                  },
                );
              }).toList(),
            );
          }).toList(),
        );
      },
    );
  }
}

// ================= PLAYER =================

class VideoPlayerPage extends StatefulWidget {
  final String path;

  const VideoPlayerPage({super.key, required this.path});

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late VideoPlayerController controller;

  @override
  void initState() {
    super.initState();

    controller = VideoPlayerController.file(File(widget.path))
      ..initialize().then((_) {
        setState(() {});
        controller.play();
      });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reflection Video")),
      body: Center(
        child: controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: VideoPlayer(controller),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}