//
//  FlutterFlexPlayerView.swift
//
//

import Flutter
import UIKit
class FlutterFlexPlayerView: NSObject, FlutterPlatformView, FlutterStreamHandler {
    private var _methodChannel: FlutterMethodChannel
    private var _eventChannel: FlutterEventChannel
    var _eventSink: FlutterEventSink?
    private var previewView: UIView
    private var playerView: VideoPlayerView?

    init(
        _ frame: CGRect,
        viewId: Int64,
        args: Any?,
        messenger: FlutterBinaryMessenger
    ) {
        _methodChannel = FlutterMethodChannel(
            name: "flutter_flex_player", binaryMessenger: messenger)
        _eventChannel = FlutterEventChannel(
            name: "flutter_flex_player/events", binaryMessenger: messenger)
        previewView = UIView(frame: frame)
        super.init()
        _methodChannel.setMethodCallHandler(onMethodCall)
        _eventChannel.setStreamHandler(playerView)
    }
    
    func onMethodCall(call: FlutterMethodCall, result: FlutterResult) {
        switch(call.method){
        case "startPreview":
            let args = call.arguments as? [String: Any]
        default:
            result(FlutterMethodNotImplemented)
        }
    }

      func view() -> UIView {
        return previewView
    }

      func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink)
        -> FlutterError?
    {
        _eventSink = events
        return nil
    }

      func onCancel(withArguments arguments: Any?) -> FlutterError? {
        _eventSink = nil
        return nil
    }
}
