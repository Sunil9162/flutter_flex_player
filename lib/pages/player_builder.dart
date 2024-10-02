library flutter_flex_player;

import 'package:flutter/material.dart';
import 'package:flutter_flex_player/controls/player_controller.dart';
import 'package:flutter_flex_player/controls/player_controls.dart';
import 'package:flutter_flex_player/flutter_flex_player_controller.dart';
import 'package:flutter_flex_player/helpers/configuration.dart';
import 'package:get/get.dart';

class PlayerBuilder extends StatefulWidget {
  final FlutterFlexPlayerController _controller;
  final FlexPlayerConfiguration configuration;
  final VoidCallback? onFullScreeen;
  const PlayerBuilder({
    super.key,
    required FlutterFlexPlayerController controller,
    required this.configuration,
    this.onFullScreeen,
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
    super.build(context);
    return Stack(
      alignment: Alignment.center,
      children: [
        const SizedBox.expand(),
        Obx(() {
          return Center(
            child: AspectRatio(
              aspectRatio: widget.configuration.aspectRatio,
              child: widget._controller.nativePlayer.value ?? const SizedBox(),
            ),
          );
        }),
        if (widget.configuration.controlsVisible)
          Positioned.fill(
            child: PlayerControls(
              controller: widget._controller,
              onFullScreeen: () {
                if (widget.onFullScreeen != null) {
                  widget.onFullScreeen!();
                }
              },
            ),
          ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
