import 'package:flutter/material.dart';
import 'package:flutter_flex_player/helpers/flex_player_sources.dart';

abstract class FlutterFlexPlayerAbstract {
  void load(FlexPlayerSource source);
  void play();
  void pause();
  void stop();
  void seekTo(Duration position);
  void setVolume(double volume);
  void setPlaybackSpeed(double speed);
  void setLooping(bool looping);
  void setMute(bool mute);
  void dispose();
  void enterFullScreen(BuildContext context);
  void exitFullScreen(BuildContext context);
}
