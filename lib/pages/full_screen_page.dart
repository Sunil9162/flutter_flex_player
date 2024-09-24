// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_flex_player/helpers/configuration.dart';
import 'package:flutter_flex_player/pages/player_builder.dart';

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
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
      overlays: [],
    );
  }

  @override
  void dispose() {
    widget.controller.isFullScreen.value = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
        SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.manual,
          overlays: SystemUiOverlay.values,
        );
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: PlayerBuilder(
          controller: widget.controller,
          configuration: widget.configuration,
        ),
      ),
    );
  }
}
