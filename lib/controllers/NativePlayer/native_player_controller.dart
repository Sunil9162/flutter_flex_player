library flutter_flex_player;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_flex_player/controllers/youtube_controller.dart';
import 'package:flutter_flex_player/flutter_flex_player_controller.dart';

part 'native_player_channel.dart';

class NativePlayerController {
  final channel = _NativePlayerChannel();
  final _flexPlayerController = FlutterFlexPlayerController.instance;

  static NativePlayerController get instance => NativePlayerController();
  factory NativePlayerController() => NativePlayerController._();
  NativePlayerController._() {
    channel.eventChannel.receiveBroadcastStream().listen((event) {
      parseEvent(event);
    });
  }

  bool get isMuted => false;
  bool get isPlaying => false;
  bool get isLooping => false;

  set isMuted(bool value) {}
  set isLooping(bool value) {}
  set isPlaying(bool value) {}

  parseEvent(event) {
    final Map<String, dynamic> data = Map<String, dynamic>.from(event);
    final String type = data['type'];
    if (type == "initialization") {
      final InitializationEvent initializationEvent =
          InitializationEvent.values[data['data']];
      _flexPlayerController.initializationSink.add(initializationEvent);
    }
    if (type == "state") {
      final PlayerState playerState = PlayerState.values[data['data']];
      _flexPlayerController.playerStateSink.add(playerState);
      if (playerState == PlayerState.playing) {
        isPlaying = true;
      } else {
        isPlaying = false;
      }
    }
    if (type == "position") {
      final Duration position = Duration(milliseconds: data['data']);
      _flexPlayerController.positionSink.add(position);
    }
    if (type == "duration") {
      final Duration duration = Duration(milliseconds: data['data']);
      _flexPlayerController.durationSink.add(duration);
    }
    if (type == "speed") {
      final double speed = double.parse(data['data']);
      _flexPlayerController.playbackSpeedSink.add(speed);
    }
    if (type == "volume") {
      final double volume = double.parse(data['data']);
      if (volume == 0) {
        isMuted = true;
      } else {
        isMuted = false;
      }
    }
  }

  void play() {
    channel.play();
  }

  void pause() {
    channel.pause();
  }

  void stop() {
    channel.stop();
  }

  void chanegQuality(String quality) {
    channel.changequality(quality);
  }

  void mute() {
    channel.setVolume(0);
  }

  void load({
    required List<VideoData> videoData,
    required bool autoPlay,
    required bool loop,
    required bool mute,
    required double volume,
    required double playbackSpeed,
    Duration? position,
    VoidCallback? onInitialized,
  }) async {
    await channel.load(
      videoData: videoData,
      autoPlay: autoPlay,
      loop: loop,
      mute: mute,
      volume: volume,
      playbackSpeed: playbackSpeed,
      position: position,
      onInitialized: onInitialized,
    );
  }

  void reload() {
    channel.reload();
  }

  void setVolume(double volume) {
    channel.setVolume(volume);
  }

  void setPlaybackSpeed(double speed) {
    channel.setPlaybackSpeed(speed);
  }

  void seekTo(Duration position) {
    channel.seekTo(position);
  }
}
