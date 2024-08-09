// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_flex_player/helpers/configuration.dart';
import 'package:flutter_flex_player/helpers/enums.dart';
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
  InitializationEvent? _initializationEvent;
  late StreamSubscription<InitializationEvent> _initializationSubscription;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    _initializationSubscription = _controller.onInitialized.listen((event) {
      setState(() {
        _initializationEvent = event;
      });
    });
  }

  @override
  void dispose() {
    _initializationSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Builder(builder: (context) {
          if (_initializationEvent == InitializationEvent.initializing) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (_initializationEvent == InitializationEvent.uninitialized) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.warning_rounded,
                    color: Colors.red,
                    size: 30,
                  ),
                  const Text(
                    'Error playing video.',
                    style: TextStyle(color: Colors.red),
                  ),
                  IconButton(
                    onPressed: () {
                      _controller.reload();
                    },
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
            );
          }
          return PlayerBuilder(
            controller: _controller,
            configuration: widget.configuration,
          );
        }),
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
        _controller.exitFullScreen(context);
        return false;
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          const SizedBox.expand(),
          AspectRatio(
            aspectRatio: configuration.aspectRatio,
            child: VideoPlayer(_controller.videoPlayerController),
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
