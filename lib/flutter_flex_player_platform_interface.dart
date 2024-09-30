import 'package:flutter/material.dart';
import 'package:flutter_flex_player/controllers/youtube_controller.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_flex_player_method_channel.dart';
import 'helpers/enums.dart';

abstract class FlutterFlexPlayerPlatform extends PlatformInterface {
  FlutterFlexPlayerPlatform() : super(token: _token);
  static final Object _token = Object();
  static FlutterFlexPlayerPlatform _instance = MethodChannelFlutterFlexPlayer();
  static FlutterFlexPlayerPlatform get instance => _instance;
  static set instance(FlutterFlexPlayerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> load({
    required List<VideoData> videoData,
    required bool autoPlay,
    required bool loop,
    required bool mute,
    required double volume,
    required double playbackSpeed,
    Duration? position,
    VoidCallback? onInitialized,
    required FileType type,
  });
  Future<void> play();
  Future<void> pause();
  Future<void> stop();
  Future<void> seekTo(Duration position);
  Future<void> setVolume(double volume);
  Future<void> setPlaybackSpeed(double speed);
  Future<void> setLooping(bool looping);
  Future<void> setMute(bool mute);
  Future<void> dispose();
  Future<void> reload();
  Future<void> setQuality(String quality);
}
