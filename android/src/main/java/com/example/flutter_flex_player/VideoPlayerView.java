package com.example.flutter_flex_player;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.SurfaceTexture;
import android.net.Uri;

import androidx.annotation.NonNull;
import androidx.annotation.OptIn;
import androidx.media3.common.MediaItem;
import androidx.media3.common.MimeTypes;
import androidx.media3.common.PlaybackException;
import androidx.media3.common.Player;
import androidx.media3.common.Timeline;
import androidx.media3.common.util.UnstableApi;
import androidx.media3.common.util.Util;
import androidx.media3.datasource.DataSource;
import androidx.media3.datasource.DefaultDataSource;
import androidx.media3.datasource.DefaultHttpDataSource;
import androidx.media3.exoplayer.DefaultLoadControl;
import androidx.media3.exoplayer.ExoPlayer;
import androidx.media3.exoplayer.hls.HlsMediaSource;
import androidx.media3.exoplayer.source.MediaSource;
import androidx.media3.exoplayer.source.MergingMediaSource;
import androidx.media3.exoplayer.source.ProgressiveMediaSource;
import androidx.media3.ui.PlayerView;

import android.os.Handler;
import android.util.Log;
import android.view.Surface;


import com.google.gson.Gson;

import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.Objects;

import io.flutter.plugin.common.EventChannel;

public class VideoPlayerView implements EventChannel.StreamHandler {
    @SuppressLint("StaticFieldLeak")
    private static VideoPlayerView instance;
    private ExoPlayer player;
    private final Context context;
    private ArrayList<VideoData> videoData;
    private EventChannel.EventSink eventSink;
    private Handler handler;
    private Runnable positionRunnable;
    private static final long POSITION_UPDATE_INTERVAL_MS = 1000;
    private Map<Object, Object> arguments;
    private FileType fileType;

    @OptIn(markerClass = UnstableApi.class)
    private VideoPlayerView(Context context) {
        this.context = context;
        initPlayer(context);
    }

    private void initPlayer(Context context) {
        handler = new Handler();
        if (player == null) {
            player = new ExoPlayer.Builder(context).build();
            player.addListener(new Player.Listener() {
                @Override
                public void onPlaybackStateChanged(int playbackState) {
                    Map<Object, Object> map = new HashMap<>();

                    switch (playbackState) {
                        case Player.STATE_IDLE:
                            map.put("state", "stopped");  // Stopped or idle
                            break;
                        case Player.STATE_BUFFERING:
                            map.put("state", "buffering");  // Buffering
                            break;
                        case Player.STATE_READY:
                            if (player.getPlayWhenReady()) {
                                map.put("state", "playing");  // Playing
                            } else {
                                map.put("state", "paused");  // Paused
                            }
                            break;
                        case Player.STATE_ENDED:
                            map.put("state", "ended");  // Ended
                            break;
                    }
                    sendMapData(map);
                }

                @Override
                public void onTimelineChanged(@NonNull Timeline timeline, @Player.TimelineChangeReason int reason) {
                    notifyPlayerTimeChanged(timeline);
                }

                @Override
                public void onIsPlayingChanged(boolean isPlaying) {
                    Map<Object, Object> map = new HashMap<>();
                    if (player.getPlaybackState() != Player.STATE_BUFFERING) {
                        map.put("state", isPlaying ? "playing" : "paused");
                    }
                    sendMapData(map);
                }

                @Override
                public void onPlayerError(@NonNull PlaybackException error) {
                    Map<Object, Object> map = new HashMap<>();
                    map.put("error", error.getMessage());
                    sendMapData(map);
                }
            });

        }
    }

    private void startPositionUpdate() {
        positionRunnable = new Runnable() {
            @Override
            public void run() {
                if (eventSink != null && player != null && player.getPlaybackState() != Player.STATE_ENDED) {
                    long duration = player.getDuration();
                    long position = player.getCurrentPosition();
                    Map<Object, Object> map = new HashMap<>();
                    map.put("position", position);
                    map.put("duration", duration);
                    map.put("buffered", player.getBufferedPosition());
                    // Send position and duration to the Flutter side
                    sendMapData(map);
                    // Post the runnable again to keep updating position
                }
                handler.postDelayed(this, POSITION_UPDATE_INTERVAL_MS);
            }
        };

        // Start the first update immediately
        handler.post(positionRunnable);
    }

    // Call this to stop position updates when the player is stopped or destroyed
    private void stopPositionUpdate() {
        if (positionRunnable != null) {
            handler.removeCallbacks(positionRunnable);
        }
    }

    private void notifyPlayerTimeChanged(@NonNull Timeline timeline) {
        if (eventSink != null && player != null) {
            Map<Object, Object> map = new HashMap<>();
            map.put("position", player.getCurrentPosition());
            map.put("duration", player.getDuration());
            map.put("buffered", player.getBufferedPosition());
            sendMapData(map);
        }
    }


