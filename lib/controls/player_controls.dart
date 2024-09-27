import 'dart:developer';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flex_player/controls/player_controller.dart';
import 'package:flutter_flex_player/flutter_flex_player_controller.dart';
import 'package:flutter_flex_player/helpers/extensions.dart';
import 'package:flutter_flex_player/helpers/streams.dart';

class PlayerControls extends StatefulWidget {
  final FlutterFlexPlayerController controller;
  final ControlsStyle controlsStyle;
  final Function onFullScreeen;
  const PlayerControls({
    super.key,
    required this.controller,
    required this.onFullScreeen,
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
                        child: StreamBuilder<PlayBackDurationStream>(
                          stream:
                              playerController.player.playbackDurationStream,
                          builder: (context, snapshot) {
                            final duration = snapshot.data?.duration;
                            final position = snapshot.data?.position;
                            return ProgressBar(
                              thumbCanPaintOutsideBar: false,
                              progress: position ?? Duration.zero,
                              total: duration ?? Duration.zero,
                              buffered:
                                  snapshot.data?.buffered ?? Duration.zero,
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
            widget.onFullScreeen();
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
          StreamBuilder<CombinedState>(
            key: const ValueKey("combinedStream"),
            stream: playerController.combinedStateController.stream,
            builder: (context, snapshot) {
              final combinedState = snapshot.data;
              if (combinedState == null) {
                // Show a loading indicator if no data is available yet
                return const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.red),
                );
              }
              // Access InitializationEvent and PlayerState from the combined data
              final initializationEvent = combinedState.initializationEvent;
              final playerState = combinedState.playerState;
              return IgnorePointer(
                ignoring:
                    initializationEvent == InitializationEvent.initializing ||
                        playerState == PlayerState.buffering,
                child: IconButton(
                  icon: Builder(builder: (_) {
                    if (initializationEvent ==
                        InitializationEvent.initializing) {
                      return const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      );
                    }
                    if (initializationEvent ==
                        InitializationEvent.uninitialized) {
                      return const Icon(
                        Icons.replay,
                        color: Colors.white,
                        size: 35,
                      );
                    }
                    if (playerState == PlayerState.buffering) {
                      log("PlayerState: ${playerState.name}");
                      return const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      );
                    }
                    return AnimatedIcon(
                      icon: AnimatedIcons.pause_play,
                      progress: playerController.playPauseController,
                      color: Colors.white,
                      size: 35,
                    );
                  }),
                  onPressed: () {
                    if (widget.controller.isInitialized) {
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

class CombinedState {
  final InitializationEvent initializationEvent;
  final PlayerState playerState;

  CombinedState(this.initializationEvent, this.playerState);
}
