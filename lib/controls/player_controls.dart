import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flex_player/controls/player_controller.dart';
import 'package:flutter_flex_player/flutter_flex_player_controller.dart';
import 'package:flutter_flex_player/helpers/extensions.dart';
import 'package:flutter_flex_player/helpers/streams.dart';
import 'package:get/state_manager.dart';

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
        if (widget.controller.isInitialized) {
          playerController.toggleControlsVisibility();
        }
      },
      child: AspectRatio(
        aspectRatio: widget.controller.configuration.aspectRatio ??
            widget.controller.playerAspectRatio.value,
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
            child: Obx(() {
              return Icon(
                widget.controller.isFullScreen.value
                    ? Icons.fullscreen_exit_rounded
                    : Icons.fullscreen_rounded,
                color: Colors.white,
                size: 20,
              );
            }),
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
              final isInitalized =
                  initializationEvent == InitializationEvent.initialized;
              return Row(
                children: [
                  if (isInitalized)
                    IconButton(
                      icon: const Icon(
                        Icons.replay_10,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: () {
                        playerController.player.seekTo(
                          playerController.player.position -
                              const Duration(seconds: 10),
                        );
                      },
                    ),
                  (context.width * 0.1).widthBox,
                  IgnorePointer(
                    ignoring: initializationEvent ==
                            InitializationEvent.initializing ||
                        playerState == PlayerState.buffering ||
                        initializationEvent ==
                            InitializationEvent.uninitialized,
                    child: Builder(builder: (_) {
                      if (initializationEvent ==
                          InitializationEvent.initializing) {
                        return const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        );
                      }
                      if (initializationEvent ==
                          InitializationEvent.uninitialized) {
                        if (widget.controller.configuration.errorWidget !=
                            null) {
                          return widget.controller.configuration.errorWidget ??
                              const SizedBox();
                        }
                        return const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.warning_rounded,
                              color: Colors.red,
                              size: 35,
                            ),
                            Text(
                              "Error Playing Video",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        );
                      }
                      if (playerState == PlayerState.buffering) {
                        return const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        );
                      }
                      return IconButton(
                        onPressed: () {
                          if (widget.controller.isInitialized) {
                            playerController.togglePlayPause();
                          }
                        },
                        icon: AnimatedIcon(
                          icon: AnimatedIcons.pause_play,
                          progress: playerController.playPauseController,
                          color: Colors.white,
                          size: 35,
                        ),
                      );
                    }),
                  ),
                  (context.width * 0.1).widthBox,
                  if (isInitalized)
                    IconButton(
                      icon: const Icon(
                        Icons.forward_10,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: () {
                        playerController.player.seekTo(
                          playerController.player.position +
                              const Duration(seconds: 10),
                        );
                      },
                    ),
                ],
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
