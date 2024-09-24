import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_flex_player/flutter_flex_player_controller.dart';

class NativePlayerView extends StatefulWidget {
  final FlutterFlexPlayerController? flexPlayerController;
  const NativePlayerView({super.key, this.flexPlayerController});

  @override
  State<NativePlayerView> createState() => _NativePlayerViewState();
}

typedef NativePlayerCreatedCallBack = void Function(
    FlutterFlexPlayerController controller);

class _NativePlayerViewState extends State<NativePlayerView> {
  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return const UiKitView(
        viewType: "player",
        creationParamsCodec: StandardMessageCodec(),
      );
    }
    return AndroidView(
      viewType: "player",
      onPlatformViewCreated: (id) {
        if (widget.flexPlayerController == null) {
          return;
        }
        widget.flexPlayerController!.channel.setupChannels(id);
      },
      creationParamsCodec: const StandardMessageCodec(),
    );
  }
}
