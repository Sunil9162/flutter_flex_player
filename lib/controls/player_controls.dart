import 'dart:async';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flex_player/flutter_flex_player_controller.dart';
import 'package:flutter_flex_player/helpers/extensions.dart';

import '../helpers/enums.dart';

class PlayerControls extends StatefulWidget {
  final FlutterFlexPlayerController controller;
  final ControlsStyle controlsStyle;
  const PlayerControls({
    super.key,
    required this.controller,
    this.controlsStyle = ControlsStyle.defaultStyle,
  });

  @override
  State<PlayerControls> createState() => _PlayerControlsState();
}

class _PlayerControlsState extends State<PlayerControls>
    with TickerProviderStateMixin {
  late FlutterFlexPlayerController _controller;
  late AnimationController _animationController;
  late AnimationController _playPauseController;
  bool _isControlsVisible = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _playPauseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    _playPauseController.dispose();
    super.dispose();
  }

  startTimer() {
    if (_timer != null) {
      _timer!.cancel();
    }
    _timer = Timer(const Duration(seconds: 3), () {
      if (_isControlsVisible && _controller.isPlaying) {
        _animationController.reset();
        _isControlsVisible = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_isControlsVisible) {
          _animationController.reset();
        } else {
          _animationController.forward();
        }
        _isControlsVisible = !_isControlsVisible;
        startTimer();
      },
      child: AspectRatio(
        aspectRatio: _controller.aspectRatio,
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            final opacity = _animationController.value;
            return AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: opacity,
              child: ColoredBox(
                color: Colors.black.withOpacity(0.6),
                child: IgnorePointer(
                  ignoring: !_isControlsVisible,
                  child: Stack(
                    children: [
                      centerButtons(),
                      bottomwidget(),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: settingsButton(),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget bottomwidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: StreamBuilder<Duration>(
                  stream: _controller.onPositionChanged,
                  builder: (context, snapshot) {
                    final duration = _controller.duration;
                    final position = snapshot.data ?? Duration.zero;
                    return ProgressBar(
                      thumbCanPaintOutsideBar: false,
                      progress: position,
                      total: duration,
                      buffered: _controller.bufferedPosition,
                      timeLabelTextStyle: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                      timeLabelLocation: TimeLabelLocation.sides,
                      thumbRadius: 6,
                      barCapShape: BarCapShape.round,
                      barHeight: 3,
                      onSeek: (duration) {
                        _controller.seekTo(duration);
                      },
                      progressBarColor: Colors.blue,
                      baseBarColor: Colors.grey.withOpacity(0.5),
                      bufferedBarColor: Colors.white.withOpacity(0.5),
                      thumbColor: Colors.blue,
                      thumbGlowRadius: 10,
                    );
                  },
                ),
              ),
              (context.width * 0.01).widthBox,
              playbackSpeedWidget(),
              fullScreenWidget(),
            ],
          ),
        ),
      ],
    );
  }

  Widget fullScreenWidget() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (_controller.isFullScreen) {
              _controller.exitFullScreen(context);
            } else {
              _controller.enterFullScreen(context);
            }
          },
          child: Container(
            height: 30,
            width: 30,
            alignment: Alignment.center,
            child: const Icon(
              Icons.fullscreen,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget playbackSpeedWidget() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // _controller.toggleFullScreen();
          },
          child: Container(
            height: 30,
            width: 30,
            alignment: Alignment.center,
            child: const Icon(
              Icons.speed,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget settingsButton() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // _controller.toggleFullScreen();
          },
          child: Container(
            height: 30,
            width: 30,
            alignment: Alignment.center,
            child: const Icon(
              Icons.settings_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget centerButtons() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(
              Icons.replay_10,
              color: Colors.white,
              size: 30,
            ),
            onPressed: () {
              _controller.seekTo(
                _controller.position - const Duration(seconds: 10),
              );
            },
          ),
          (context.width * 0.1).widthBox,
          IconButton(
            icon: StreamBuilder<PlayerState>(
              stream: _controller.onPlayerStateChanged,
              builder: (context, snapshot) {
                if (snapshot.data == PlayerState.buffering) {
                  return const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  );
                }
                return AnimatedIcon(
                  icon: AnimatedIcons.pause_play,
                  progress: _playPauseController,
                  color: Colors.white,
                  size: 35,
                );
              },
            ),
            onPressed: () {
              if (_controller.isPlaying) {
                _controller.pause();
                _playPauseController.forward();
              } else {
                _controller.play();
                _playPauseController.reverse();
              }
              startTimer();
            },
          ),
          (context.width * 0.1).widthBox,
          IconButton(
            icon: const Icon(
              Icons.forward_10,
              color: Colors.white,
              size: 30,
            ),
            onPressed: () {
              _controller.seekTo(
                _controller.position + const Duration(seconds: 10),
              );
            },
          ),
        ],
      ),
    );
  }
}
