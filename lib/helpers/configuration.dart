import 'package:flutter/material.dart';

class FlexPlayerConfiguration {
  final bool isFullScreen;
  final bool controlsVisible;
  final Orientation orientationonFullScreen;
  final String? thumbnail;
  final double aspectRatio;
  final bool autoDispose;

  FlexPlayerConfiguration({
    this.isFullScreen = false,
    this.controlsVisible = true,
    this.orientationonFullScreen = Orientation.landscape,
    this.thumbnail,
    this.aspectRatio = 16 / 9,
    this.autoDispose = true,
  });

  FlexPlayerConfiguration copyWith({
    bool? isFullScreen,
    bool? controlsVisible,
    Orientation? orientationonFullScreen,
    String? thumbnail,
    double? aspectRatio,
    bool? autoDispose,
  }) {
    return FlexPlayerConfiguration(
      isFullScreen: isFullScreen ?? this.isFullScreen,
      controlsVisible: controlsVisible ?? this.controlsVisible,
      orientationonFullScreen:
          orientationonFullScreen ?? this.orientationonFullScreen,
      thumbnail: thumbnail ?? this.thumbnail,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      autoDispose: autoDispose ?? this.autoDispose,
    );
  }
}
