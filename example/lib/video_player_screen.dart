import 'package:flutter/material.dart';
import 'package:flutter_flex_player/flutter_flex_player.dart';
import 'package:flutter_flex_player/flutter_flex_player_controller.dart';
import 'package:flutter_flex_player/helpers/flex_player_sources.dart';

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late FlutterFlexPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = FlutterFlexPlayerController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.load(
        NetworkFlexPlayerSource(
          'https://live-par-2-abr.livepush.io/vod/bigbuckbunnyclip.mp4',
        ),
        autoPlay: true,
        loop: true,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VideoPlayerScreen'),
      ),
      body: FlutterFlexPlayer(
        _controller,
        aspectRatio: 16 / 9,
      ),
    );
  }
}
