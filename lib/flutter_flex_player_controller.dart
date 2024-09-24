// ignore_for_file: use_build_context_synchronously, invalid_use_of_protected_member
library flutter_flex_player;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_flex_player/controllers/NativePlayer/native_player_view.dart';
import 'package:flutter_flex_player/flutter_flex_player_method_channel.dart';
import 'package:flutter_flex_player/helpers/extensions.dart';
import 'package:flutter_flex_player/helpers/flex_player_sources.dart';
import 'package:flutter_flex_player/pages/player_builder.dart';
import 'package:get/state_manager.dart';
import 'package:http/http.dart';

import 'controllers/youtube_controller.dart';
import 'helpers/configuration.dart';
import 'helpers/enums.dart';
import 'pages/full_screen_page.dart';

export 'helpers/enums.dart';

class FlutterFlexPlayerController {
  MethodChannelFlutterFlexPlayer channel = MethodChannelFlutterFlexPlayer();

  FlutterFlexPlayerController._internal();

  // The static singleton instance
  static final FlutterFlexPlayerController _instance =
      FlutterFlexPlayerController._internal();

  // Factory constructor to return the singleton instance
  factory FlutterFlexPlayerController() {
    return _instance;
  }

  // Static getter to access the singleton instance if needed
  static FlutterFlexPlayerController get instance => _instance;

