import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_flex_player_platform_interface.dart';

/// An implementation of [FlutterFlexPlayerPlatform] that uses method channels.
class MethodChannelFlutterFlexPlayer extends FlutterFlexPlayerPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_flex_player');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
