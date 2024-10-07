//
//  FlutterFlexPlayerView.swift
//
//

import Flutter
import UIKit
import AVFoundation 

class FlutterFlexPlayerView: NSObject, FlutterPlatformView {
    private var methodChannel: FlutterMethodChannel
    private var eventChannel: FlutterEventChannel
    private var eventSink: FlutterEventSink?
    private var previewView: UIView
    private var videoPlayerView: VideoPlayerView?

    init(
        _ frame: CGRect,
        viewId: Int64,
        args: Any?,
        messenger: FlutterBinaryMessenger
    ) {
        // Initialize method and event channels
        methodChannel = FlutterMethodChannel(
            name: "flutter_flex_player",
            binaryMessenger: messenger
        )
        eventChannel = FlutterEventChannel(
            name: "flutter_flex_player/events",
            binaryMessenger: messenger
        )
        previewView = UIView(frame: frame)
        super.init()
        
        // Set up method and event handlers
        methodChannel.setMethodCallHandler(onMethodCall)
        // Create the player view
        createPlayer()
    }

    private func createPlayer() {
        self.videoPlayerView = VideoPlayerView.getInstance()
        eventChannel.setStreamHandler(self.videoPlayerView!)
        self.videoPlayerView?.setTextureView(textureView: previewView)
    }

    func onMethodCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "load":
            if let args = call.arguments as? [String: Any] {
                videoPlayerView?.loadPlayer(arguments: args)
                result("Player Loaded")
            } else {
                result(FlutterError(code: "LOAD_ERROR", message: "Invalid Arguments", details: nil))
            }
        case "play":
            videoPlayerView?.player?.play();
            result(true)
        case "pause":
            videoPlayerView?.player?.pause();
            result(true)
        case "seekTo":
            if let position = call.arguments as? Int {
                videoPlayerView?.player?.seek(to: CMTime(value: CMTimeValue(position), timescale: 1))
                result(true)
            } else {
                result(FlutterError(code: "SEEK_ERROR", message: "Invalid Position", details: nil))
            }
        case "setVolume":
            if let volume = call.arguments as? Double {
                videoPlayerView?.player?.volume = Float(volume)
                result(true)
            } else {
                result(FlutterError(code: "VOLUME_ERROR", message: "Invalid Volume", details: nil))
            }
        case "setPlaybackSpeed":
            if let playbackSpeed = call.arguments as? Double {
                videoPlayerView?.player?.rate = Float(playbackSpeed)
                result(true)
            } else {
                result(FlutterError(code: "SPEED_ERROR", message: "Invalid Speed", details: nil))
            }
        case "changequality":
            if let quality = call.arguments as? String {
//                videoPlayerView?.changeq
                result(true)
            } else {
                result(FlutterError(code: "QUALITY_ERROR", message: "Invalid Quality", details: nil))
            }
//        case "reload":
//            videoPlayerView?.reloadPlayer()
//            result("Player Reloading...")
        case "dispose":
            videoPlayerView?.releasePlayer()
            result(true)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    func view() -> UIView {
        return previewView
    }
}
