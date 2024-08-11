library flutter_flex_player;

import 'package:flutter/material.dart';
import 'package:flutter_flex_player/flutter_flex_player_controller.dart';
import 'package:flutter_flex_player/helpers/configuration.dart';
import 'package:flutter_flex_player/pages/full_screen_page.dart';

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

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
  }

  @override
  void dispose() {
    if (widget.configuration.autoDispose) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: widget.configuration.aspectRatio,
      child: ColoredBox(
        color: Colors.black,
        child: PlayerBuilder(
          controller: _controller,
          configuration: widget.configuration,
        ),
      ),
    );
  }
}
