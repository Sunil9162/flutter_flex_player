library flutter_flex_player;

import 'package:flutter/services.dart';
import 'package:flutter_flex_player/controllers/NativePlayer/native_player_interface.dart';
import 'package:flutter_flex_player/controllers/youtube_controller.dart';

class NativePlayerChannel extends NativePlayerInterface {
  static NativePlayerChannel get instance => NativePlayerChannel();
  factory NativePlayerChannel() => NativePlayerChannel._();
  NativePlayerChannel._();

  static const String _channelName = 'com.sunilflutter.ytPlayer';
  static const String _eventChannelName = 'com.sunilflutter.ytPlayer/events';
  static const String _methodPlay = 'play';
  static const String _methodPause = 'pause';
  static const String _methodStop = 'stop';
  static const String _methodLoad = 'load';

  static const MethodChannel _channel = MethodChannel(_channelName);
  static const EventChannel _eventChannel = EventChannel(_eventChannelName);

  EventChannel get eventChannel => _eventChannel;

  @override
  Future<void> play() async {
    await _channel.invokeMethod(_methodPlay);
  }

  @override
  Future<void> pause() async {
    await _channel.invokeMethod(_methodPause);
  }

  @override
  Future<void> stop() async {
    await _channel.invokeMethod(_methodStop);
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
    await _channel.invokeMethod(_methodLoad, {
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
  void changequality(String quality) async {
    await _channel.invokeMethod('changequality', quality);
  }

  @override
  void reload() async {
    await _channel.invokeMethod('reload');
  }

  @override
  void setVolume(double volume) async {
    await _channel.invokeMethod('setVolume', volume);
  }

  @override
  void setPlaybackSpeed(double speed) async {
    await _channel.invokeMethod('setPlaybackSpeed', speed);
  }

  @override
  void seekTo(Duration position) async {
    await _channel.invokeMethod('seekTo', position.inMilliseconds);
  }
}
