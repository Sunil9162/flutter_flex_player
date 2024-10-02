
package com.example.flutter_flex_player;

import android.content.Context;
import android.graphics.SurfaceTexture;
import android.view.TextureView;
import android.view.View;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import io.flutter.Log;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;
import android.os.Handler;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import com.google.gson.Gson;
import java.util.Map;

public class PlayerView implements PlatformView, MethodChannel.MethodCallHandler  {
    private final LinearLayout layout;
    private VideoPlayerView videoPlayerView = null;

    public PlayerView(Context context, BinaryMessenger messenger, int viewId) {
        TextureView textureView = new TextureView(context);
        layout = new LinearLayout(context);
        layout.setLayoutParams(new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
        this.videoPlayerView = VideoPlayerView.getInstance(context);
        layout.addView(textureView);
        textureView.setSurfaceTextureListener(new TextureView.SurfaceTextureListener() {

            @Override
            public void onSurfaceTextureAvailable(@NonNull SurfaceTexture surface, int width, int height) {
                videoPlayerView.setTextureView(surface);
            }

            @Override
            public void onSurfaceTextureSizeChanged(@NonNull SurfaceTexture surface, int width, int height) {

            }

            @Override
            public boolean onSurfaceTextureDestroyed(@NonNull SurfaceTexture surface) {
                return false;
            }

            @Override
            public void onSurfaceTextureUpdated(@NonNull SurfaceTexture surface) {

            }
        });
        MethodChannel methodChannel = new MethodChannel(messenger, "flutter_flex_player");
        methodChannel.setMethodCallHandler(this);
        EventChannel eventChannel = new EventChannel(messenger, "flutter_flex_player/events");
        eventChannel.setStreamHandler(this.videoPlayerView);
    }



    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        switch (call.method) {
            case "load":
                Map<Object, Object> arguments = (Map<Object, Object>) call.arguments;
                loadPlayer(arguments);
                result.success("Player Loaded");
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
                    videoPlayerView.setQuality(quality);
                }
                result.success(true);
                break;
            case "reload":
                videoPlayerView.reloadPlayer();
                result.success("Player Reloading...");
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
