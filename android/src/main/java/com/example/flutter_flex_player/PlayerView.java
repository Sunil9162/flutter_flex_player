//package com.example.flutter_flex_player;
//
//import android.content.Context;
//import android.view.View;
//import android.view.ViewGroup;
//import android.widget.LinearLayout;
//
//import androidx.annotation.NonNull;
//import io.flutter.plugin.common.BinaryMessenger;
//import io.flutter.plugin.common.MethodCall;
//import io.flutter.plugin.common.MethodChannel;
//import io.flutter.plugin.platform.PlatformView;
//
//import java.util.ArrayList;
//import java.util.Map;
//
//public class PlayerView implements PlatformView, MethodChannel.MethodCallHandler {
//    private final LinearLayout layout;
//
//
//    public PlayerView(Context context, BinaryMessenger messenger, int viewId) {
//        this.layout = new LinearLayout(context);
//        this.layout.setLayoutParams(new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
//        // Get the singleton instance of VideoPlayerView
//
//        // Add the PlayerView to the layout
//        androidx.media3.ui.PlayerView playerView = new androidx.media3.ui.PlayerView(context);
//        playerView.setPlayer(videoPlayerView.getPlayer());
//        layout.addView(playerView);
//        MethodChannel methodChannel = new MethodChannel(messenger, "flutter_flex_player_" + viewId);
//        methodChannel.setMethodCallHandler(this);
//    }
//
//    @Override
//    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
//        switch (call.method) {
//            case "load":
//                Map<Object, Object> arguments = (Map<Object, Object>) call.arguments;
//                loadPlayer(arguments);
//                result.success(true);
//                break;
//            case "play":
//                if (videoPlayerView != null) {
//                    videoPlayerView.getPlayer().play();
//                }
//                result.success(true);
//                break;
//            case "pause":
//                if (videoPlayerView != null) {
//                    videoPlayerView.getPlayer().pause();
//                }
//                result.success(true);
//                break;
//            case "dispose":
//                if (videoPlayerView != null) {
//                    videoPlayerView.releasePlayer();
//                }
//                result.success(true);
//                break;
//            default:
//                result.notImplemented();
//                break;
//        }
//    }
//
//    private void loadPlayer(@NonNull Map<Object, Object> arguments) {
//
//        // Load the player in the singleton instance
//        videoPlayerView.loadPlayer(arguments);
//    }
//
//    @Override
//    public View getView() {
//        return layout;
//    }
//
//    @Override
//    public void dispose() {
//    }
//}



package com.example.flutter_flex_player;

import android.annotation.SuppressLint;
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
import java.util.Random;

public class PlayerView implements PlatformView, MethodChannel.MethodCallHandler, EventChannel.StreamHandler {
    private final LinearLayout layout;
    private final Handler handler;
    private EventChannel.EventSink messenger; 
    private VideoPlayerView videoPlayerView = null;

    @OptIn(markerClass = UnstableApi.class)
    @SuppressLint("SetTextI18n")
    public PlayerView(Context context, BinaryMessenger messenger, int viewId) {
        layout = new LinearLayout(context);
        layout.setLayoutParams(new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
        this.videoPlayerView = VideoPlayerView.getInstance(context);
        layout.removeAllViews();
        androidx.media3.ui.PlayerView playerView = new androidx.media3.ui.PlayerView(context);
        playerView.setPlayer(videoPlayerView.getPlayer());
        playerView.setUseController(false);
        layout.addView(playerView);
        handler = new Handler();
        MethodChannel methodChannel = new MethodChannel(messenger, "flutter_flex_player_" + viewId);
        methodChannel.setMethodCallHandler(this);
        EventChannel eventChannel = new EventChannel(messenger, "flutter_flex_player/events_" + viewId);
        eventChannel.setStreamHandler(this);
    }

    @Override
    public void onListen(Object arguments, EventChannel.EventSink events) {
        messenger = events;
    }

    private void sendMapData(Map<Object, Object> map) {
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
                if (videoPlayerView != null) {
                    videoPlayerView.getPlayer().play();
                }
                result.success(true);
                break;
            case "pause":
                if (videoPlayerView != null) {
                    videoPlayerView.getPlayer().pause();
                }
                result.success(true);
                break;
            case "seekTo":
                int position = (int) call.arguments;
                if (videoPlayerView != null) {
                    videoPlayerView.getPlayer().seekTo(position);
                }
                result.success(true);
                break;
            case "setVolume":
                double volume = (double) call.arguments;
                if (videoPlayerView != null) {
                    videoPlayerView.getPlayer().setVolume((float) volume);
                }
                result.success(true);
                break;
            case "setPlaybackSpeed":
                double playbackSpeed = (double) call.arguments;
                if (videoPlayerView != null) {
                    videoPlayerView.getPlayer().setPlaybackSpeed((float) playbackSpeed);
                }
                result.success(true);
                break;
            case "changequality":
                String quality = (String) call.arguments;
                if (videoPlayerView != null) {
//                    videoPlayerView.setQuality();
                }
                result.success(true);
                break;
            case "dispose":
                if (videoPlayerView != null) {
                    videoPlayerView.releasePlayer();
                }
                result.success(true);

                break;
        }
    }

    private void loadPlayer(@NonNull Map<Object, Object> arguments) {
        try {
            this.videoPlayerView.loadPlayer(arguments);
        } catch (Exception e) {
            Log.e("PlayerView", "Error loading player: " + e.getMessage());
        }
    }

    @Nullable
    @Override
    public View getView() {
        return layout;
    }

    @Override
    public void dispose() {
    }
}
