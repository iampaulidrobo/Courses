flutter create focus_timer
cd focus_timer
plugin the device(phone(USB debugging)) and run :
flutter run
it will build the app and a demo app will be created in the phone to check and see.

March5
1)Made estimate and update tabs,est to start seesion with custom time,update to see the previous recording.
2)LOGO?Name?daily logo change theme..
3)recorded data mark on the calender??

DEFAULT CAMERA AND STREAK INTEGFRATED-MARCH 25

MAKE ui BETTER











// 🔥 FINAL COMPLETE VERSION (ALL FEATURES)

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:video_player/video_player.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:path/path.dart' as p;

late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
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
          BottomNavigationBarItem(
              icon: Icon(Icons.schedule), label: "Estimate"),
          BottomNavigationBarItem(
              icon: Icon(Icons.update), label: "Update"),
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
                    decoration:
                        const InputDecoration(labelText: "Session Name"),
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
                    onChanged: (v) =>
                        setStateDialog(() => durationSeconds = v!),
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
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            SessionPage(sessionName: name, duration: 60),
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

  const SessionPage({
    super.key,
    required this.sessionName,
    required this.duration,
  });

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
    return recordedDays.containsKey(day) &&
        recordedDays.containsKey(prev);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text(widget.sessionName)),
      body: TableCalendar(
        firstDay: DateTime.utc(2023,1,1),
        lastDay: DateTime.utc(2035,12,31),
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
                    child: Text("${day.day}",
                        style: const TextStyle(color: Colors.white)),
                  ),

                  Positioned(
                    top: 4,
                    right: 6,
                    child: Text("$count",
                        style: const TextStyle(
                            fontSize: 10, color: Colors.white)),
                  )
                ],
              );
            }

            return null;
          },
        ),

        onDaySelected: (selected, _) {

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VideoRecorder(
                sessionName: widget.sessionName,
                duration: widget.duration,
                recordDate: selected,
              ),
            ),
          ).then((_) => loadRecordedDays());
        },
      ),
    );
  }
}

// ================= RECORDER =================

class VideoRecorder extends StatefulWidget {

  final String sessionName;
  final int duration;
  final DateTime recordDate;

  const VideoRecorder({
    super.key,
    required this.sessionName,
    required this.duration,
    required this.recordDate,
  });

  @override
  State<VideoRecorder> createState() => _VideoRecorderState();
}

class _VideoRecorderState extends State<VideoRecorder> {

  CameraController? controller;

  bool recording = false;
  bool paused = false;

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  Future<void> initCamera() async {

    controller = CameraController(
      cameras[0],
      ResolutionPreset.medium,
    );

    await controller!.initialize();
    setState(() {});
  }

  Future<String> getPath() async {

    final dir = Directory(
        "/storage/emulated/0/Movies/YourYesterday/${widget.sessionName}");

    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final d = widget.recordDate;

    return p.join(
      dir.path,
      "${d.year}-${d.month}-${d.day}_${DateTime.now().millisecondsSinceEpoch}.mp4",
    );
  }

  Future<void> startRecording() async {

    await controller!.startVideoRecording();
    recording = true;
    paused = false;

    setState(() {});
  }

  Future<void> pauseRecording() async {

    if (!paused) {
      await controller!.pauseVideoRecording();
      paused = true;
    } else {
      await controller!.resumeVideoRecording();
      paused = false;
    }

    setState(() {});
  }

  Future<void> saveRecording() async {

    final file = await controller!.stopVideoRecording();

    final path = await getPath();

    await File(file.path).copy(path);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {

    if (!controller!.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Record")),
      body: Column(
        children: [

          Expanded(child: CameraPreview(controller!)),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              ElevatedButton(
                onPressed: recording ? null : startRecording,
                child: const Text("Start"),
              ),

              const SizedBox(width: 10),

              ElevatedButton(
                onPressed: recording ? pauseRecording : null,
                child: Text(paused ? "Resume" : "Pause"),
              ),

              const SizedBox(width: 10),

              ElevatedButton(
                onPressed: recording ? saveRecording : null,
                child: const Text("Save"),
              ),
            ],
          ),

          const SizedBox(height: 20),
        ],
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

  Future<Map<String,List<File>>> loadVideos() async {

    final base = Directory("/storage/emulated/0/Movies/YourYesterday");

    Map<String,List<File>> result = {};

    if (!await base.exists()) return result;

    for (var session in base.listSync()) {

      if (session is Directory) {

        final name = p.basename(session.path);

        final files = session
            .listSync()
            .whereType<File>()
            .where((file) => file.path.endsWith(".mp4"))
            .toList();

        if(files.isNotEmpty){
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
                        builder: (_) =>
                            VideoPlayerPage(path: file.path),
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