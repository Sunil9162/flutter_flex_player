// ignore_for_file: use_build_context_synchronously, invalid_use_of_protected_member
library flutter_flex_player;

import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_flex_player/flutter_flex_player_controller.dart';
import 'package:flutter_flex_player/flutter_flex_player_method_channel.dart';
import 'package:flutter_flex_player/helpers/configuration.dart';
import 'package:flutter_flex_player/helpers/exceptions.dart';
import 'package:flutter_flex_player/helpers/extensions.dart';
import 'package:flutter_flex_player/helpers/flex_player_sources.dart';
import 'package:flutter_flex_player/helpers/streams.dart';
import 'package:flutter_flex_player/pages/player_builder.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:get/state_manager.dart';
import 'package:http/http.dart';
import 'package:rxdart/rxdart.dart' as dart;
import 'package:rxdart/rxdart.dart';

import 'controllers/youtube_controller.dart';
import 'helpers/enums.dart';

export 'package:youtube_explode_dart/youtube_explode_dart.dart';

export 'helpers/enums.dart';

part './controllers/NativePlayer/native_player_view.dart';
part './pages/full_screen_page.dart';

class FlutterFlexPlayerController {
  final MethodChannelFlutterFlexPlayer _channel =
      MethodChannelFlutterFlexPlayer();
  StreamSubscription? eventStreamSubScription;
  final _completer = Completer();

  FlutterFlexPlayerController() {
    _channel.setupChannels(this);
    nativePlayer.value = RepaintBoundary(
      child: _NativePlayerView(
        flexPlayerController: this,
        onPlatformViewCreated: () {
          _completer.complete();
        },
      ),
    );
  }

  startListner() {
    try {
      _bufferstream.add(Duration.zero);
      _positionstream.add(Duration.zero);
      _durationstream.add(Duration.zero);
      eventStreamSubScription?.cancel();
      _playbackDurationstreamSubscription?.cancel();
      eventStreamSubScription =
          _channel.eventChannel.receiveBroadcastStream().listen(
        (event) {
          parseEvent(event);
        },
        onError: (value) {
          log(value.toString());
        },
      );
      _playbackDurationstreamSubscription = dart.Rx.combineLatest3<Duration,
          Duration, Duration, PlayBackDurationStream>(
        _durationstream.stream,
        _positionstream.stream,
        _bufferstream.stream,
        (a, b, c) =>
            PlayBackDurationStream(duration: a, position: b, buffered: c),
      ).listen(
        (event) {
          _playbackDurationStream.add(event);
        },
      );
    } catch (e) {
      disposePlayer();
    }
  }

  StreamSubscription<PlayBackDurationStream>?
      _playbackDurationstreamSubscription;

  final BehaviorSubject<PlayBackDurationStream> _playbackDurationStream =
      BehaviorSubject<PlayBackDurationStream>();
  Stream<PlayBackDurationStream> get playbackDurationStream =>
      _playbackDurationStream.stream;

  parseEvent(dynamic event) {
    try {
      final data = Map<String, dynamic>.from(jsonDecode(event));
      if (data.containsKey('state')) {
        final state = _mapStateFromString(data['state']);
        playerStateSink.add(state);
        isPlaying = state == PlayerState.playing;
      }
      if (data.containsKey("width")) {
        final width = data['width'];
        final height = data['height'];
        final ratio = width / height;
        _aspectRatiosink.add(ratio);
        playerAspectRatio.value = double.parse(ratio.toString());
      }
      if (data.containsKey('duration') || data.containsKey("position")) {
        final duration = Duration(milliseconds: data['duration']);
        final position = Duration(milliseconds: data['position']);
        final bufferedPosition = Duration(milliseconds: data['buffered'] ?? 0);
        durationSink.add(duration);
        this.duration = duration;
        positionSink.add(position);
        this.position = position;
        bufferSink.add(bufferedPosition);
      }
      if (data.containsKey('initializationEvent')) {
        final initalization =
            _mapInitializationEventFromString(data['initializationEvent']);
        _initializationsink.add(initalization);
        isInitialized = initalization == InitializationEvent.initialized;
      }
    } catch (e) {
      log("Error: $e");
      disposePlayer();
    }
  }

  InitializationEvent _mapInitializationEventFromString(String event) {
    switch (event) {
      case 'initializing':
        return InitializationEvent.initializing;
      case 'initialized':
        return InitializationEvent.initialized;
      case 'uninitialized':
        return InitializationEvent.uninitialized;
      default:
        return InitializationEvent.uninitialized;
    }
  }

  PlayerState _mapStateFromString(String state) {
    switch (state) {
      case 'stopped':
        return PlayerState.stopped;
      case 'buffering':
        return PlayerState.buffering;
      case 'ready':
        return PlayerState.ready;
      case 'playing':
        return PlayerState.playing;
      case 'paused':
        return PlayerState.paused;
      case 'ended':
        return PlayerState.ended;
      default:
        return PlayerState.stopped;
    }
  }

