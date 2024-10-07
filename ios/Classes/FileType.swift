//
//  FileType.swift
//  Pods
//
//  Created by Gitesh Dang iOS on 04/10/24.
//


enum FileType: Int {
    case url = 1
    case file = 0
    case youtube = 2
}

struct VideoData {
    var videoUrl: String
    var audioUrl: String = ""
    var quality: String = ""
    
    static func fromJson(json: [String: Any]) -> VideoData? {
        guard let videoUrl = json["url"] as? String else { return nil }
        let audioUrl = json["audioUrl"] as? String ?? ""
        let quality = json["quality"] as? String ?? ""
        return VideoData(videoUrl: videoUrl, audioUrl: audioUrl, quality: quality)
    }
}
