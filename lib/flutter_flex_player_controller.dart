import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_flex_player/helpers/flex_player_sources.dart';
import 'package:video_player/video_player.dart';

import 'flutter_flex_player_abstract.dart';
import 'helpers/enums.dart';
import 'pages/full_screen_page.dart';

class FlutterFlexPlayerController extends FlutterFlexPlayerAbstract {
  factory FlutterFlexPlayerController() {
    return _instance;
  }
  FlutterFlexPlayerController._internal();

  static final FlutterFlexPlayerController _instance =
      FlutterFlexPlayerController._internal();

  static FlutterFlexPlayerController get instance => _instance;

  late VideoPlayerController _videoPlayerController;

  VideoPlayerController? get videoPlayerController =>
      _videoPlayerController.value.isInitialized
          ? _videoPlayerController
          : null;

  /// Returns whether the video player is initialized.
  bool get isInitialized => _videoPlayerController.value.isInitialized;

  /// Stream of [InitializationEvent] emitted when the video player is initialized.
  /// The stream emits whether the video player is initialized.
  final StreamController<InitializationEvent> _initializationstream =
      StreamController<InitializationEvent>.broadcast();

  Stream<InitializationEvent> get onInitialized => _initializationstream.stream;

  /// Returns the current position of the video player.
  Duration get position {
    if (isInitialized) {
      return _videoPlayerController.value.position;
    }
    return Duration.zero;
  }

  /// Stream of [Duration] emitted when the video player position changes.
  /// The stream emits the current position of the video player.
  final StreamController<Duration> _positionstream =
      StreamController<Duration>.broadcast();

  Stream<Duration> get onPositionChanged => _positionstream.stream;

  /// Returns the duration of the video player.
  Duration get duration {
    if (isInitialized) {
      return _videoPlayerController.value.duration;
    }
    return Duration.zero;
  }

  /// Stream of [Duration] emitted when the video player duration changes.
  /// The stream emits the duration of the video player.
  final StreamController<Duration> _durationstream =
      StreamController<Duration>.broadcast();

  Stream<Duration> get onDurationChanged => _durationstream.stream;

  /// Buffer position of the video player.
  Duration get bufferedPosition {
    if (isInitialized) {
      final buffered = _videoPlayerController.value.buffered;
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
      return _videoPlayerController.value.isPlaying;
    }
    return false;
  }

  /// Stream of [PlayerState] emitted when the video player is playing.
  /// The stream emits whether the video player is playing.
  final StreamController<PlayerState> _playerstatestream =
      StreamController<PlayerState>.broadcast();

  Stream<PlayerState> get onPlayerStateChanged => _playerstatestream.stream;

  /// Returns whether the video player is looping.
  bool get isLooping {
    if (isInitialized) {
      return _videoPlayerController.value.isLooping;
    }
    return false;
  }

  /// Returns whether the video player is muted.
  bool get isMuted {
    if (isInitialized) {
      return _videoPlayerController.value.volume == 0;
    }
    return false;
  }

  /// Returns the volume of the video player.
  double get volume {
    if (isInitialized) {
      return _videoPlayerController.value.volume;
    }
    return 0;
  }

  /// Returns the playback speed of the video player.
  double get playbackSpeed {
    if (isInitialized) {
      return _videoPlayerController.value.playbackSpeed;
    }
    return 0;
  }

  VoidCallback? listner;

  void _startListeners() {
    _durationstream.add(_videoPlayerController.value.duration);
    listner = () async {
      if (_videoPlayerController.value.hasError) {
        _initializationstream.add(InitializationEvent.uninitialized);
      }
      if (_videoPlayerController.value.isInitialized) {
        _initializationstream.add(InitializationEvent.initialized);

        _positionstream.add(_videoPlayerController.value.position);
        _updatePlayerState();
      }
    };
    _videoPlayerController.addListener(listner!);
  }

  void _stopListeners() {
    if (listner != null) _videoPlayerController.removeListener(listner!);
  }

