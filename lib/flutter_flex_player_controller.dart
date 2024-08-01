import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_flex_player/helpers/flex_player_sources.dart';
import 'package:video_player/video_player.dart';

import 'flutter_flex_player_abstract.dart';
import 'helpers/enums.dart';

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

  void _startListeners() {
    _videoPlayerController.addListener(() async {
      if (_videoPlayerController.value.hasError) {
        _initializationstream.add(InitializationEvent.uninitialized);
      }
      if (_videoPlayerController.value.isInitialized) {
        _initializationstream.add(InitializationEvent.initialized);
        if ((await _durationstream.stream.last) !=
            _videoPlayerController.value.duration) {
          _durationstream.add(_videoPlayerController.value.duration);
        }
        _positionstream.add(_videoPlayerController.value.position);
        _updatePlayerState();
      }
    });
  }

  void _updatePlayerState() {
    if (_videoPlayerController.value.isPlaying) {
      _playerstatestream.add(PlayerState.playing);
    } else {
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
    // TODO: implement pause
  }

  @override
  void play() {
    // TODO: implement play
  }

  @override
  void seekTo(Duration position) {
    // TODO: implement seekTo
  }

  @override
  void setLooping(bool looping) {
    // TODO: implement setLooping
  }

  @override
  void setMute(bool mute) {
    // TODO: implement setMute
  }

  @override
  void setPlaybackSpeed(double speed) {
    // TODO: implement setPlaybackSpeed
  }

  @override
  void setVolume(double volume) {
    // TODO: implement setVolume
  }

  @override
  void stop() {
    // TODO: implement stop
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _initializationstream.close();
    _positionstream.close();
    _durationstream.close();
    _playerstatestream.close();
  }
}
