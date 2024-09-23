part of 'native_player_controller.dart';

class _NativePlayerChannel {
  static const String _channelName = 'com.sunilflutter.ytPlayer';
  static const String _eventChannelName = 'com.sunilflutter.ytPlayer/events';
  static const String _methodPlay = 'play';
  static const String _methodPause = 'pause';
  static const String _methodStop = 'stop';
  static const String _methodLoad = 'load';

  static const MethodChannel _channel = MethodChannel(_channelName);
  static const EventChannel _eventChannel = EventChannel(_eventChannelName);

  EventChannel get eventChannel => _eventChannel;

  factory _NativePlayerChannel() => _NativePlayerChannel._();
  _NativePlayerChannel._();

  Widget get playerView {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return const UiKitView(
        viewType: _channelName,
        creationParamsCodec: StandardMessageCodec(),
      );
    }
    return PlatformViewLink(
      viewType: _channelName,
      surfaceFactory: (context, controller) {
        return AndroidViewSurface(
          controller: controller as AndroidViewController,
          gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
          hitTestBehavior: PlatformViewHitTestBehavior.opaque,
        );
      },
      onCreatePlatformView: (params) {
        return PlatformViewsService.initSurfaceAndroidView(
          id: params.id,
          viewType: _channelName,
          layoutDirection: TextDirection.ltr,
          creationParams: params,
          creationParamsCodec: const StandardMessageCodec(),
        )
          ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
          ..create();
      },
    );
  }

  Future<void> play() async {
    await _channel.invokeMethod(_methodPlay);
  }

  Future<void> pause() async {
    await _channel.invokeMethod(_methodPause);
  }

  Future<void> stop() async {
    await _channel.invokeMethod(_methodStop);
  }

  Future<void> load({
    required List<VideoData> videoData,
    required bool autoPlay,
    required bool loop,
    required bool mute,
    required double volume,
    required double playbackSpeed,
    Duration? position,
    VoidCallback? onInitialized,
  }) async {
    await _channel.invokeMethod(_methodLoad, {
      'videoData': videoData.map((e) => e.toMap()).toList(),
      'autoPlay': autoPlay,
      'loop': loop,
      'mute': mute,
      'volume': volume,
      'playbackSpeed': playbackSpeed,
      'position': position?.inMilliseconds,
    });
  }

  void changequality(String quality) async {
    await _channel.invokeMethod('changequality', quality);
  }

  void reload() async {
    await _channel.invokeMethod('reload');
  }

  void setVolume(double volume) async {
    await _channel.invokeMethod('setVolume', volume);
  }

  void setPlaybackSpeed(double speed) async {
    await _channel.invokeMethod('setPlaybackSpeed', speed);
  }

  void seekTo(Duration position) async {
    await _channel.invokeMethod('seekTo', position.inMilliseconds);
  }
}
