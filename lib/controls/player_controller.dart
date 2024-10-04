import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_flex_player/controls/player_controls.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart' as dart;

import '../flutter_flex_player_controller.dart';

class PlayerController extends GetxController with GetTickerProviderStateMixin {
  static PlayerController get instance => Get.isRegistered<PlayerController>()
      ? Get.find()
      : Get.put(PlayerController(), permanent: true);

  late FlutterFlexPlayerController _controller;

  FlutterFlexPlayerController get player => _controller;

  late AnimationController _animationController;
  AnimationController get animationController => _animationController;

  late AnimationController _playPauseController;
  AnimationController get playPauseController => _playPauseController;
  late StreamSubscription<PlayerState>? _playerStateSubscription;

  // Make sure the StreamController is broadcast
  dart.BehaviorSubject<CombinedState> combinedStateController =
      dart.BehaviorSubject<CombinedState>();

  StreamSubscription<CombinedState>? _streamSubscription;

  Timer? _timer;
  RxBool isControlsVisible = true.obs;
  bool _isInitDone = false;
  Stream<CombinedState>? combinedStream;

  initPlayerControls(FlutterFlexPlayerController controller) {
    if (_isInitDone == true) {
      return;
    }
    _controller = controller;
    _streamSubscription?.cancel();
    combinedStream =
        dart.Rx.combineLatest2<InitializationEvent, PlayerState, CombinedState>(
      player.onInitialized,
      player.onPlayerStateChanged,
      (initializationEvent, playerState) =>
          CombinedState(initializationEvent, playerState),
    ).asBroadcastStream(); // Convert to broadcast stream

    // Subscribe to the combined stream
    _streamSubscription = combinedStream?.listen((combinedState) {
      if (combinedState.initializationEvent ==
              InitializationEvent.initialized &&
          combinedState.playerState == PlayerState.playing) {
        startTimer();
      }
      combinedStateController.add(combinedState);
    });

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _playPauseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _playerStateSubscription = _controller.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.playing) {
        _playPauseController.reverse();
      } else {
        _playPauseController.forward();
      }
      if (state == PlayerState.buffering) {
        isControlsVisible.value = true;
        _animationController.forward();
      }
    });

    _playPauseController.forward();
    _animationController.forward();
    if (_controller.isPlaying) {
      _playPauseController.reverse();
    }
    startTimer();
    _isInitDone = true;
  }

  void startTimer() {
    if (_timer != null) {
      _timer!.cancel();
    }
    _timer = Timer(const Duration(seconds: 3), () {
      if (isControlsVisible.value && player.isPlaying) {
        _animationController.reset();
        isControlsVisible.value = false;
      }
    });
  }

  @override
  void onClose() {
    _animationController.dispose();
    _playPauseController.dispose();
    _playerStateSubscription?.cancel();
    _timer?.cancel();
    super.onClose();
  }

  void toggleControlsVisibility() {
    if (isControlsVisible.value) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
    isControlsVisible.value = !isControlsVisible.value;
    startTimer();
  }

  void toggleFullScreen(BuildContext context) {
    if (player.isFullScreen.value) {
      player.exitFullScreen(context);
    } else {
      player.enterFullScreen(context);
    }
  }

  void showSpeedDialog(BuildContext context) {
    player.showSpeedDialog(context);
  }

  void showQualityDialog(BuildContext context) {
    player.showQualityDialog(context);
  }

  void togglePlayPause() {
    if (player.isPlaying) {
      player.pause();
    } else {
      player.play();
    }
    startTimer();
  }
}
