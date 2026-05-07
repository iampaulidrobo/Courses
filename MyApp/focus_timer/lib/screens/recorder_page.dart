import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../main.dart' show appCameras;
import '../models/session_summary.dart';
import '../services/session_store.dart';

class RecorderPage extends StatefulWidget {
  final SessionSummary session;
  final String userScopeId;
  final DateTime recordDate;

  const RecorderPage({
    super.key,
    required this.session,
    required this.userScopeId,
    required this.recordDate,
  });

  @override
  State<RecorderPage> createState() => _RecorderPageState();
}

class _RecorderPageState extends State<RecorderPage> {
  CameraController? controller;
  Timer? timer;
  bool recording = false;
  int remainingSeconds = 0;
  int _cameraIndex = 0;
  late final SessionStore store;
  bool _initializing = true;
  String _status = 'Preparing camera...';

  @override
  void initState() {
    super.initState();
    store = SessionStore(widget.userScopeId);
    _initCamera();
  }

  @override
  void dispose() {
    timer?.cancel();
    controller?.dispose();
    super.dispose();
  }

  CameraDescription? get _selectedCamera {
    if (appCameras.isEmpty) return null;
    if (_cameraIndex < 0 || _cameraIndex >= appCameras.length) {
      _cameraIndex = 0;
    }

    final preferredDirection = _cameraIndex == 0 ? CameraLensDirection.back : CameraLensDirection.front;
    final match = appCameras.where((c) => c.lensDirection == preferredDirection).toList();
    if (match.isNotEmpty) return match.first;
    return appCameras.first;
  }

  void _startTimer() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (t) async {
      if (!mounted) return;
      setState(() {
        remainingSeconds--;
      });

      if (remainingSeconds <= 0) {
        t.cancel();
        await _stopAndSave(popAfterSave: true);
      }
    });
  }

  Future<void> _initCamera() async {
    setState(() {
      _initializing = true;
      _status = 'Preparing camera...';
    });

    try {
      await controller?.dispose();
      final camera = _selectedCamera;
      if (camera == null) {
        setState(() {
          _status = 'No camera found';
          _initializing = false;
        });
        return;
      }

      controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: true,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await controller!.initialize();
      if (!mounted) return;
      setState(() {
        _initializing = false;
        _status = recording ? 'Recording' : 'Ready';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _initializing = false;
        _status = 'Camera init failed: $e';
      });
    }
  }

  Future<void> _toggleCamera() async {
    if (appCameras.isEmpty) return;

    final wasRecording = recording;
    final savedRemaining = remainingSeconds;

    if (wasRecording) {
      timer?.cancel();
      await _stopAndSave(popAfterSave: false);
    }

    _cameraIndex = _cameraIndex == 0 ? 1 : 0;
    await _initCamera();

    if (wasRecording && mounted && controller != null && controller!.value.isInitialized) {
      try {
        await controller!.startVideoRecording();
        if (!mounted) return;
        setState(() {
          recording = true;
          remainingSeconds = savedRemaining;
          _status = 'Recording';
        });
        _startTimer();
      } catch (e) {
        if (!mounted) return;
        setState(() => _status = 'Restart after switch failed: $e');
      }
    }
  }

  Future<void> _startRecording() async {
    if (controller == null || !controller!.value.isInitialized || recording) return;

    final total = await store.totalVideos(widget.session);
    if (total >= widget.session.meta.maxRecordings) {
      setState(() => _status = 'Recording limit reached');
      return;
    }

    try {
      await controller!.startVideoRecording();
      if (!mounted) return;

      setState(() {
        recording = true;
        remainingSeconds = widget.session.meta.durationSeconds;
        _status = 'Recording';
      });

      _startTimer();
    } catch (e) {
      if (!mounted) return;
      setState(() => _status = 'Start failed: $e');
    }
  }

  Future<void> _stopAndSave({required bool popAfterSave}) async {
    if (controller == null || !recording) return;

    try {
      timer?.cancel();
      final file = await controller!.stopVideoRecording();
      final destination = await store.nextRecordingPath(widget.session, widget.recordDate);
      await File(file.path).copy(destination);

      if (!mounted) return;
      setState(() {
        recording = false;
        _status = 'Saved';
      });
      if (popAfterSave && mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        recording = false;
        _status = 'Save failed: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final preview = controller?.value.isInitialized == true;
    final canToggle = appCameras.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: _initializing || !preview
                      ? Center(
                          child: Text(
                            _status,
                            style: const TextStyle(color: Colors.white70),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: AspectRatio(
                            aspectRatio: controller!.value.aspectRatio,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                CameraPreview(controller!),
                                Positioned(
                                  right: 12,
                                  bottom: 12,
                                  child: Opacity(
                                    opacity: 0.88,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.45),
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: const Text(
                                        'ApnaFlow',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                if (recording)
                                  Positioned(
                                    left: 12,
                                    top: 12,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.75),
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        '$remainingSeconds s',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: Material(
                color: Colors.black.withOpacity(0.45),
                shape: const CircleBorder(),
                child: IconButton(
                  onPressed: canToggle ? _toggleCamera : null,
                  icon: Icon(
                    _cameraIndex == 0 ? Icons.camera_rear : Icons.camera_front,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 18,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FilledButton.icon(
                    onPressed: recording ? null : _startRecording,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    ),
                    icon: const Icon(Icons.fiber_manual_record),
                    label: Text(recording ? 'Recording' : 'Start recording'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
