import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class FlexYoutubeController extends GetxController {
  static FlexYoutubeController get instance =>
      Get.isRegistered<FlexYoutubeController>()
          ? Get.find()
          : Get.put(FlexYoutubeController());

  RxList<VideoData> videosList = <VideoData>[].obs;

  final yt = YoutubeExplode();

  String cleanHtmlString(String html) {
    // Remove \n and replace \/ with /
    String cleaned =
        html.replaceAll(RegExp(r'\n'), '').replaceAll(RegExp(r'\/'), '/');

    cleaned = cleaned.split('<script')[0];
    return cleaned;
  }

  Future<void> getVideoDetails(String videoId) async {
    try {
      videosList.clear();
      final video = await yt.videos.get(VideoId(videoId));
      if (video.isLive) {
        final videoUrl =
            await yt.videos.streams.getHttpLiveStreamUrl(VideoId(videoId));
        final response = await get(Uri.parse(videoUrl));
        String m3u8Content = response.body;
        // Extract stream qualities
        List<Map<String, String>> qualities = parseM3U8Content(m3u8Content);
        for (var element in qualities) {
          videosList.add(
            VideoData(
              url: element['url'] ?? "",
              quality: element['resolution'].toString().split("x").last,
            ),
          );
        }
      } else {
        final videoinfo = await yt.videos.streams.getManifest(videoId);

        if (videoinfo.videoOnly.isNotEmpty) {
          for (var element in videoinfo.videoOnly) {
            final video = VideoData(
              url: element.url.toString(),
              quality: element.videoQualityLabel.toString(),
              format: element.container.name.toString(),
              audioUrl: videoinfo.audio.first.url.toString(),
            );
            videosList.add(video);
          }
        }
      }
      sortByQuality();
    } catch (e) {
      rethrow;
    }
  }

  sortByQuality() {
    videosList.sort((a, b) {
      return int.parse(a.quality.split("p").first) -
          int.parse(b.quality.split("p").first);
    });
  }

  Future<bool> isNotLive(String videoId) async {
    final video = await yt.videos.get(VideoId(videoId));
    return !video.isLive;
  }
}

List<Map<String, String>> parseM3U8Content(String m3u8Content) {
  List<Map<String, String>> qualities = [];
  List<String> lines = m3u8Content.split('\n');

  String? resolution;
  String? bandwidth;
  String? url;

  for (String line in lines) {
    if (line.startsWith('#EXT-X-STREAM-INF')) {
      // Extract bandwidth and resolution
      RegExp bandwidthExp = RegExp(r'BANDWIDTH=(\d+)');
      RegExp resolutionExp = RegExp(r'RESOLUTION=(\d+x\d+)');

      bandwidth = bandwidthExp.firstMatch(line)?.group(1);
      resolution = resolutionExp.firstMatch(line)?.group(1);
    } else if (line.endsWith('.m3u8')) {
      // This line should be the URL to the specific stream
      url = line;

      if (bandwidth != null && resolution != null) {
        qualities.add({
          'resolution': resolution,
          'bandwidth': bandwidth,
          'url': url,
        });

        // Reset variables
        resolution = null;
        bandwidth = null;
        url = null;
      }
    }
  }
  return qualities;
}

class VideoData {
  final String url;
  final String quality;
  final String format;
  final String audioUrl;
  final bool isLive;

  VideoData({
    required this.url,
    required this.quality,
    this.format = "",
    this.audioUrl = "",
    this.isLive = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'url': url,
      'quality': quality,
      'format': format,
      'audioUrl': audioUrl,
      'isLive': isLive,
    };
  }

  factory VideoData.fromMap(Map<String, dynamic> map) {
    return VideoData(
      url: map['url'],
      quality: map['quality'],
      format: map['format'],
      audioUrl: map['audioUrl'],
      isLive: map['isLive'],
    );
  }
}
