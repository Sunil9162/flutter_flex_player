package com.example.flutter_flex_player;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.SurfaceTexture;
import android.net.Uri;

import androidx.annotation.NonNull;
import androidx.annotation.OptIn;
import androidx.media3.common.MediaItem;
import androidx.media3.common.PlaybackException;
import androidx.media3.common.Player;
import androidx.media3.common.Timeline;
import androidx.media3.common.util.UnstableApi;
import androidx.media3.datasource.DefaultDataSource;
import androidx.media3.exoplayer.ExoPlayer;
import androidx.media3.exoplayer.source.MediaSource;
import androidx.media3.exoplayer.source.MergingMediaSource;
import androidx.media3.exoplayer.source.ProgressiveMediaSource;
import androidx.media3.exoplayer.source.TrackGroupArray;
import androidx.media3.ui.PlayerView;

import android.os.Handler;
import android.util.Log;
import android.view.Surface;
import androidx.media3.common.TrackGroup;
import androidx.media3.common.Format;
import androidx.media3.exoplayer.trackselection.DefaultTrackSelector;
import androidx.media3.common.TrackSelectionOverride;


import com.google.gson.Gson;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;

import io.flutter.plugin.common.EventChannel;

public class VideoPlayerView implements EventChannel.StreamHandler {
    @SuppressLint("StaticFieldLeak")
    private static VideoPlayerView instance;
    private ExoPlayer player;
    private final Context context;
    private ArrayList<VideoData> videoData;
    private EventChannel.EventSink eventSink;
    private final Handler handler;
    private Runnable positionRunnable;
    private static final long POSITION_UPDATE_INTERVAL_MS = 1000;
    private PlayerView playerView;

    @OptIn(markerClass = UnstableApi.class)
    private VideoPlayerView(Context context) {
        this.context = context;
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
                    if(player.getPlaybackState() != Player.STATE_BUFFERING) {
                        map.put("state", isPlaying ? "playing" : "paused");
                    }
                    sendMapData(map);
                }

                @Override
                public void onPlayerError(@NonNull PlaybackException error) {
                    Map<Object, Object> map = Map.of("error", error.getMessage());
                    sendMapData(map);
                }
            });
            startPositionUpdate();

        }
    }

    private void startPositionUpdate() {
        positionRunnable = new Runnable() {
            @Override
            public void run() {
                if (eventSink != null && player != null) {
                    long duration = player.getDuration();
                    long position = player.getCurrentPosition();

                    Map<Object, Object> map = Map.of(
                            "position", position,
                            "duration", duration,
                            "buffered", player.getBufferedPosition()
                    );
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
            Map<Object, Object> map = Map.of(
                    "duration", player.getDuration(),
                    "position", player.getCurrentPosition(),
                    "buffered", player.getBufferedPosition()
            );
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
        }else {
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
    public void loadPlayer(@NonNull Map<Object, Object> arguments) {
        if (this.videoData != null) {
            return;
        }
        try {
            sendInitializationEvent(InitializationEvent.initializing);
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
            player.setPlayWhenReady(autoPlay);
            player.setRepeatMode(loop ? ExoPlayer.REPEAT_MODE_ALL : ExoPlayer.REPEAT_MODE_OFF);
            player.setVolume((float) volume);
            player.setVolume(mute?0:1);
            player.setPlaybackSpeed((float) playbackSpeed);
            player.seekTo(position);
            initializePlayer();
        } catch (Exception e) {
            sendInitializationEvent(InitializationEvent.uninitialized);
            Log.e("PlayerView", "Error loading player: " + e.getMessage());
        }
    }

    @OptIn(markerClass = UnstableApi.class)
    private void initializePlayer() {
        try {
            String audioUrl = videoData.get(0).getAudioUrl();
            String videoUrl = videoData.get(0).getVideoUrl();
            playWithAudioAndVideo(videoUrl, audioUrl);
            sendInitializationEvent(InitializationEvent.initialized);
        } catch (Exception e){
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
        return new ProgressiveMediaSource.Factory(new DefaultDataSource.Factory(context))
                .createMediaSource(MediaItem.fromUri(uri));
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
        Log.d("PlayerView","EventSink Added");
    }

    @Override
    public void onCancel(Object arguments) {
        this.eventSink = null;
        stopPositionUpdate();
    }

    public void setQuality(String quality) {
        switchQualityFromVideoData(quality,this.videoData);
    }


    @OptIn(markerClass = UnstableApi.class)
    private void switchQualityFromVideoData(String quality, ArrayList<VideoData> videoDataList) {
        // Create TrackGroupArray from the available VideoData
        TrackGroupArray trackGroupArray = createTrackGroupsFromVideoData(videoDataList);

        // Build the TrackSelector parameters
        DefaultTrackSelector.Parameters.Builder builder = (DefaultTrackSelector.Parameters.Builder) player.getTrackSelectionParameters().buildUpon();

        // Loop through TrackGroups to find the matching quality
        for (int i = 0; i < trackGroupArray.length; i++) {
            TrackGroup trackGroup = trackGroupArray.get(i);

            // We only have one format in each TrackGroup (videoFormat) from the earlier step
            Format format = trackGroup.getFormat(0);

            // Compare the height with the selected quality
            if (String.valueOf(format.height).equals(quality)) {
                // Create a TrackSelectionOverride for the matching quality
                TrackSelectionOverride override = new TrackSelectionOverride(trackGroup, 0);  // Select the first format (we only have one)
                builder.addOverride(override);
                Objects.requireNonNull(player.getTrackSelector()).setParameters(builder.build());
                return;
            }
        }
    }


    @OptIn(markerClass = UnstableApi.class)
    private TrackGroupArray createTrackGroupsFromVideoData(ArrayList<VideoData> videoDataList) {
        TrackGroup[] trackGroups = new TrackGroup[videoDataList.size()];

        for (int i = 0; i < videoDataList.size(); i++) {
            VideoData videoData = videoDataList.get(i);

            // Create a Format object for each VideoData quality (you can customize based on audio, video, etc.)
            Format videoFormat = new Format.Builder()
                    .setSampleMimeType("video/mp4")
                    .setHeight(getQualityHeight(videoData.getQuality()))  // Convert "quality" string into height (like 720p -> 720)
                    .build();

            // Create a TrackGroup with one Format
            trackGroups[i] = new TrackGroup(videoFormat);
        }
        return new TrackGroupArray(trackGroups);
    }

    private int getQualityHeight(String quality) {
        return Integer.parseInt(quality);
    }
}
