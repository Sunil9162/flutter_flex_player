import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_flex_player/flutter_flex_player.dart';
import 'package:flutter_flex_player/flutter_flex_player_controller.dart';

class VideoPlayerScreen extends StatefulWidget {
  final FlexPlayerSource? source;
  const VideoPlayerScreen({super.key, this.source});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late FlutterFlexPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = FlutterFlexPlayerController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.load(
        // NetworkFlexPlayerSource(
        //   // 'https://live-par-2-abr.livepush.io/vod/bigbuckbunnyclip.mp4',
        //   // "https://videos.pexels.com/video-files/4115454/4115454-uhd_2560_1440_30fps.mp4",
        //   // "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/VolkswagenGTIReview.mp4",
        //   "https://moctobpltc-i.akamaihd.net/hls/live/571329/eight/playlist.m3u8",
        // ),
        PlayerSources.network(
            "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8"),

        // widget.source ?? PlayerSources.youtube(videoId: "zqDLrRsTplk"),
        autoPlay: true,
        loop: true,
      );
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: SystemUiOverlay.values,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VideoPlayerScreen'),
      ),
      body: Column(
        children: [
          FlutterFlexPlayer(
            _controller,
            // aspectRatio: 16 / 9,
          ),
          const SizedBox(
            height: 50,
          ),
        ],
      ),
    );
  }
}
