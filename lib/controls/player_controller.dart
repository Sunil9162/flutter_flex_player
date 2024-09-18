import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../flutter_flex_player_controller.dart';

class PlayerController extends GetxController with GetTickerProviderStateMixin {
  static PlayerController get instance => Get.isRegistered<PlayerController>()
      ? Get.find()
      : Get.put(PlayerController());

  late FlutterFlexPlayerController _controller;

  FlutterFlexPlayerController get player => _controller;

  late AnimationController _animationController;
  AnimationController get animationController => _animationController;

  late AnimationController _playPauseController;
  AnimationController get playPauseController => _playPauseController;
  late StreamSubscription<PlayerState>? _playerStateSubscription;

  Timer? _timer;
  RxBool isControlsVisible = true.obs;

  initPlayerControls(FlutterFlexPlayerController controller) {
    _controller = controller;
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
    });
    _playPauseController.forward();
    _animationController.forward();
    if (_controller.isPlaying) {
      _playPauseController.reverse();
    }
    startTimer();
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
    if (player.isFullScreen) {
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