  /// Returns whether the video player is initialized.
  bool isInitialized = false;

  /// Stream of [InitializationEvent] emitted when the video player is initialized.
  /// The stream emits whether the video player is initialized.
  final BehaviorSubject<InitializationEvent> _initializationstream =
      BehaviorSubject<InitializationEvent>();
  StreamSink<InitializationEvent> get _initializationsink =>
      _initializationstream.sink;
  Stream<InitializationEvent> get onInitialized => _initializationstream.stream;

  /// Stream of [VideoData]
  final BehaviorSubject<VideoData> _currentPlayingStream =
      BehaviorSubject<VideoData>();
  StreamSink<VideoData> get _currentPlayingSink => _currentPlayingStream.sink;
  Stream<VideoData> get currentPlayingStream => _currentPlayingStream.stream;

  VideoData? getCurrentPlaying;

  /// Returns the current position of the video player.
  Duration position = Duration.zero;

  /// Returns the duration of the video player.
  Duration duration = Duration.zero;

  // final Duration _previousPosition = Duration.zero;

  /// Stream of [Duration] emitted when the video player position changes.
  /// The stream emits the current position of the video player.
  final _positionstream = BehaviorSubject<Duration>.seeded(Duration.zero);
  StreamSink<Duration> get positionSink => _positionstream.sink;
  Stream<Duration> get onPositionChanged => _positionstream.stream;

  final _aspectRatiostream = BehaviorSubject<double>.seeded(16 / 0);
  StreamSink<double> get _aspectRatiosink => _aspectRatiostream.sink;
  Stream<double> get aspectRatioStream => _aspectRatiostream.stream;
  RxDouble playerAspectRatio = (16 / 9).obs;

  /// Stream of [Duration] emitted when the video player duration changes.
  /// The stream emits the duration of the video player.
  final _durationstream = BehaviorSubject<Duration>.seeded(Duration.zero);
  StreamSink<Duration> get durationSink => _durationstream.sink;
  Stream<Duration> get onDurationChanged => _durationstream.stream;

  final _bufferstream = BehaviorSubject<Duration>.seeded(Duration.zero);
  StreamSink<Duration> get bufferSink => _bufferstream.sink;
  Stream<Duration> get onBufferChanged => _bufferstream.stream;

  /// Stream of [PlayerState] emitted when the video player is playing.
  /// The stream emits whether the video player is playing.
  final BehaviorSubject<PlayerState> _playerstatestream =
      BehaviorSubject<PlayerState>();
  StreamSink<PlayerState> get playerStateSink => _playerstatestream.sink;
  Stream<PlayerState> get onPlayerStateChanged => _playerstatestream.stream;

  /// Returns whether the video player is playing.
  bool isPlaying = false;

  /// Returns whether the video player is looping.
  bool get isLooping {
    // if (isInitialized) {
    //   return _videoPlayerController.value.isLooping;
    // }
    return false;
  }

  /// Returns whether the video player is muted.
  bool get isMuted {
    if (isInitialized) {
      return volume == 0;
    }
    return false;
  }

  /// Returns the volume of the video player.
  double volume = 0;

  /// Returns the playback speed of the video player.
  double playbackSpeed = 0;

  /// On PlayBack Speed Change Stream
  final BehaviorSubject<double> _playbackSpeedStream =
      BehaviorSubject<double>();

  StreamSink<double> get playbackSpeedSink => _playbackSpeedStream.sink;
  Stream<double> get onPlaybackSpeedChanged => _playbackSpeedStream.stream;

  VoidCallback? listner;

  RxList<VideoData> videosList = <VideoData>[].obs;
  FlexPlayerSource? _source;
  FlexPlayerSource? get source => _source;

  Rxn<Widget> nativePlayer = Rxn();
  final key = GlobalKey();
  FileType type = FileType.file;

  /// Load the video player with the given [source].

