import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_flex_player_method_channel.dart';

abstract class FlutterFlexPlayerPlatform extends PlatformInterface {
  /// Constructs a FlutterFlexPlayerPlatform.
  FlutterFlexPlayerPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterFlexPlayerPlatform _instance = MethodChannelFlutterFlexPlayer();

  /// The default instance of [FlutterFlexPlayerPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterFlexPlayer].
  static FlutterFlexPlayerPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterFlexPlayerPlatform] when
  /// they register themselves.
  static set instance(FlutterFlexPlayerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
