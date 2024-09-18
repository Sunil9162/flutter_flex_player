import 'package:flutter/material.dart';
import 'package:flutter_flex_player/controls/player_controller.dart';
import 'package:flutter_flex_player/controls/player_controls.dart';
import 'package:flutter_flex_player/flutter_flex_player_controller.dart';
import 'package:flutter_flex_player/helpers/configuration.dart';
import 'package:video_player/video_player.dart';

class PlayerBuilder extends StatefulWidget {
  final FlutterFlexPlayerController _controller;
  final FlexPlayerConfiguration configuration;

  const PlayerBuilder({
    super.key,
    required FlutterFlexPlayerController controller,
    required this.configuration,
  }) : _controller = controller;

  @override
  State<PlayerBuilder> createState() => _PlayerBuilderState();
}

class _PlayerBuilderState extends State<PlayerBuilder>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      widget._controller.pause();
    } else if (state == AppLifecycleState.resumed) {
      widget._controller.play();
      PlayerController.instance.isControlsVisible.value = true;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !widget._controller.isFullScreen,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          widget._controller.exitFullScreen(context);
        }
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          const SizedBox.expand(),
          StreamBuilder<InitializationEvent>(
            stream: widget._controller.onInitialized,
            builder: (context, snapshot) {
              return AspectRatio(
                aspectRatio: widget.configuration.aspectRatio,
                child: widget._controller.isInitialized
                    ? VideoPlayer(widget._controller.videoPlayerController)
                    : const SizedBox(),
              );
            },
          ),
          if (widget.configuration.controlsVisible)
            Positioned.fill(
              child: PlayerControls(
                controller: widget._controller,
              ),
            ),
        ],
      ),
    );
  }
}
