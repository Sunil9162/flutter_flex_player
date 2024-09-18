import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flex_player/controls/player_controller.dart';
import 'package:flutter_flex_player/flutter_flex_player_controller.dart';
import 'package:flutter_flex_player/helpers/extensions.dart';

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

class _PlayerControlsState extends State<PlayerControls> {
  final playerController = PlayerController.instance;

  @override
  void initState() {
    super.initState();
    playerController.initPlayerControls(widget.controller);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        playerController.toggleControlsVisibility();
      },
      child: AspectRatio(
        aspectRatio: widget.controller.configuration.aspectRatio,
        child: AnimatedBuilder(
          animation: playerController.animationController,
          builder: (context, child) {
            final opacity = playerController.animationController.value;
            return AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: opacity,
              child: ColoredBox(
                color: Colors.black.withOpacity(0.6),
                child: IgnorePointer(
                  ignoring: !playerController.isControlsVisible.value,
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
        StreamBuilder<InitializationEvent>(
            stream: playerController.player.onInitialized,
            builder: (context, snapshot) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: IgnorePointer(
                        ignoring: snapshot.data ==
                                InitializationEvent.initializing ||
                            snapshot.data == InitializationEvent.uninitialized,
                        child: StreamBuilder<Duration>(
                          stream: playerController.player.onPositionChanged,
                          builder: (context, snapshot) {
                            final duration = playerController.player.duration;
                            final position = snapshot.data ??
                                playerController.player.position;
                            return ProgressBar(
                              thumbCanPaintOutsideBar: false,
                              progress: position,
                              total: duration,
                              buffered:
                                  playerController.player.bufferedPosition,
                              timeLabelTextStyle: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                              timeLabelLocation: TimeLabelLocation.sides,
                              thumbRadius: 6,
                              barCapShape: BarCapShape.round,
                              barHeight: 3,
                              onSeek: (duration) {
                                playerController.player.seekTo(duration);
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
                    ),
                    (context.width * 0.01).widthBox,
                    playbackSpeedWidget(),
                    fullScreenWidget(),
                  ],
                ),
              );
            }),
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
            playerController.toggleFullScreen(context);
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
            playerController.showSpeedDialog(context);
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
            playerController.showQualityDialog(context);
          },
          child: Container(
            height: 30,
            width: 30,
            alignment: Alignment.center,
            child: const Icon(
              Icons.more_vert,
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
              playerController.player.seekTo(
                playerController.player.position - const Duration(seconds: 10),
              );
            },
          ),
          (context.width * 0.1).widthBox,
          StreamBuilder<InitializationEvent>(
            stream: widget.controller.onInitialized,
            builder: (context, initalization) {
              return IgnorePointer(
                ignoring:
                    initalization.data == InitializationEvent.initializing,
                child: IconButton(
                  icon: initalization.data == InitializationEvent.initializing
                      ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        )
                      : initalization.data == InitializationEvent.uninitialized
                          ? const Icon(
                              Icons.replay,
                              color: Colors.white,
                              size: 35,
                            )
                          : StreamBuilder<PlayerState>(
                              stream:
                                  playerController.player.onPlayerStateChanged,
                              builder: (context, snapshot) {
                                if (snapshot.data == PlayerState.buffering) {
                                  return const CircularProgressIndicator(
                                    valueColor:
                                        AlwaysStoppedAnimation(Colors.white),
                                  );
                                }
                                return AnimatedIcon(
                                  icon: AnimatedIcons.pause_play,
                                  progress:
                                      playerController.playPauseController,
                                  color: Colors.white,
                                  size: 35,
                                );
                              },
                            ),
                  onPressed: () {
                    if (playerController.player.isInitialized) {
                      playerController.togglePlayPause();
                    } else {
                      playerController.player.reload();
                    }
                  },
                ),
              );
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
              playerController.player.seekTo(
                playerController.player.position + const Duration(seconds: 10),
              );
            },
          ),
        ],
      ),
    );
  }
}
