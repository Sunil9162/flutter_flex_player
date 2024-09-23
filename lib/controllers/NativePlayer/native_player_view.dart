import 'package:flutter/material.dart';
import 'package:flutter_flex_player/controllers/NativePlayer/native_player_controller.dart';

class NativePlayerView extends StatefulWidget {
  final NativePlayerController controller;
  const NativePlayerView({super.key, required this.controller});

  @override
  State<NativePlayerView> createState() => _NativePlayerViewState();
}

class _NativePlayerViewState extends State<NativePlayerView>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.controller.channel.playerView;
  }

  @override
  bool get wantKeepAlive => true;
}
