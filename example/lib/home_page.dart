import 'dart:developer';
import 'dart:io';

import 'package:example/video_player_screen.dart';
import 'package:file_picker/file_picker.dart' as filepicker;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flex_player/flutter_flex_player.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HomePage'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const VideoPlayerScreen()));
              },
              child: const Text("Player Screen"),
            ),
            ElevatedButton(
              onPressed: () async {
                final file = await FilePicker.platform.pickFiles(
                  type: filepicker.FileType.video,
                  allowMultiple: false,
                  onFileLoading: (p0) {
                    log("Loading: ${p0.name}");
                  },
                );
                log("Loaded");
                if (file?.files.isEmpty ?? true) {
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VideoPlayerScreen(
                      source: PlayerSources.file(File(file!.files.first.path!)),
                    ),
                  ),
                );
              },
              child: const Text("Player Screen"),
            ),
          ],
        ),
      ),
    );
  }
}
