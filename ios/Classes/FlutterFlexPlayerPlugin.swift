import Flutter
import UIKit

public class FlutterFlexPlayerPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
      registrar.register(FlutterFlexPlayerFactory(messenger: registrar.messenger()), withId: "player");
  }
}
