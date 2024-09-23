library flutter_flex_player;

import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:flutter_flex_player/controllers/NativePlayer/native_player_channel.dart';
import 'package:flutter_flex_player/controllers/youtube_controller.dart';
import 'package:flutter_flex_player/flutter_flex_player_controller.dart';
import 'package:get/get.dart';

class NativePlayerController {
  final channel = NativePlayerChannel.instance;
  final _flexPlayerController = FlutterFlexPlayerController.instance;

  static NativePlayerController get instance => NativePlayerController();
  factory NativePlayerController() => NativePlayerController._();

  NativePlayerController._() {
    log("NativePlayerController created");
    once(isVieweCreated, (isVieweCreated) {
      log("isVieweCreated: $isVieweCreated");
      if (isVieweCreated) {
        channel.eventChannel.receiveBroadcastStream().listen((event) {
          parseEvent(event);
        });
        loadPlayer();
      }
    });
  }

  loadPlayer() async {
    log(videoData.toString());
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

  bool get isMuted => false;
  bool get isPlaying => false;
  bool get isLooping => false;
  RxBool isVieweCreated = false.obs;

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

  void muteVideo() {
    channel.setVolume(0);
  }

  //Player Datas
  List<VideoData> videoData = [];
  bool autoPlay = false;
  bool loop = false;
  double volume = 1.0;
  bool mute = false;
  double playbackSpeed = 1.0;
  Duration? position;
  VoidCallback? onInitialized;

  // void load({
  //   required List<VideoData> videoData,
  //   required bool autoPlay,
  //   required bool loop,
  //   required bool mute,
  //   required double volume,
  //   required double playbackSpeed,
  //   Duration? position,
  //   VoidCallback? onInitialized,
  // }) {
  //   this.videoData = videoData;
  //   this.autoPlay = autoPlay;
  //   this.loop = loop;
  //   this.volume = volume;
  //   this.mute = mute;
  //   this.playbackSpeed = playbackSpeed;
  //   this.position = position;
  //   this.onInitialized = onInitialized;
  // }

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
