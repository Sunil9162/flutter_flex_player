library flutter_flex_player;

import 'package:flutter/material.dart';
import 'package:flutter_flex_player/flutter_flex_player_controller.dart';
import 'package:video_player/video_player.dart';

import 'helpers/enums.dart';

// FlutterFlexPlayer is a class that will be used to create a FlutterFlexPlayer widget.
class FlutterFlexPlayer extends StatefulWidget {
  final FlutterFlexPlayerController controller;
  final bool isFullScreen;
  final bool controlsVisible;
  final Orientation orientationonFullScreen;
  final String? thumbnail;
  final double aspectRatio;
  final bool autoDispose;
  const FlutterFlexPlayer(
    this.controller, {
    super.key,
    this.isFullScreen = false,
    this.controlsVisible = true,
    this.orientationonFullScreen = Orientation.portrait,
    this.thumbnail,
    this.aspectRatio = 16 / 9,
    this.autoDispose = true,
  });

  @override
  State<FlutterFlexPlayer> createState() => _FlutterFlexPlayerState();
}

class _FlutterFlexPlayerState extends State<FlutterFlexPlayer> {
  late FlutterFlexPlayerController _controller;
  InitializationEvent? _initializationEvent;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    _controller.onInitialized.listen((event) {
      setState(() {
        _initializationEvent = event;
      });
    });
  }

  @override
  void dispose() {
    if (widget.autoDispose) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_initializationEvent == null ||
        _initializationEvent == InitializationEvent.initializing) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    if (_initializationEvent == InitializationEvent.uninitialized) {
      return const Center(
        child: Text('Error initializing video player.'),
      );
    }
    return AspectRatio(
      aspectRatio: widget.aspectRatio,
      child: VideoPlayer(_controller.videoPlayerController!),
    );
  }
}
