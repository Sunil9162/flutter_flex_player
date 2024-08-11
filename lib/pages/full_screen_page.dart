// ignore_for_file: deprecated_member_use

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: PlayerBuilder(
          controller: _controller,
          configuration: widget.configuration,
        ),
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
    return WillPopScope(
      onWillPop: () async {
        if (_controller.isFullScreen) {
          _controller.exitFullScreen(context);
          return false;
        } else {
          return true;
        }
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          const SizedBox.expand(),
          StreamBuilder<InitializationEvent>(
            stream: _controller.onInitialized,
            builder: (context, snapshot) {
              return AspectRatio(
                aspectRatio: configuration.aspectRatio,
                child: _controller.isInitialized
                    ? VideoPlayer(_controller.videoPlayerController)
                    : const SizedBox(),
              );
            },
          ),
          if (configuration.controlsVisible)
            Positioned.fill(
              child: PlayerControls(
                controller: _controller,
              ),
            ),
        ],
      ),
    );
  }
}
