library flutter_flex_player;

import 'package:flutter/material.dart';
import 'package:flutter_flex_player/flutter_flex_player_controller.dart';
import 'package:flutter_flex_player/helpers/configuration.dart';
import 'package:flutter_flex_player/pages/player_builder.dart';
import 'package:get/get.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

// FlutterFlexPlayer is a class that will be used to create a FlutterFlexPlayer widget.
class FlutterFlexPlayer extends StatefulWidget {
  final FlutterFlexPlayerController controller;
  final bool autoDispose;
  final double aspectRatio;
  final VoidCallback? onFullScreeen;

  const FlutterFlexPlayer(
    this.controller, {
    super.key,
    this.autoDispose = true,
    this.aspectRatio = 16 / 9,
    this.onFullScreeen,
  });

  @override
  State<FlutterFlexPlayer> createState() => _FlutterFlexPlayerState();
}

class _FlutterFlexPlayerState extends State<FlutterFlexPlayer> {
  late FlutterFlexPlayerController _controller;
  late FlexPlayerConfiguration configuration;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    configuration = _controller.configuration;

    if (mounted) {
      WakelockPlus.enable();
      setState(() {
        configuration = configuration.copyWith(
          aspectRatio: widget.aspectRatio,
          autoDispose: widget.autoDispose,
        );
      });
    }
  }

  @override
  void dispose() {
    if (configuration.autoDispose) {
      _controller.dispose();
    }
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: AspectRatio(
        aspectRatio: configuration.aspectRatio,
        child: ColoredBox(
          color: Colors.black,
          child: Obx(() {
            if (widget.controller.isFullScreen.value) {
              return const SizedBox();
            }
            return PlayerBuilder(
              controller: widget.controller,
              configuration: configuration,
              onFullScreeen: widget.onFullScreeen,
            );
          }),
        ),
      ),
    );
  }
}