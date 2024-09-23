import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_flex_player/flutter_flex_player_controller.dart';

class NativePlayerView extends StatefulWidget {
  const NativePlayerView({super.key});

  @override
  State<NativePlayerView> createState() => _NativePlayerViewState();
}

class _NativePlayerViewState extends State<NativePlayerView>
    with AutomaticKeepAliveClientMixin {
  final controller = FlutterFlexPlayerController.instance;
  ValueNotifier<int> get viewId => ValueNotifier(0);
  final key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RepaintBoundary(
      key: key,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: ValueListenableBuilder<int>(
          valueListenable: viewId,
          builder: (context, snapshot, _) {
            if (defaultTargetPlatform == TargetPlatform.iOS) {
              return UiKitView(
                viewType: "player",
                creationParamsCodec: const StandardMessageCodec(),
                onPlatformViewCreated: (id) {
                  controller.nativePlayerController!.isVieweCreated.value =
                      true;
                },
              );
            }
            return AndroidView(
              viewType: "player",
              onPlatformViewCreated: (id) {
                controller.nativePlayerController!.isVieweCreated.value = true;
                log("onPlatformViewCreated: $id");
              },
              creationParamsCodec: const StandardMessageCodec(),
            );
          },
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