  /// Returns whether the video player is initialized.
  bool get isInitialized {
    try {
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Stream of [InitializationEvent] emitted when the video player is initialized.
  /// The stream emits whether the video player is initialized.
  final StreamController<InitializationEvent> _initializationstream =
      StreamController<InitializationEvent>.broadcast();
  StreamSink<InitializationEvent> get initializationSink =>
      _initializationstream.sink;

  Stream<InitializationEvent> get onInitialized => _initializationstream.stream;

  /// Returns the current position of the video player.
  Duration get position {
    if (isInitialized) {
      return Duration.zero;
    }
    return Duration.zero;
  }

  final Duration _previousPosition = Duration.zero;

  /// Stream of [Duration] emitted when the video player position changes.
  /// The stream emits the current position of the video player.
  final StreamController<Duration> _positionstream =
      StreamController<Duration>.broadcast();

  StreamSink<Duration> get positionSink => _positionstream.sink;

  Stream<Duration> get onPositionChanged => _positionstream.stream;

  /// Returns the duration of the video player.
  Duration get duration {
    if (isInitialized) {
      return Duration.zero;
    }
    return Duration.zero;
  }

  /// Stream of [Duration] emitted when the video player duration changes.
  /// The stream emits the duration of the video player.
  final StreamController<Duration> _durationstream =
      StreamController<Duration>.broadcast();
  StreamSink<Duration> get durationSink => _durationstream.sink;
  Stream<Duration> get onDurationChanged => _durationstream.stream;

  /// Buffer position of the video player.
  Duration get bufferedPosition {
    if (isInitialized) {
      final buffered = [];
      //  Convert the buffered position to a duration.
      if (buffered.isNotEmpty) {
        return buffered.last.end;
      }
    }
    return Duration.zero;
  }

  /// Returns whether the video player is playing.
  bool get isPlaying {
    if (isInitialized) {
      return true;
    }
    return false;
  }

  /// Stream of [PlayerState] emitted when the video player is playing.
  /// The stream emits whether the video player is playing.
  final StreamController<PlayerState> _playerstatestream =
      StreamController<PlayerState>.broadcast();

  StreamSink<PlayerState> get playerStateSink => _playerstatestream.sink;
  Stream<PlayerState> get onPlayerStateChanged => _playerstatestream.stream;

  /// Returns whether the video player is looping.
  bool get isLooping {
    // if (isInitialized) {
    //   return _videoPlayerController.value.isLooping;
    // }
    return false;
  }

  /// Returns whether the video player is muted.
  bool get isMuted {
    // if (isInitialized) {
    //   if (isNativePlayer.value) {
    //     return _nativePlayerController!.isMuted;
    //   }
    //   return _videoPlayerController.value.volume == 0;
    // }
    return false;
  }

  /// Returns the volume of the video player.
  double get volume {
    // if (isInitialized) {
    //   return _videoPlayerController.value.volume;
    // }
    return 0;
  }

  /// Returns the playback speed of the video player.
  double get playbackSpeed {
    // if (isInitialized) {
    //   return _videoPlayerController.value.playbackSpeed;
    // }
    return 0;
  }

  /// On PlayBack Speed Change Stream
  final StreamController<double> _playbackSpeedStream =
      StreamController<double>.broadcast();

  StreamSink<double> get playbackSpeedSink => _playbackSpeedStream.sink;
  Stream<double> get onPlaybackSpeedChanged => _playbackSpeedStream.stream;

  VoidCallback? listner;

  void _startListeners() {
    _stopListeners();
    // _durationstream.add(_videoPlayerController.value.duration);
    // listner = () {
    //   if (_videoPlayerController.value.hasError) {
    //     _initializationstream.add(InitializationEvent.uninitialized);
    //   }
    //   if (_videoPlayerController.value.isInitialized) {
    //     _initializationstream.add(InitializationEvent.initialized);
    //     _positionstream.add(_videoPlayerController.value.position);
    //     if (_videoPlayerController.value.hasError == false) {
    //       _previousPosition = _videoPlayerController.value.position;
    //     }
    //     _updatePlayerState();
    //     _playbackSpeedStream.add(_videoPlayerController.value.playbackSpeed);
    //   }
    // };
    // _videoPlayerController.addListener(listner!);
  }

  void _stopListeners() {
    // if (listner != null) _videoPlayerController.removeListener(listner!);
  }

  void _updatePlayerState() {
    // if (_videoPlayerController.value.isPlaying) {
    //   _playerstatestream.add(PlayerState.playing);
    // } else if (_videoPlayerController.value.isBuffering) {
    //   _playerstatestream.add(PlayerState.buffering);
    // } else if (_videoPlayerController.value.isCompleted) {
    //   _playerstatestream.add(PlayerState.ended);
    // } else if (!isPlaying) {
    //   _playerstatestream.add(PlayerState.paused);
    // }
  }

  RxList<VideoData> videosList = <VideoData>[].obs;
  FlexPlayerSource? _source;
  FlexPlayerSource? get source => _source;

  Rxn<NativePlayerView> nativePlayer = Rxn();
  final key = GlobalKey();
  Rxn<PlayerBuilder> playerBuilder = Rxn();

  /// Load the video player with the given [source].

  void load(
    FlexPlayerSource source, {
    bool autoPlay = false,
    bool loop = false,
    bool mute = false,
    double volume = 1.0,
    double playbackSpeed = 1.0,
    Duration? position,
    VoidCallback? onInitialized,
  }) async {
    configuration = configuration.copyWith(
      autoPlay: autoPlay,
      loop: loop,
      volume: volume,
      playbackSpeed: playbackSpeed,
      position: position,
      isPlaying: autoPlay,
    );
    nativePlayer.value = NativePlayerView(
      flexPlayerController: this,
    );
    playerBuilder.value = PlayerBuilder(
      controller: this,
      configuration: configuration,
      onFullScreeen: () {},
    );
    _initializationstream.add(InitializationEvent.initializing);

    if (source is YouTubeFlexPlayerSource) {
      final isNotLive =
          await FlexYoutubeController.instance.isNotLive(source.videoId);
      if (isNotLive) {
        final flexYoutubecontroller = FlexYoutubeController.instance;
        await flexYoutubecontroller
            .getVideoDetails(source.videoId)
            .then((value) {
          qualities.value = flexYoutubecontroller.videosList
              .map((e) => e.quality)
              .toSet()
              .toList();
          selectedQuality = flexYoutubecontroller.videosList.first.quality;
          channel.load(
            videoData: flexYoutubecontroller.videosList,
            autoPlay: autoPlay,
            loop: loop,
            mute: mute,
            volume: volume,
            playbackSpeed: playbackSpeed,
          );
        });
        _initializationstream.add(InitializationEvent.initialized);
        return;
      }
    }
    try {
      _source = source;

      if (source is AssetFlexPlayerSource) {
        // _videoPlayerController = VideoPlayerController.asset(source.asset);
      } else if (source is NetworkFlexPlayerSource) {
        if (source.url.endsWith('.m3u8')) {
          final response = await get(Uri.parse(source.url));
          String m3u8Content = response.body;
          // Extract stream qualities
          List<Map<String, String>> data = parseM3U8Content(m3u8Content);
          for (var element in data) {
            videosList.add(
              VideoData(
                url: element['url'] ?? "",
                quality: element['resolution'].toString().split("x").last,
              ),
            );
          }
          if (data.isEmpty) {
            videosList.add(VideoData(url: source.url, quality: 'Auto'));
          }
        } else {
          videosList.add(VideoData(url: source.url, quality: 'Auto'));
        }
        qualities.value = videosList.map((e) => e.quality).toSet().toList();
        qualities.sort((a, b) => a.compareTo(b));
        // _videoPlayerController = VideoPlayerController.networkUrl(
        //   videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
        //   Uri.parse(videosList.first.url),
        // );
      } else if (source is FileFlexPlayerSource) {
        // _videoPlayerController = VideoPlayerController.file(source.file);
      } else if (source is YouTubeFlexPlayerSource) {
        final videoId = source.videoId;
        final flexYoutubecontroller = FlexYoutubeController.instance;
        await flexYoutubecontroller.getVideoDetails(videoId).then(
          (value) {
            qualities.value = flexYoutubecontroller.videosList
                .map((e) => e.quality)
                .toSet()
                .toList();
            final streamInfo = flexYoutubecontroller.videosList.first;
            selectedQuality = flexYoutubecontroller.videosList.first.quality;
            // _videoPlayerController = VideoPlayerController.networkUrl(
            //   Uri.parse(streamInfo.url.toString()),
            // );
          },
        );
      }
      // await _videoPlayerController.initialize().then((_) async {
      //   _startListeners();
      //   onInitialized!();
      //   _videoPlayerController.setVolume(volume);
      //   _videoPlayerController.setPlaybackSpeed(playbackSpeed);
      //   _videoPlayerController.setLooping(loop);
      //   if (mute) {
      //     _videoPlayerController.setVolume(0);
      //   }
      //   await _videoPlayerController.seekTo(position ?? Duration.zero);
      //   if (autoPlay) {
      //     _videoPlayerController.play();
      //   }
      // });
    } catch (e) {
      _initializationstream.add(InitializationEvent.uninitialized);
    }
  }

  void reload() async {
    _initializationstream.add(InitializationEvent.initializing);
    try {
      // await _videoPlayerController.initialize();
      // await _videoPlayerController.seekTo(_previousPosition);
      // _positionstream.add(_previousPosition);
      // _videoPlayerController.setPlaybackSpeed(configuration.playbackSpeed);
      // _videoPlayerController.setVolume(configuration.volume);
      // _videoPlayerController.setLooping(configuration.loop);
      // if (configuration.isPlaying) {
      //   _videoPlayerController.play();
      // }
      _startListeners();
    } catch (e) {
      _initializationstream.add(InitializationEvent.uninitialized);
    }
  }

  void pause() {
    if (isInitialized) {
      configuration = configuration.copyWith(isPlaying: false);
    }
  }

  void play() {
    if (isInitialized) {
      configuration = configuration.copyWith(isPlaying: true);
    }
  }

  void seekTo(Duration position) async {
    if (isInitialized) {}
  }

  void setLooping(bool looping) {
    if (isInitialized) {
      configuration = configuration.copyWith(loop: looping);
    }
  }

  void setMute(bool mute) {
    if (isInitialized) {
      configuration = configuration.copyWith(volume: mute ? 0 : 1);
    }
  }

  void setPlaybackSpeed(double speed) {
    if (isInitialized) {
      configuration = configuration.copyWith(playbackSpeed: speed);
    }
  }

  void setVolume(double volume) {
    if (isInitialized) {
      configuration = configuration.copyWith(volume: volume);
    }
  }

  void stop() {
    if (isInitialized) {
      _playerstatestream.add(PlayerState.stopped);
      configuration = configuration.copyWith(isPlaying: false);
    }
  }

  void dispose() {
    _initializationstream.close();
    _positionstream.close();
    _durationstream.close();
    _playerstatestream.close();
    _stopListeners();
    channel.dispose();
  }

  RxBool isFullScreen = false.obs;

  FlexPlayerConfiguration configuration = FlexPlayerConfiguration();

  void enterFullScreen(BuildContext context) async {
    isFullScreen.value = true;

    Navigator.push(
      context,
      PageRouteBuilder<dynamic>(
        pageBuilder: (BuildContext context, _, __) => FullScreenView(
          controller: this,
          configuration: configuration,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOut,
                ),
              ),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void exitFullScreen(BuildContext context) async {
    isFullScreen.value = false;
    Navigator.pop(context);
  }

  final List<String> _speeds = [
    '0.25x',
    '0.5x',
    '0.75x',
    'Normal',
    '1.25x',
    '1.5x',
    '1.75x',
    '2x',
  ];

  void showSpeedDialog(BuildContext context) {
    if (context.orientation == Orientation.landscape) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            title: const Text(
              'Playback Speed',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: _speeds
                    .map(
                      (speed) => InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          final speedValue = double.parse(speed == "Normal"
                              ? "1.0"
                              : speed.replaceAll('x', ''));
                          setPlaybackSpeed(speedValue);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 5,
                            horizontal: 10,
                          ),
                          child: Row(
                            children: [
                              playbackSpeed ==
                                      double.parse(speed == "Normal"
                                          ? "1.0"
                                          : speed.replaceAll('x', ''))
                                  ? const Icon(
                                      Icons.check_box_rounded,
                                      color: Colors.blue,
                                    )
                                  : const Icon(
                                      Icons.check_box_outline_blank,
                                      color: Colors.grey,
                                    ),
                              10.widthBox,
                              Text(speed),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          );
        },
      );
    } else {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(10),
          ),
        ),
        isScrollControlled: true,
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Playback Speed',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _speeds.length,
                  itemBuilder: (context, index) {
                    final speed = _speeds[index];
                    return InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        final speedValue = double.parse(speed == "Normal"
                            ? "1.0"
                            : speed.replaceAll('x', ''));
                        setPlaybackSpeed(speedValue);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 2,
                          horizontal: 5,
                        ),
                        child: Row(
                          children: [
                            playbackSpeed ==
                                    double.parse(speed == "Normal"
                                        ? "1.0"
                                        : speed.replaceAll('x', ''))
                                ? const Icon(
                                    Icons.check_box_rounded,
                                    color: Colors.blue,
                                  )
                                : const Icon(
                                    Icons.check_box_outline_blank,
                                    color: Colors.grey,
                                  ),
                            10.widthBox,
                            Expanded(child: Text(speed)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      );
    }
  }

  String selectedQuality = 'Auto';

  /// On Quality Change Stream
  final StreamController<String> _qualityStream =
      StreamController<String>.broadcast();
  Stream<String> get onQualityChanged => _qualityStream.stream;

  RxList<String> qualities = <String>[].obs;

  void showQualityDialog(BuildContext context) {
    if (qualities.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No qualities available'),
        ),
      );
      return;
    }
    if (context.orientation == Orientation.landscape) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            title: const Text(
              'Quality',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Obx(() {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // InkWell(
                    //   onTap: () {
                    //     Navigator.pop(context);
                    //     if (configuration.autoQuality) {
                    //       configuration = configuration.copyWith(
                    //         autoQuality: false,
                    //       );
                    //     } else {
                    //       configuration = configuration.copyWith(
                    //         autoQuality: true,
                    //       );
                    //     }
                    //     startAutoQuality();
                    //   },
                    //   child: Padding(
                    //     padding: const EdgeInsets.symmetric(
                    //       vertical: 5,
                    //       horizontal: 10,
                    //     ),
                    //     child: Row(
                    //       children: [
                    //         configuration.autoQuality
                    //             ? const Icon(
                    //                 Icons.check_box_rounded,
                    //                 color: Colors.blue,
                    //               )
                    //             : const Icon(
                    //                 Icons.check_box_outline_blank,
                    //                 color: Colors.grey,
                    //               ),
                    //         10.widthBox,
                    //         const Expanded(child: Text("Auto")),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    ...qualities.value.map(
                      (quality) => InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          selectedQuality = quality;
                          _qualityStream.add(quality);
                          setQuality(quality);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 5,
                            horizontal: 10,
                          ),
                          child: Row(
                            children: [
                              selectedQuality == quality
                                  ? const Icon(
                                      Icons.check_box_rounded,
                                      color: Colors.blue,
                                    )
                                  : const Icon(
                                      Icons.check_box_outline_blank,
                                      color: Colors.grey,
                                    ),
                              10.widthBox,
                              Text(quality),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              );
            }),
          );
        },
      );
    } else {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(10),
          ),
        ),
        isScrollControlled: true,
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quality',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(),
                Obx(() {
                  return Column(
                    children: [
                      // InkWell(
                      //   onTap: () {
                      //     Navigator.pop(context);
                      //     if (configuration.autoQuality) {
                      //       configuration = configuration.copyWith(
                      //         autoQuality: false,
                      //       );
                      //     } else {
                      //       configuration = configuration.copyWith(
                      //         autoQuality: true,
                      //       );
                      //     }
                      //     startAutoQuality();
                      //   },
                      //   child: Padding(
                      //     padding: const EdgeInsets.symmetric(
                      //       vertical: 2,
                      //       horizontal: 5,
                      //     ),
                      //     child: Row(
                      //       children: [
                      //         configuration.autoQuality
                      //             ? const Icon(
                      //                 Icons.check_box_rounded,
                      //                 color: Colors.blue,
                      //               )
                      //             : const Icon(
                      //                 Icons.check_box_outline_blank,
                      //                 color: Colors.grey,
                      //               ),
                      //         10.widthBox,
                      //         const Expanded(child: Text("Auto")),
                      //       ],
                      //     ),
                      //   ),
                      // ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: qualities.value.length,
                        itemBuilder: (context, index) {
                          final quality = qualities[index];
                          return InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              selectedQuality = quality;
                              _qualityStream.add(quality);
                              setQuality(quality);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 2,
                                horizontal: 5,
                              ),
                              child: Row(
                                children: [
                                  selectedQuality == quality
                                      ? const Icon(
                                          Icons.check_box_rounded,
                                          color: Colors.blue,
                                        )
                                      : const Icon(
                                          Icons.check_box_outline_blank,
                                          color: Colors.grey,
                                        ),
                                  10.widthBox,
                                  Expanded(child: Text(quality)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                }),
              ],
            ),
          );
        },
      );
    }
  }

  void setQuality(String quality) async {
    if (source is YouTubeFlexPlayerSource) {
      final flexYoutubecontroller = FlexYoutubeController.instance;
      final video = flexYoutubecontroller.videosList.firstWhere(
        (element) => element.quality == quality,
      );
      final url = video.url.toString();
      // _videoPlayerController = VideoPlayerController.networkUrl(
      //   Uri.parse(url),
      // );
      reload();
    }
    if (source is NetworkFlexPlayerSource) {
      final video = videosList.firstWhere(
        (element) => element.quality == quality,
      );
      final url = video.url.toString();
      // _videoPlayerController = VideoPlayerController.networkUrl(
      //   Uri.parse(url),
      // );
      reload();
    }
  }
}
