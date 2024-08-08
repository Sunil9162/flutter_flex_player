import 'package:flutter/material.dart';
import 'package:flutter_flex_player/helpers/configuration.dart';
import 'package:video_player/video_player.dart';

import '../controls/player_controls.dart';
import '../flutter_flex_player_controller.dart';

class FullScreenView extends StatefulWidget {
  final FlutterFlexPlayerController controller;
  final FlexPlayerConfiguration configuration;
  const FullScreenView({
    super.key,
    required this.controller,
    required this.configuration,
  });

  @override
  State<FullScreenView> createState() => _FullScreenViewState();
}

class _FullScreenViewState extends State<FullScreenView> {
  late FlutterFlexPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
  }

  @override
  void dispose() {
    _controller.exitFullScreen(context);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PlayerBuilder(
        controller: _controller,
        configuration: widget.configuration,
      ),
    );
  }
}

class PlayerBuilder extends StatelessWidget {
  final FlutterFlexPlayerController _controller;
  final FlexPlayerConfiguration configuration;

  const PlayerBuilder({
    super.key,
    required FlutterFlexPlayerController controller,
    required this.configuration,
  }) : _controller = controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        VideoPlayer(_controller.videoPlayerController!),
        if (configuration.controlsVisible)
          Positioned.fill(
            child: PlayerControls(
              controller: _controller,
            ),
          ),
      ],
    );
  }
}
