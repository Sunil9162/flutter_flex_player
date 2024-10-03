import 'package:flutter/material.dart';

class FlexPlayerConfiguration {
  final bool isFullScreen;
  final bool controlsVisible;
  final Orientation orientationonFullScreen;
  final String? thumbnail;
  final double? aspectRatio;
  final bool autoDispose;
  final bool autoPlay;
  final bool loop;
  final bool showControls;
  final double volume;
  final double playbackSpeed;
  final Duration? position;
  final bool isPlaying;
  final bool autoQuality;
  final Widget? errorWidget;
  final bool showControlsOnError;

  FlexPlayerConfiguration({
    this.isFullScreen = false,
    this.controlsVisible = true,
    this.orientationonFullScreen = Orientation.landscape,
    this.thumbnail,
    this.aspectRatio,
    this.autoDispose = true,
    this.autoPlay = true,
    this.loop = false,
    this.showControls = true,
    this.volume = 1.0,
    this.playbackSpeed = 1.0,
    this.position,
    this.isPlaying = false,
    this.autoQuality = true,
    this.errorWidget,
    this.showControlsOnError = true,
  });

  FlexPlayerConfiguration copyWith({
    bool? isFullScreen,
    bool? controlsVisible,
    Orientation? orientationonFullScreen,
    String? thumbnail,
    double? aspectRatio,
    bool? autoDispose,
    bool? autoPlay,
    bool? loop,
    bool? showControls,
    double? volume,
    double? playbackSpeed,
    Duration? position,
    bool? isPlaying,
    bool? autoQuality,
    Widget? errorWidet,
    bool? showControlsOnError,
  }) {
    return FlexPlayerConfiguration(
      isFullScreen: isFullScreen ?? this.isFullScreen,
      controlsVisible: controlsVisible ?? this.controlsVisible,
      orientationonFullScreen:
          orientationonFullScreen ?? this.orientationonFullScreen,
      thumbnail: thumbnail ?? this.thumbnail,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      autoDispose: autoDispose ?? this.autoDispose,
      autoPlay: autoPlay ?? this.autoPlay,
      loop: loop ?? this.loop,
      showControls: showControls ?? this.showControls,
      volume: volume ?? this.volume,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      position: position ?? this.position,
      isPlaying: isPlaying ?? this.isPlaying,
      autoQuality: autoQuality ?? this.autoQuality,
      errorWidget: errorWidet ?? errorWidget,
      showControlsOnError: showControlsOnError ?? this.showControlsOnError,
    );
  }
}