    private void sendInitializationEvent(InitializationEvent event) {
        if (eventSink != null) {
            Map<Object, Object> map = new HashMap<>();
            map.put("initializationEvent", event.name()); // Send the event name as a string
            sendMapData(map); // This method should send the event data to Flutter
        } else {
            Log.d("PlayerView", "EventSink is null, cannot send initialization event");
        }
    }

    private void sendMapData(Map<Object, Object> map) {
        Gson json = new Gson();
        sendEvent(json.toJson(map));
    }

    // Send the event to Flutter on Main Thread
    private void sendEvent(Object event) {
        if (eventSink != null) {
            Log.d("PlayerView", "Sending event: " + event.toString());
            handler.post(() -> eventSink.success(event));
        } else {
            Log.d("PlayerView", "EventSink is null");
        }
    }

    public void setTextureView(SurfaceTexture textureView) {
        Surface surface = new Surface(textureView);
        player.setVideoSurface(surface);
    }

    // Singleton instance method
    public static VideoPlayerView getInstance(Context context) {
        if (instance == null) {
            instance = new VideoPlayerView(context);
        }
        return instance;
    }


    public ExoPlayer getPlayer() {
        return player;
    }

    @OptIn(markerClass = UnstableApi.class)
    public synchronized void loadPlayer(@NonNull Map<Object, Object> arguments) {
        if (this.videoData != null) {
            return;
        }
        try {
            if (player == null) {
                initPlayer(this.context);
            } else {
                player.stop();
                player.clearMediaItems();
                initPlayer(this.context);
            }
            startPositionUpdate();
            this.arguments = arguments;
            sendInitializationEvent(InitializationEvent.initializing);
            Log.d("PlayerView", "Loading player");
            this.videoData = new ArrayList<>();
            ArrayList<Map<Object, Object>> videoData = ((ArrayList<Map<Object, Object>>) arguments.get("videoData"));
            assert videoData != null;
            this.videoData.clear();
            for (Map<Object, Object> video : videoData) {
                this.videoData.add(VideoData.fromJson(video));
            }
            if (videoData.isEmpty()) {
                Log.e("VideoPlayerView", "No video data provided");
                return;
            }
            boolean autoPlay = (boolean)  Objects.requireNonNull(arguments.get("autoPlay"));
            boolean loop = (boolean)  Objects.requireNonNull(arguments.get("loop"));
            boolean mute = (boolean)  Objects.requireNonNull(arguments.get("mute"));
            double volume = (double)  Objects.requireNonNull(arguments.get("volume"));
            double playbackSpeed = (double) Objects.requireNonNull(arguments.get("playbackSpeed"));
            int position = (int) Objects.requireNonNull(arguments.get("position"));
            int index = (Integer) Objects.requireNonNull(arguments.get("index"));
            player.setPlayWhenReady(autoPlay);
            player.setRepeatMode(loop ? ExoPlayer.REPEAT_MODE_ALL : ExoPlayer.REPEAT_MODE_OFF);
            player.setVolume((float) volume);
            player.setVolume(mute ? 0 : 1);
            player.setPlaybackSpeed((float) playbackSpeed);
            player.seekTo(position);
            fileType = FileType.values()[(Integer)  Objects.requireNonNull(arguments.get("type"))];
            initializePlayer((Integer) arguments.get("type"), index);
        } catch (Exception e) {
            sendInitializationEvent(InitializationEvent.uninitialized);
            Log.e("PlayerView", "Error loading player: " + e.getMessage());
        }
    }

    @OptIn(markerClass = UnstableApi.class)
    private void initializePlayer(Integer type,Integer index) {
        try {
            FileType filetype = FileType.values()[type];
            if (filetype == FileType.file) {
                playWithFile(index);
            } else if (filetype == FileType.url) {
                playWithUrl(index);
            } else {
                String audioUrl = videoData.get(index).getAudioUrl();
                String videoUrl = videoData.get(index).getVideoUrl();
                playWithAudioAndVideo(videoUrl, audioUrl);
                sendInitializationEvent(InitializationEvent.initialized);
            }
        } catch (Exception e) {
            sendInitializationEvent(InitializationEvent.uninitialized);
        }
    }

