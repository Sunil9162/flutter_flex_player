import 'package:flutter/services.dart';
import 'package:flutter_flex_player/controllers/NativePlayer/native_player_channel.dart';
import 'package:flutter_flex_player/controllers/youtube_controller.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

abstract class NativePlayerInterface extends PlatformInterface {
  NativePlayerInterface() : super(token: _token);
  static final Object _token = Object();
  static NativePlayerInterface _instance = NativePlayerChannel();
  static NativePlayerInterface get instance => _instance;
  static set instance(NativePlayerInterface instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> play();

  Future<void> pause();

  Future<void> stop();

  Future<void> load({
    required List<VideoData> videoData,
    required bool autoPlay,
    required bool loop,
    required bool mute,
    required double volume,
    required double playbackSpeed,
    Duration? position,
    VoidCallback? onInitialized,
  });

  void changequality(String quality);

  void reload();

  void setVolume(double volume);

  void setPlaybackSpeed(double speed);

  void seekTo(Duration position);
}
