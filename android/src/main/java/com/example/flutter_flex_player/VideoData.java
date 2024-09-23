package com.example.flutter_flex_player;

import java.util.Map;

public class VideoData {
    private final String videoUrl;
    private final String audioUrl;
    private final String quality;

    public VideoData(String videoUrl, String audioUrl, String quality) {
        this.videoUrl = videoUrl;
        this.audioUrl = audioUrl;
        this.quality = quality;
    }

    ///Create a getter for the videoUrl


    public String getAudioUrl() {
        return audioUrl;
    }

    ///Create a getter for the audioUrl
    public String getVideoUrl() {
        return videoUrl;
    }

    ///Create a getter for the quality
    public String getQuality() {
        return quality;
    }

    public String toJson() {
        return "{\"videoUrl\":\"" + videoUrl + "\",\"audioUrl\":\"" + audioUrl + "\"}";
    }

    public static VideoData fromJson(Map<Object, Object> map) {
        String videoUrl = (String) map.get("videoUrl");
        String audioUrl = (String) map.get("audioUrl");
        String quality = (String) map.get("quality");
        return new VideoData(videoUrl, audioUrl,quality);
    }
}