    @OptIn(markerClass = UnstableApi.class)
    private void playWithUrl(Integer index) {
        try {
            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.N) {
                Uri fileUri = Uri.parse(this.videoData.get(index).getVideoUrl());
                MediaSource fileSource = buildMediaSource(fileUri);
                player.setMediaSource(fileSource);
                player.prepare();
                player.play();
                sendInitializationEvent(InitializationEvent.initialized);
            }
        } catch (Exception e) {
            sendInitializationEvent(InitializationEvent.uninitialized);
        }
    }

    @OptIn(markerClass = UnstableApi.class)
    private void playWithFile(Integer integer) {
        try {
            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.N) {
                File file = new File(String.valueOf(this.videoData.get(integer).getVideoUrl()));
                Uri fileUri = Uri.parse(file.getPath());
                MediaSource fileSource = buildMediaSource(fileUri);
                player.setMediaSource(fileSource);
                player.prepare();
                player.play();
                sendInitializationEvent(InitializationEvent.initialized);
            }
        } catch (Exception e) {
            sendInitializationEvent(InitializationEvent.uninitialized);
        }
    }

    @OptIn(markerClass = UnstableApi.class)
    private void playWithAudioAndVideo(String videoUrl, String audioUrl) {
        try {
            if (videoUrl == null || audioUrl == null) {
                Log.e("VideoPlayerView", "Invalid video or audio URL");
                return;
            }
            MediaSource videoSource = buildMediaSource(Uri.parse(videoUrl));
            MediaSource audioSource = buildMediaSource(Uri.parse(audioUrl));
            MergingMediaSource mergedSource = new MergingMediaSource(videoSource, audioSource);
            player.setMediaSource(mergedSource);
            player.prepare();
            player.play();
            Log.d("PlayerView", "Player started");
        } catch (Exception e) {
            Log.e("PlayerView", Objects.requireNonNull(e.getMessage()));
        }
    }

    @OptIn(markerClass = UnstableApi.class)
    private MediaSource buildMediaSource(Uri uri) {

        if (uri.toString().endsWith(".m3u8")) {
            Log.e("PlayerView", "HLS Media Source");

            DataSource.Factory dataSourceFactory = new DefaultHttpDataSource.Factory()
                    .setConnectTimeoutMs(10_000)   // Set connection timeout
                    .setReadTimeoutMs(10_000)      // Set read timeout
                    .setAllowCrossProtocolRedirects(true);  // Allow redirects if needed
            HlsMediaSource.Factory hlsFactory = new HlsMediaSource.Factory(dataSourceFactory);
            return hlsFactory.createMediaSource(MediaItem.fromUri(uri));
        } else {
            return new ProgressiveMediaSource.Factory(new DefaultDataSource.Factory(context))
                    .createMediaSource(MediaItem.fromUri(uri));
        }
    }

    public void releasePlayer() {
        if (player != null) {
            player.release();
            videoData = null;
            player = null;
            instance = null;
            stopPositionUpdate();
            Log.d("PlayerView", "Player released");
        }
    }

    @Override
    public void onListen(Object arguments, EventChannel.EventSink events) {
        this.eventSink = events;
        if (player != null) {
            notifyPlayerTimeChanged(player.getCurrentTimeline());
        }
        Log.d("PlayerView", "EventSink Added");
    }

    @Override
    public void onCancel(Object arguments) {
        this.eventSink = null;
        stopPositionUpdate();
    }

    @OptIn(markerClass = UnstableApi.class)
    public void setQuality(String quality) {
        VideoData newVideo = null;
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.N) {
            newVideo = videoData.stream()
                    .filter(video -> video.getQuality().equals(quality))
                    .findFirst()
                    .orElse(null);
        }
        if (newVideo != null) {
            if (fileType == FileType.youtube) {
                String audioUrl = newVideo.getAudioUrl();
                String videoUrl = newVideo.getVideoUrl();
                // Call the method to switch the quality without pausing
                switchQualityWithoutPause(videoUrl, audioUrl);
            } else if (fileType == FileType.file) {
                File file = new File(String.valueOf(newVideo.getVideoUrl()));
                Uri fileUri = Uri.parse(file.getPath());
                MediaSource fileSource = buildMediaSource(fileUri);
                player.setMediaSource(fileSource, false);
                player.prepare();
            } else {
                String videoUrl = newVideo.getVideoUrl();
                Uri fileUri = Uri.parse(videoUrl);
                MediaSource fileSource = buildMediaSource(fileUri);
                player.setMediaSource(fileSource, false);
                player.prepare();
            }
        }
    }

    @OptIn(markerClass = UnstableApi.class)
    private void switchQualityWithoutPause(String videoUrl, String audioUrl) {
        // Create new media sources for the new quality
        MediaSource newVideoSource = buildMediaSource(Uri.parse(videoUrl));
        MediaSource newAudioSource = buildMediaSource(Uri.parse(audioUrl));
        MergingMediaSource newMergedSource = new MergingMediaSource(newVideoSource, newAudioSource);

        // Save the current position and play state
        boolean wasPlaying = player.isPlaying();

        // Set the new media source and keep the playback state (don't call prepare)
        player.setMediaSource(newMergedSource, /* resetPosition= */ false);

        // Ensure playback continues if it was playing before
        if (wasPlaying) {
            player.play(); // Resume playback if it was playing before
        }
    }


    public void reloadPlayer() {
        loadPlayer(this.arguments);
    }
}
