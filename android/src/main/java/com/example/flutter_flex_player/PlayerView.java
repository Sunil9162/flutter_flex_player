package com.example.flutter_flex_player;

import android.content.Context;
import android.net.Uri;
import android.view.SurfaceView;
import android.view.TextureView;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.OptIn;
import androidx.media3.common.MediaItem;
import androidx.media3.common.util.UnstableApi;
import androidx.media3.datasource.DefaultDataSource;
import androidx.media3.exoplayer.ExoPlayer;
import androidx.media3.exoplayer.source.MediaSource;
import androidx.media3.exoplayer.source.MergingMediaSource;
import androidx.media3.exoplayer.source.ProgressiveMediaSource;

import io.flutter.Log;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;
import android.os.Handler;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.google.gson.Gson;

import java.util.ArrayList;
import java.util.Map;

public class PlayerView  implements PlatformView, MethodChannel.MethodCallHandler, EventChannel.StreamHandler{
    private final Context context;
    private final LinearLayout layout;
    private final Handler handler;
    private EventChannel.EventSink messenger;
    private ExoPlayer player;
    private ArrayList<VideoData> videoData;
    private androidx.media3.ui.PlayerView playerView;

    public  PlayerView(Context context, BinaryMessenger messenger){
        this.context = context;
        layout = new LinearLayout(context);
        layout.setLayoutParams(new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
        handler = new Handler();
        MethodChannel methodChannel = new MethodChannel(messenger, "com.sunilflutter.ytPlayer");
        methodChannel.setMethodCallHandler(this);
        EventChannel eventChannel = new EventChannel(messenger, "com.sunilflutter.ytPlayer/events");
        eventChannel.setStreamHandler(this);
    }

    @Override
    public void onListen(Object arguments, EventChannel.EventSink events) {
        messenger = events;
    }

    private void sendMapData(Map<Object, Object> map){
        Gson json = new Gson();
        sendEvent(json.toJson(map));
    }

    // Send the event to Flutter on Main Thread
    private void sendEvent(Object event) {
        if (messenger != null) {
            handler.post(() -> messenger.success(event));
        }
    }

    @Override
    public void onCancel(Object arguments) {
        messenger = null;
    }



    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        switch (call.method) {
            case "load":
                Map<Object, Object> arguments = (Map<Object, Object>) call.arguments;
                loadPlayer(arguments);
                break;
            case "play":
                if (player != null) {
                    player.play();
                }
                result.success(true);
                break;
            case "pause":
                if (player != null) {
                    player.pause();
                }
                result.success(true);
                break;
            case "seekTo":
                int position = (int) call.arguments;
                if (player != null) {
                    player.seekTo(position);
                }
                result.success(true);
                break;
            case "setVolume":
                double volume = (double) call.arguments;
                if (player != null) {
                    player.setVolume((float) volume);
                }
                result.success(true);
                break;
            case "setPlaybackSpeed":
                double playbackSpeed = (double) call.arguments;
                if (player != null) {
                    player.setPlaybackSpeed((float) playbackSpeed);
                }
                result.success(true);
                break;
            case "changequality":
                String quality = (String) call.arguments;
                if (player != null) {
                    if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.N) {
                        VideoData newVideo = videoData.stream().filter(video -> video.getQuality().equals(quality)).findFirst().orElse(null);
                        if (newVideo != null) {
                            String audioUrl = newVideo.getAudioUrl();
                            String videoUrl = newVideo.getVideoUrl();
                            playWithAudioAndVideo(videoUrl, audioUrl);
                        }
                    }
                }
                result.success(true);
                break;
            case "dispose":
                if (player != null) {
                    player.release();
                }
                result.success(true);

                break;
        }
    }

    private void loadPlayer(@NonNull Map<Object, Object> arguments){
        try {
            Log.d("PlayerView", "Loading player");
            this.videoData = new ArrayList<>();
            ArrayList<Map<Object, Object>> videoData = (ArrayList<Map<Object, Object>>) arguments.get("videoData");
            assert videoData != null;
            for (Map<Object, Object> video : videoData){
                this.videoData.add(VideoData.fromJson(video));
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
        } catch (Exception e){
            Log.e("PlayerView", "Error loading player: " + e.getMessage());
        }
    }

    @OptIn(markerClass = UnstableApi.class)
    private void initializePlayer(){
        playerView = new androidx.media3.ui.PlayerView(context);
        playerView.setPlayer(player);
        layout.addView(playerView);
        if (playerView.getVideoSurfaceView() instanceof SurfaceView) {
            SurfaceView surfaceView = (SurfaceView) playerView.getVideoSurfaceView();
            ViewGroup parent = (ViewGroup) surfaceView.getParent();
            int index = parent.indexOfChild(surfaceView);

            // Remove the SurfaceView from PlayerView
            parent.removeView(surfaceView);

            // Add a TextureView instead
            TextureView textureView = new TextureView(context);
            parent.addView(textureView, index);

            // Set the TextureView for the player
            player.setVideoTextureView(textureView);
        }
        playerView.setUseController(false);
        String audioUrl = videoData.get(0).getAudioUrl();
        String videoUrl = videoData.get(0).getVideoUrl();
        playWithAudioAndVideo(videoUrl,audioUrl);
        Log.d("PlayerView", "Player initialized");
    }

    @OptIn(markerClass = UnstableApi.class)
    private void playWithAudioAndVideo(String videoUrl, String audioUrl){
        MediaSource videoSource = buildMediaSource(Uri.parse(videoUrl));
        MediaSource audioSource = buildMediaSource(Uri.parse(audioUrl));
        MergingMediaSource mergedSource = new MergingMediaSource(videoSource, audioSource);
        // Prepare and play the merged media
        player.setMediaSource(mergedSource);
        player.prepare();
        player.play();
    }

    @OptIn(markerClass = UnstableApi.class)
    private MediaSource buildMediaSource(Uri uri) {
        return new ProgressiveMediaSource.Factory(new DefaultDataSource.Factory(context ))
                .createMediaSource(MediaItem.fromUri(uri));
    }

    @Nullable
    @Override
    public View getView() {
        return layout;
    }

    @Override
    public void dispose() {
        layout.removeAllViews();
        handler.removeCallbacksAndMessages(null);
        messenger = null;
        if (player != null) {
            player.release();
        }
    }
}
