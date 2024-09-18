// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
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