  double aspectRatio = 16 / 9;

  void _updatePlayerState() {
    if (_videoPlayerController.value.isPlaying) {
      _playerstatestream.add(PlayerState.playing);
    } else if (_videoPlayerController.value.isBuffering) {
      _playerstatestream.add(PlayerState.buffering);
    } else if (_videoPlayerController.value.isCompleted) {
      _playerstatestream.add(PlayerState.ended);
    } else if (!isPlaying) {
      _playerstatestream.add(PlayerState.paused);
    }
  }

  @override
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
    _initializationstream.add(InitializationEvent.initializing);
    try {
      if (source is AssetFlexPlayerSource) {
        _videoPlayerController = VideoPlayerController.asset(source.asset);
      } else if (source is NetworkFlexPlayerSource) {
        _videoPlayerController = VideoPlayerController.networkUrl(
          Uri.parse(source.url),
        );
      } else if (source is FileFlexPlayerSource) {
        _videoPlayerController = VideoPlayerController.file(source.file);
      } else if (source is YouTubeFlexPlayerSource) {
        // _videoPlayerController = VideoPlayerController.networkUrl(
        //   Uri.parse('https://www.youtube.com/watch?v=${source.videoId}'),
        // );
        throw UnimplementedError('YouTubeFlexPlayerSource is not implemented.');
      }
      await _videoPlayerController.initialize().then((_) async {
        _startListeners();
        if (onInitialized != null) {
          onInitialized();
        }
        _videoPlayerController.setVolume(volume);
        _videoPlayerController.setPlaybackSpeed(playbackSpeed);
        _videoPlayerController.setLooping(loop);
        if (mute) {
          _videoPlayerController.setVolume(0);
        }
        if (position != null) {
          await _videoPlayerController.seekTo(position);
        }
        if (autoPlay) {
          _videoPlayerController.play();
        }
      });
    } catch (e) {
      _initializationstream.add(InitializationEvent.uninitialized);
    }
  }

  @override
  void pause() {
    if (isInitialized) {
      _videoPlayerController.pause();
    }
  }

  @override
  void play() {
    if (isInitialized) {
      _videoPlayerController.play();
    }
  }

  @override
  void seekTo(Duration position) {
    if (isInitialized) {
      _videoPlayerController.seekTo(position);
    }
  }

  @override
  void setLooping(bool looping) {
    if (isInitialized) {
      _videoPlayerController.setLooping(looping);
    }
  }

  @override
  void setMute(bool mute) {
    if (isInitialized) {
      _videoPlayerController.setVolume(mute ? 0 : 1);
    }
  }

  @override
  void setPlaybackSpeed(double speed) {
    if (isInitialized) {
      _videoPlayerController.setPlaybackSpeed(speed);
    }
  }

  @override
  void setVolume(double volume) {
    if (isInitialized) {
      _videoPlayerController.setVolume(volume);
    }
  }

  @override
  void stop() {
    if (isInitialized) {
      _videoPlayerController.pause();
      _videoPlayerController.seekTo(Duration.zero);
      _playerstatestream.add(PlayerState.stopped);
    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _initializationstream.close();
    _positionstream.close();
    _durationstream.close();
    _playerstatestream.close();
    _stopListeners();
  }

  bool _isFullScreen = false;

  bool get isFullScreen => _isFullScreen;

  @override
  void enterFullScreen(BuildContext context) async {
    _isFullScreen = true;
    await Navigator.push(
      context,
      PageRouteBuilder<dynamic>(
        fullscreenDialog: true,
        pageBuilder: (BuildContext context, _, __) => const FullScreenView(),
        reverseTransitionDuration: const Duration(milliseconds: 400),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(
          opacity: animation,
          child: child,
        ),
      ),
    );
    _isFullScreen = false;
  }

  @override
  void exitFullScreen(BuildContext context) {
    _isFullScreen = false;
    Navigator.of(context).pop();
  }
}
