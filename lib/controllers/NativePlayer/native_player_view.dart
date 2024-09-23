import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ValueListenableBuilder<int>(
        valueListenable: viewId,
        builder: (context, snapshot, _) {
          if (defaultTargetPlatform == TargetPlatform.iOS) {
            return UiKitView(
              key: key,
              viewType: "player",
              creationParamsCodec: const StandardMessageCodec(),
              onPlatformViewCreated: (id) {
                controller.nativePlayerController!.isVieweCreated.value = true;
              },
            );
          }
          return PlatformViewLink(
            viewType: 'player', // The unique identifier for your native view
            surfaceFactory:
                (BuildContext context, PlatformViewController controller) {
              return AndroidViewSurface(
                controller: controller as AndroidViewController,
                gestureRecognizers: const <Factory<
                    OneSequenceGestureRecognizer>>{},
                hitTestBehavior: PlatformViewHitTestBehavior.opaque,
              );
            },
            onCreatePlatformView: (PlatformViewCreationParams params) {
              return PlatformViewsService.initSurfaceAndroidView(
                id: params.id,
                viewType: 'player',
                layoutDirection: TextDirection.ltr,
                creationParams: <String, dynamic>{},
                creationParamsCodec: const StandardMessageCodec(),
              )
                ..addOnPlatformViewCreatedListener((id) {
                  params.onPlatformViewCreated(id);
                  controller.nativePlayerController!.isVieweCreated.value =
                      true;
                  viewId.value = id;
                  viewId.notifyListeners();
                })
                ..create();
            },
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
