library flutter_flex_player;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_flex_player/flutter_flex_player_controller.dart';
import 'package:flutter_flex_player/helpers/configuration.dart';
import 'package:flutter_flex_player/pages/full_screen_page.dart';

import 'helpers/enums.dart';

// FlutterFlexPlayer is a class that will be used to create a FlutterFlexPlayer widget.
class FlutterFlexPlayer extends StatefulWidget {
  final FlutterFlexPlayerController controller;
  final FlexPlayerConfiguration configuration;
  const FlutterFlexPlayer(
    this.controller, {
    super.key,
    required this.configuration,
  });

  @override
  State<FlutterFlexPlayer> createState() => _FlutterFlexPlayerState();
}

class _FlutterFlexPlayerState extends State<FlutterFlexPlayer> {
  late FlutterFlexPlayerController _controller;
  InitializationEvent? _initializationEvent;
  late StreamSubscription<InitializationEvent> _initializationSubscription;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    _controller.aspectRatio = widget.configuration.aspectRatio;
    _initializationSubscription = _controller.onInitialized.listen((event) {
      setState(() {
        _initializationEvent = event;
      });
    });
  }

  @override
  void dispose() {
    if (widget.configuration.autoDispose) {
      _controller.dispose();
    }
    _initializationSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: widget.configuration.aspectRatio,
      child: Builder(
        builder: (context) {
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
          return PlayerBuilder(
            controller: _controller,
            configuration: widget.configuration,
          );
        },
      ),
    );
  }
}
