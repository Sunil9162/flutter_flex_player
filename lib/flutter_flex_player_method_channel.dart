import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:flutter_flex_player/controllers/youtube_controller.dart';

import 'flutter_flex_player_platform_interface.dart';

/// An implementation of [FlutterFlexPlayerPlatform] that uses method channels.
class MethodChannelFlutterFlexPlayer extends FlutterFlexPlayerPlatform {
  static const String _eventChannelName = 'flutter_flex_player/events';
  static const String _methodPlay = 'play';
  static const String _methodPause = 'pause';
  static const String _methodStop = 'stop';
  static const String _methodLoad = 'load';
  late MethodChannel methodChannel;
  late EventChannel eventChannel;

  Future<void> setupChannels(int id) async {
    methodChannel = MethodChannel('flutter_flex_player_$id');
    eventChannel = EventChannel("${_eventChannelName}_$id");
    log("Channel is setup with id $id");
  }

  @override
  Future<void> dispose() async {
    await methodChannel.invokeMethod("dispose");
  }

  @override
  Future<void> setLooping(bool looping) async {}

  @override
  Future<void> setMute(bool mute) async {
    await setVolume(mute ? 0 : 1);
  }

  @override
  Future<void> setPlaybackSpeed(double speed) async {
    await methodChannel.invokeMethod('setPlaybackSpeed', speed);
  }

  @override
  Future<void> setQuality(String quality) async {
    await methodChannel.invokeMethod('changequality', quality);
  }

  @override
  Future<void> setVolume(double volume) async {
    await methodChannel.invokeMethod('setVolume', volume);
  }

  @override
  Future<void> play() async {
    await methodChannel.invokeMethod(_methodPlay);
  }

  @override
  Future<void> pause() async {
    await methodChannel.invokeMethod(_methodPause);
  }

  @override
  Future<void> stop() async {
    await methodChannel.invokeMethod(_methodStop);
  }

  @override
  Future<void> load({
    required List<VideoData> videoData,
    required bool autoPlay,
    required bool loop,
    required bool mute,
    required double volume,
    required double playbackSpeed,
    Duration? position,
    VoidCallback? onInitialized,
  }) async {
    await methodChannel.invokeMethod(_methodLoad, {
      'videoData': videoData.map((e) => e.toMap()).toList(),
      'autoPlay': autoPlay,
      'loop': loop,
      'mute': mute,
      'volume': volume,
      'playbackSpeed': playbackSpeed,
      'position': position?.inMilliseconds ?? 0,
    });
  }

  @override
  Future<void> reload() async {
    await methodChannel.invokeMethod('reload');
  }

  @override
  Future<void> seekTo(Duration position) async {
    await methodChannel.invokeMethod('seekTo', position.inMilliseconds);
  }
}
