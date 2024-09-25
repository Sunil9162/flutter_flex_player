package com.example.flutter_flex_player;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.SurfaceTexture;
import android.net.Uri;

import androidx.annotation.NonNull;
import androidx.annotation.OptIn;
import androidx.media3.common.MediaItem;
import androidx.media3.common.Player;
import androidx.media3.common.util.UnstableApi;
import androidx.media3.datasource.DefaultDataSource;
import androidx.media3.exoplayer.ExoPlayer;
import androidx.media3.exoplayer.source.MediaSource;
import androidx.media3.exoplayer.source.MergingMediaSource;
import androidx.media3.exoplayer.source.ProgressiveMediaSource;

import android.os.Handler;
import android.util.Log;
import android.view.Surface;
import android.view.TextureView;


import com.google.gson.Gson;

import java.util.ArrayList;
import java.util.Map;
import java.util.Objects;

import io.flutter.plugin.common.EventChannel;

public class VideoPlayerView {
    @SuppressLint("StaticFieldLeak")
    private static VideoPlayerView instance;
    private ExoPlayer player;
    private final Context context;
    private ArrayList<VideoData> videoData;
    private EventChannel.EventSink eventSink;
    private final Handler handler;

    @OptIn(markerClass = UnstableApi.class)
    private VideoPlayerView(Context context) {
        this.context = context;
        handler = new Handler();
        if (player == null) {
            player = new ExoPlayer.Builder(context).build();
            player.addListener(new Player.Listener() {
                @Override
                public void onPlaybackStateChanged( int playbackState) {
                    notifyPlayerState(playbackState); // Notify player state
                }
            });
        }
    }

    private void sendMapData(Map<Object, Object> map) {
        Gson json = new Gson();
        sendEvent(json.toJson(map));
    }

    // Send the event to Flutter on Main Thread
    private void sendEvent(Object event) {
        if (eventSink != null) {
            handler.post(() -> eventSink.success(event));
        }
    }

    public void setTextureView(SurfaceTexture textureView) {
        Surface surface = new Surface(textureView);
        player.setVideoSurface(surface);
    }
    public void setEventSink(EventChannel.EventSink eventSink) {
        this.eventSink = eventSink;
    }
    // Singleton instance method
    public static VideoPlayerView getInstance(Context context) {
        if (instance == null) {
            instance = new VideoPlayerView(context);
        }
        return instance;
    }

    private void notifyPlayerState(int state) {
        if (eventSink != null) {
            Map<Object, Object> map = Map.of("state", state);
            sendMapData(map);
        }
    }


    public ExoPlayer getPlayer(){
        return player;
    }

    @OptIn(markerClass = UnstableApi.class)
    public void loadPlayer(@NonNull Map<Object, Object> arguments) {
        if (this.videoData != null){
            return;
        }
        try {
            Log.d("PlayerView", "Loading player");
            this.videoData = new ArrayList<>();
            ArrayList<Map<Object, Object>> videoData = (ArrayList<Map<Object, Object>>) arguments.get("videoData");
            assert videoData != null;
            for (Map<Object, Object> video : videoData) {
                this.videoData.add(VideoData.fromJson(video));
            }
            if (videoData.isEmpty()) {
                Log.e("VideoPlayerView", "No video data provided");
                return;
            }
            boolean autoPlay = (boolean) arguments.get("autoPlay");
            boolean loop = (boolean) arguments.get("loop");
            boolean mute = (boolean) arguments.get("mute");
            double volume = (double) arguments.get("volume");
            double playbackSpeed = (double) arguments.get("playbackSpeed");
            int position = (int) arguments.get("position");
            player = new ExoPlayer.Builder(context).build();
            player.setPlayWhenReady(autoPlay);
            player.setRepeatMode(loop ? ExoPlayer.REPEAT_MODE_ALL : ExoPlayer.REPEAT_MODE_OFF);
            player.setVolume((float) volume);
            player.setPlaybackSpeed((float) playbackSpeed);
            player.seekTo(position);
            initializePlayer();
        } catch (Exception e) {
            Log.e("PlayerView", "Error loading player: " + e.getMessage());
        }
    }

    @OptIn(markerClass = UnstableApi.class)
    private void initializePlayer() {
        String audioUrl = videoData.get(0).getAudioUrl();
        String videoUrl = videoData.get(0).getVideoUrl();
        playWithAudioAndVideo(videoUrl, audioUrl);
        Log.d("VideoPlayerView", "Player initialized");
    }

    @OptIn(markerClass = UnstableApi.class)
    private void playWithAudioAndVideo(String videoUrl, String audioUrl) {
       try {
           if (videoUrl == null || audioUrl == null) {
               Log.e("VideoPlayerView", "Invalid video or audio URL");
               return;
           }
           Log.d("PlayerView", "Audio URL: " + audioUrl);
           Log.d("PlayerView", "Video URL: " + videoUrl);
           MediaSource videoSource = buildMediaSource(Uri.parse(videoUrl));
           MediaSource audioSource = buildMediaSource(Uri.parse(audioUrl));
           MergingMediaSource mergedSource = new MergingMediaSource(videoSource, audioSource);
           player.setMediaSource(mergedSource);
           player.prepare();
           player.play();
           Log.d("PlayerView", "Player started");
       } catch (Exception e){
           Log.e("PlayerView", Objects.requireNonNull(e.getMessage()));
       }
    }

    @OptIn(markerClass = UnstableApi.class)
    private MediaSource buildMediaSource(Uri uri) {
        return new ProgressiveMediaSource.Factory(new DefaultDataSource.Factory(context))
                .createMediaSource(MediaItem.fromUri(uri));
    }

    public void releasePlayer() {
        if (player != null) {
            player.release();
            videoData = null;
            player = null;
            instance = null;
            Log.d("PlayerView", "Player released");
        }
    }
}
