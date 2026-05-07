import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import 'player_page.dart';

class DayVideosPage extends StatelessWidget {
  final DateTime date;
  final List<File> videos;

  const DayVideosPage({super.key, required this.date, required this.videos});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${date.day}/${date.month}/${date.year}')),
      body: ListView.separated(
        itemCount: videos.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final video = videos[index];
          return ListTile(
            title: Text(p.basename(video.path)),
            trailing: const Icon(Icons.play_arrow),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PlayerPage(path: video.path)),
              );
            },
          );
        },
      ),
    );
  }
}
