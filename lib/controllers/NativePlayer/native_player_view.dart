part of '../../flutter_flex_player_controller.dart';

class _NativePlayerView extends StatefulWidget {
  final VoidCallback onPlatformViewCreated;
  final FlutterFlexPlayerController flexPlayerController;
  const _NativePlayerView({
    required this.flexPlayerController,
    required this.onPlatformViewCreated,
  });

  @override
  State<_NativePlayerView> createState() => _NativePlayerViewState();
}

class _NativePlayerViewState extends State<_NativePlayerView> {
  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return const UiKitView(
        viewType: "player",
        creationParamsCodec: StandardMessageCodec(),
      );
    }
    return PlatformViewLink(
      viewType: 'player',
      surfaceFactory: (context, controller) {
        return AndroidViewSurface(
          controller: controller as AndroidViewController,
          gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
          hitTestBehavior: PlatformViewHitTestBehavior.opaque,
        );
      },
      onCreatePlatformView: (params) {
        return PlatformViewsService.initExpensiveAndroidView(
          id: params.id,
          viewType: "player",
          layoutDirection: TextDirection.ltr,
          onFocus: () {
            params.onFocusChanged(true);
          },
        )
          ..addOnPlatformViewCreatedListener((int id) {
            params.onPlatformViewCreated(id);
            widget.onPlatformViewCreated();
          })
          ..create();
      },
    );
  }
}
