import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'app/app.dart';

late final List<CameraDescription> appCameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    appCameras = await availableCameras();
  } catch (_) {
    appCameras = <CameraDescription>[];
  }
  runApp(const KalLogAppRoot());
}
