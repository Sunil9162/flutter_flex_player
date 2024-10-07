//
//  VideoPlayerView.swift
//  Pods
//
//  Created by Gitesh Dang iOS on 04/10/24.
//
import Flutter
import AVFoundation
import UIKit
#if canImport(VideoToolbox)
import VideoToolbox
#endif
#if canImport(CoreMedia)
import CoreMedia
#endif
#if canImport(CoreVideo)
import CoreVideo
#endif
#if canImport(CoreGraphics)
import CoreGraphics
#endif
#if canImport(QuartzCore)
import QuartzCore
#endif

class VideoPlayerView: NSObject, FlutterStreamHandler {
    static var instance: VideoPlayerView?
    
    public var player: AVPlayer?
    public var playerLayer: AVPlayerLayer?
    private var playerItem: AVPlayerItem?
    private var eventSink: FlutterEventSink?
    private var handler: Timer?
    
    private var videoData: [VideoData] = []
    private var arguments: [String: Any] = [:]
    private var fileType: FileType = .url
    private let POSITION_UPDATE_INTERVAL_MS = 1.0

    private var observerContext = 0
    
    override init() {
        super.init() 
    }
    
    static func getInstance() -> VideoPlayerView {
        if instance == nil {
            instance = VideoPlayerView()
        }
        return instance!
    }
    
    private func initPlayer() {
        
        guard player == nil else { return }
        
        player = AVPlayer()
       
    }
   
    
    private func startPositionUpdate() {
        handler = Timer.scheduledTimer(withTimeInterval: POSITION_UPDATE_INTERVAL_MS, repeats: true, block: { [weak self] timer in
            guard let strongSelf = self, let player = strongSelf.player else { return }
            
            let duration = player.currentItem?.duration.seconds ?? 0
            let position = player.currentTime().seconds
            let buffered = player.currentItem?.loadedTimeRanges.first?.timeRangeValue.end.seconds ?? 0
            
            let data: [String: Any] = [
                "position": position,
                "duration": duration,
                "buffered": buffered
            ]
            
            strongSelf.sendMapData(data)
        })
    }
    
    private func stopPositionUpdate() {
        handler?.invalidate()
        handler = nil
    }
    
    private func sendMapData(_ map: [String: Any]) {
        guard let eventSink = eventSink else { return }
        if let jsonData = try? JSONSerialization.data(withJSONObject: map, options: []), let jsonString = String(data: jsonData, encoding: .utf8) {
            eventSink(jsonString)
        }
    }
    
    private func sendPlayerState(_ state: String) {
        let map: [String: Any] = ["state": state]
        sendMapData(map)
    }

    func setTextureView(textureView: UIView) {
        guard let player = player else { return }
        
        // Use AVPlayerLayer for rendering the video
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.frame = textureView.bounds
        playerLayer?.videoGravity = .resizeAspectFill
        textureView.layer.addSublayer(playerLayer!)
    }

    func loadPlayer(arguments: [String: Any]) {
        self.arguments = arguments
        
        guard let videoDataList = arguments["videoData"] as? [[String:Any]] else { return }
        print(videoDataList)
        for videoDataDict in videoDataList {
            if let videoDataItem = VideoData.fromJson(json: videoDataDict) {
                videoData.append(videoDataItem)
            }
        }
        
        if videoData.isEmpty {
            print("No video data provided")
            return
        }
        
        let autoPlay = arguments["autoPlay"] as? Bool ?? false
        let loop = arguments["loop"] as? Bool ?? false
        let mute = arguments["mute"] as? Bool ?? false
        let volume = arguments["volume"] as? Double ?? 1.0
        let playbackSpeed = arguments["playbackSpeed"] as? Double ?? 1.0
        let position = arguments["position"] as? Double ?? 0
        let index = arguments["index"] as? Int ?? 0
        
        fileType = FileType(rawValue: arguments["type"] as? Int ?? 0) ?? .url
        print(arguments["type"] as Any)
        if player == nil {
            initPlayer()
        }
        
        // Player configuration
        player?.volume = mute ? 0 : Float(volume)
        player?.rate = Float(playbackSpeed)
        
        loadMedia(index: index)
        
        // Set autoPlay
        if autoPlay {
            player?.play()
        }
        
        startPositionUpdate()
    }

    func loadMedia(index: Int) {
        guard index < videoData.count else { return }
        
        let videoItem = videoData[index]
        
        switch fileType {
        case .url:
            playWithUrl(videoItem: videoItem)
        case .file:
            playWithFile(videoItem: videoItem)
        case .youtube:
            playWithAudioAndVideo(videoUrl: videoItem.videoUrl, audioUrl: videoItem.audioUrl)
        }
    }
    
    func playWithUrl(videoItem: VideoData) {
       
        guard let url = URL(string: videoItem.videoUrl) else { return }
        playerItem = AVPlayerItem(url: url)
        print("Video Url is Coming \(url)")
        player = AVPlayer(playerItem: playerItem)
        player?.play()
    }
    
    func playWithFile(videoItem: VideoData) {
        let fileUrl = URL(fileURLWithPath: videoItem.videoUrl)
        playerItem = AVPlayerItem(url: fileUrl)
        player?.replaceCurrentItem(with: playerItem)
        player?.play()
    }
    
    func playWithAudioAndVideo(videoUrl: String, audioUrl: String) {
        guard let videoURL = URL(string: videoUrl), let audioURL = URL(string: audioUrl) else { return }
        
        let composition = AVMutableComposition()
        
        do {
            // Video Asset
            let videoAsset = AVURLAsset(url: videoURL)
            let videoTrack = videoAsset.tracks(withMediaType: .video).first!
            
            // Add video track to the composition
            let videoCompositionTrack = composition.addMutableTrack(withMediaType: .video,
                                                                    preferredTrackID: kCMPersistentTrackID_Invalid)
            try videoCompositionTrack?.insertTimeRange(CMTimeRange(start: .zero, duration: videoAsset.duration),
                                                       of: videoTrack, at: .zero)
            
            // Audio Asset
            let audioAsset = AVURLAsset(url: audioURL)
            let audioTrack = audioAsset.tracks(withMediaType: .audio).first!
            
            // Add audio track to the composition
            let audioCompositionTrack = composition.addMutableTrack(withMediaType: .audio,
                                                                    preferredTrackID: kCMPersistentTrackID_Invalid)
            try audioCompositionTrack?.insertTimeRange(CMTimeRange(start: .zero, duration: videoAsset.duration),
                                                       of: audioTrack, at: .zero)
            
            // Create a player item with the composition
            let playerItem = AVPlayerItem(asset: composition)
            player = AVPlayer(playerItem: playerItem)
            
            // Play the combined audio and video
            player?.play()
            
        } catch {
            print("Error merging audio and video: \(error)")
        }
    }
    
    func releasePlayer() {
        stopPositionUpdate()
        player?.pause()
        player = nil
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
    }
    
    // MARK: - FlutterStreamHandler methods
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        releasePlayer()
        eventSink = nil
        return nil
    }
}
