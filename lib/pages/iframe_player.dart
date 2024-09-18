import 'package:flutter/material.dart';

class IframePlayer extends StatefulWidget {
  const IframePlayer({super.key});

  @override
  State<IframePlayer> createState() => _IframePlayerState();
}

class _IframePlayerState extends State<IframePlayer> {
  // late WebViewController _controller;
  // final playerController = PlayerController.instance;

  // @override
  // void initState() {
  //   super.initState();
  //   _controller = WebViewController()
  //     ..loadRequest(
  //       Uri.parse(
  //         'https://www.youtube.com/embed/${(playerController.player.source as YouTubeFlexPlayerSource).videoId}',
  //       ),
  //     );
  // }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
