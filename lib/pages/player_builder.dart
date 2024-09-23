import 'package:flutter/material.dart';
import 'package:flutter_flex_player/controls/player_controls.dart';
import 'package:flutter_flex_player/flutter_flex_player_controller.dart';
import 'package:flutter_flex_player/helpers/configuration.dart';
import 'package:get/get.dart';
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
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  final Rx<InitializationEvent> _initializationEvent = Rx<InitializationEvent>(
    InitializationEvent.uninitialized,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget._controller.onInitialized.listen((event) {
      _initializationEvent.value = event;
    });
  }

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   super.didChangeAppLifecycleState(state);
  //   if (state == AppLifecycleState.paused) {
  //     widget._controller.pause();
  //   } else if (state == AppLifecycleState.resumed) {
  //     widget._controller.play();
  //     PlayerController.instance.isControlsVisible.value = true;
  //   }
  // }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RepaintBoundary(
      child: PopScope(
        canPop: !widget._controller.isFullScreen,
        onPopInvokedWithResult: (didPop, result) {
          if (widget._controller.isFullScreen) {
            widget._controller.exitFullScreen(context);
          }
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            const SizedBox.expand(),
            Hero(
              tag: 'player',
              child: Obx(
                () {
                  return AspectRatio(
                    aspectRatio: widget.configuration.aspectRatio,
                    child: widget._controller.isInitialized &&
                            widget._controller.isNativePlayer.value == false
                        ? VideoPlayer(widget._controller.videoPlayerController)
                        : widget._controller.isNativePlayer.value
                            ? widget._controller.nativePlayer
                            : const SizedBox(),
                  );
                },
              ),
            ),
            if (widget.configuration.controlsVisible)
              Positioned.fill(
                child: PlayerControls(
                  controller: widget._controller,
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
