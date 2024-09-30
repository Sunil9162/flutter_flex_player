//package com.example.flutter_flex_player;
//
//import android.annotation.SuppressLint;
//import android.content.Context;
//import android.net.Uri;
//
//import androidx.annotation.NonNull;
//import androidx.annotation.OptIn;
//import androidx.media3.common.C;
//import androidx.media3.common.Format;
//import androidx.media3.common.MediaItem;
//import androidx.media3.common.TrackGroup;
//import androidx.media3.common.Tracks;
//import androidx.media3.common.util.UnstableApi;
//import androidx.media3.datasource.DefaultDataSource;
//import androidx.media3.exoplayer.ExoPlayer;
//import androidx.media3.exoplayer.Renderer;
//import androidx.media3.exoplayer.RendererConfiguration;
//import androidx.media3.exoplayer.source.MediaSource;
//import androidx.media3.exoplayer.source.MergingMediaSource;
//import androidx.media3.exoplayer.source.ProgressiveMediaSource;
//import androidx.media3.exoplayer.source.TrackGroupArray;
//import androidx.media3.exoplayer.trackselection.DefaultTrackSelector;
//import androidx.media3.exoplayer.trackselection.TrackSelection;
//import androidx.media3.exoplayer.trackselection.TrackSelectionArray;
//import androidx.media3.exoplayer.trackselection.TrackSelectorResult;
//
//import java.util.List;
//
//@SuppressLint("UnsafeOptInUsageError")
//public class QualityTrackSelector extends DefaultTrackSelector {
//
//    private List<VideoData> videoData;
//    private int selectedQualityIndex;
//
//    public QualityTrackSelector(Context context, List<VideoData> videoData) {
//        super(context);
//        this.videoData = videoData;
//        this.selectedQualityIndex = 0; // Default quality
//    }
//
//    @Override
//    public TrackSelectorResult selectTracks(Renderer renderer, TrackGroupArray trackGroups, TrackSelectionArray tracks) {
//        // Assuming the first track group represents the video quality
//        TrackGroup trackGroup = trackGroups.get(0);
//        TrackGroupArray trackGroupArray = new TrackGroupArray(new TrackGroup[]{trackGroup});
//
//        // Create track selections for each quality
//        TrackSelection[] trackSelections = new TrackSelection[trackGroup.length];
//        for (int i = 0; i < trackGroup.length; i++) {
//            trackSelections[i] = new QualityTrackSelection(trackGroup, i, videoData.get(i).getVideoUrl());
//        }
//
//        // Create renderer configurations (assuming none are disabled)
//        RendererConfiguration[] rendererConfigurations = new RendererConfiguration[1];
//        rendererConfigurations[0] = new RendererConfiguration.Builder().build();
//
//        // Create Tracks object
//        Tracks tracksObject = new Tracks(trackGroupArray);
//
//        // Return TrackSelectorResult
//        return new TrackSelectorResult(rendererConfigurations, trackSelections, tracksObject, null);
//    }
//
//    public void selectQuality(int index) {
//        selectedQualityIndex = index;
//        // Update the media source with the new quality URL
//        updateMediaSource();
//    }
//
//    private void updateMediaSource() {
//        // Create a new media source with the selected quality URL
//        VideoData selectedVideo = videoData.get(selectedQualityIndex);
//        String videoUrl = selectedVideo.getVideoUrl();
//        String audioUrl = selectedVideo.getAudioUrl();
//
//        MediaSource videoSource = buildMediaSource(Uri.parse(videoUrl));
//        MediaSource audioSource = buildMediaSource(Uri.parse(audioUrl));
//        MergingMediaSource mergedSource = new MergingMediaSource(videoSource, audioSource);
//
//        // Update the player's media source
//        ExoPlayer player = VideoPlayerView.getInstance(null).getPlayer();
//        player.setMediaSource(mergedSource);
//        player.prepare();
//    }
//
//    @OptIn(markerClass = UnstableApi.class)
//    private MediaSource buildMediaSource(Uri uri) {
//        assert context != null;
//        return new ProgressiveMediaSource.Factory(new DefaultDataSource.Factory(context))
//                .createMediaSource(MediaItem.fromUri(uri));
//    }
//
//    public static class QualityTrackSelection implements TrackSelection {
//
//        private final TrackGroup trackGroup;
//        private final int qualityIndex;
//        private final String videoUrl;
//
//        public QualityTrackSelection(TrackGroup trackGroup, int qualityIndex, String videoUrl) {
//            this.trackGroup = trackGroup;
//            this.qualityIndex = qualityIndex;
//            this.videoUrl = videoUrl;
//        }
//
//        @Override
//        public int getType() {
//            return C.TRACK_TYPE_VIDEO; // Specify the track type as video
//        }
//
//        @NonNull
//        @Override
//        public TrackGroup getTrackGroup() {
//            return trackGroup; // Return the track group
//        }
//
//        @Override
//        public int length() {
//            return trackGroup.length; // Return the number of tracks in the group
//        }
//
//        @NonNull
//        @Override
//        public Format getFormat(int index) {
//            return trackGroup.getFormat(index); // Return the format at the specified index
//        }
//
//        @Override
//        public int getIndexInTrackGroup(int index) {
//            return index; // Return the index within the track group
//        }
//
//        @Override
//        public int indexOf(@NonNull Format format) {
//            return trackGroup.indexOf(format); // Return the index of the specified format
//        }
//
//        @Override
//        public int indexOf(int indexInTrackGroup) {
//            return indexInTrackGroup; // Return the index within the track group
//        }
//    }
//}