  Future<void> load(
    FlexPlayerSource source, {
    bool autoPlay = false,
    bool loop = false,
    bool mute = false,
    double volume = 1.0,
    double playbackSpeed = 1.0,
    Duration? position,
    VoidCallback? onInitialized,
  }) async {
    _channel.setupChannels(this);
    await _completer.future;
    configuration = configuration.copyWith(
      autoPlay: autoPlay,
      loop: loop,
      volume: volume,
      playbackSpeed: playbackSpeed,
      position: position,
      isPlaying: autoPlay,
    );
    this.playbackSpeed = playbackSpeed;
    this.volume = volume;
    _initializationstream.add(InitializationEvent.initializing);
    playerStateSink.add(PlayerState.ended);
    try {
      _source = source;
      if (source is AssetFlexPlayerSource) {
        throw Exception("Asset source is currently not supported");
      } else if (source is NetworkFlexPlayerSource) {
        type = FileType.url;
        if (source.url.endsWith('.m3u8')) {
          final response = await get(Uri.parse(source.url));
          String m3u8Content = response.body;
          // Extract stream qualities
          List<Map<String, String>> data = parseM3U8Content(m3u8Content);
          for (var element in data) {
            videosList.add(
              VideoData(
                url: (element['url'] ?? "").toFullUrl(source.url),
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
      } else if (source is FileFlexPlayerSource) {
        type = FileType.file;
        videosList.add(
          VideoData(
            url: source.file.path,
            quality: 'Auto',
          ),
        );
      } else if (source is YouTubeFlexPlayerSource) {
        final videoId = source.videoId;
        final flexYoutubecontroller = FlexYoutubeController.instance;
        final isNotLive =
            await FlexYoutubeController.instance.isNotLive(source.videoId);
        try {
          if (isNotLive) {
            await flexYoutubecontroller
                .getVideoDetails(source.videoId)
                .then((value) {
              qualities.value = flexYoutubecontroller.videosList
                  .map((e) => e.quality)
                  .toSet()
                  .toList();
              videosList.addAll(flexYoutubecontroller.videosList.value);
            });
            type = FileType.youtube;
          } else {
            await flexYoutubecontroller
                .getVideoDetails(videoId, isLive: true)
                .then(
              (value) {
                qualities.value = flexYoutubecontroller.videosList
                    .map((e) => e.quality)
                    .toSet()
                    .toList();
                videosList.addAll(flexYoutubecontroller.videosList.value);
              },
            );
            type = FileType.url;
          }
        } catch (e) {
          _initializationstream.add(InitializationEvent.uninitialized);
          rethrow;
        }
      }
      final ids = videosList.map((e) => e.quality).toSet();
      videosList.retainWhere((x) => ids.remove(x.quality));
      videosList.sort((a, b) {
        return int.parse(a.quality.split("p").first) -
            int.parse(b.quality.split("p").first);
      });
      qualities.value = videosList.map((e) => e.quality).toSet().toList();
      startListner();
      final video =
          videosList.firstWhereOrNull((e) => e.quality.contains("360")) ??
              videosList.first;
      selectedQuality = video.quality;
      _currentPlayingSink.add(video);
      getCurrentPlaying = video;
      await _channel.load(
        videoData: videosList,
        index: videosList.indexWhere((e) => e.quality == video.quality),
        autoPlay: autoPlay,
        loop: loop,
        mute: mute,
        volume: volume,
        playbackSpeed: playbackSpeed,
        type: type,
      );
    } on Exception catch (e) {
      _initializationstream.add(InitializationEvent.uninitialized);
      log("Error in Loading: $e");
      throw PlayerError(e.toString());
    }
  }

  void pause() {
    if (isInitialized) {
      configuration = configuration.copyWith(isPlaying: false);
      _channel.pause();
    }
  }

  void play() {
    if (isInitialized) {
      configuration = configuration.copyWith(isPlaying: true);
      _channel.play();
    }
  }

  void seekTo(Duration position) async {
    if (isInitialized) {
      _channel.seekTo(position);
    }
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
      playbackSpeed = speed;
      configuration = configuration.copyWith(playbackSpeed: speed);
      _channel.setPlaybackSpeed(speed);
    }
  }

  void setVolume(double volume) {
    if (isInitialized) {
      configuration = configuration.copyWith(volume: volume);
      _channel.setVolume(volume);
    }
  }

  void stop() {
    if (isInitialized) {
      configuration = configuration.copyWith(isPlaying: false);
      _channel.stop();
    }
  }

  // @override
  // void onClose() {
  //   disposePlayer();
  //   super.onClose();
  // }

  disposePlayer() {
    _channel.dispose();
    _durationstream.close();
    _positionstream.close();
    _bufferstream.close();
    _qualityStream.close();
    _playbackSpeedStream.close();
    eventStreamSubScription?.cancel();
    _playbackDurationstreamSubscription?.cancel();
  }

  RxBool isFullScreen = false.obs;

  FlexPlayerConfiguration configuration = FlexPlayerConfiguration();

  void enterFullScreen(BuildContext context) async {
    isFullScreen.value = true;

    Navigator.push(
      context,
      PageRouteBuilder<dynamic>(
        pageBuilder: (BuildContext context, _, __) => _FullScreenView(
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
  final BehaviorSubject<String> _qualityStream = BehaviorSubject<String>();
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
    final video = videosList.firstWhereOrNull((e) => e.quality == quality);
    if (video == null) {
      throw Exception("No video found for format");
    }
    _channel.setQuality(quality);
    _currentPlayingSink.add(video);
    getCurrentPlaying = video;
  }
}
