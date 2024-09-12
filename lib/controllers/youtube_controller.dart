import 'dart:convert';
import 'dart:developer';

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

  Future<void> getInitialUrl(String videoId, {bool isLive = false}) async {
    try {
      videosList.clear();
      if (isLive) {
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

        if (videoinfo.muxed.isNotEmpty) {
          final video = VideoData(
            url: videoinfo.muxed.first.url.toString(),
            quality: videoinfo.muxed.first.qualityLabel,
            format: 'mp4',
            size: '${videoinfo.muxed.first.size.totalMegaBytes} MB',
          );
          videosList.add(video);
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> getVideoInfo(String videoId) async {
    try {
      final response = await get(
        Uri.parse(
          "https://cdn34.savetube.me/info?url=https://www.youtube.com/watch?v=$videoId",
        ),
      );
      if (response.statusCode == 200) {
        List<String> qualities = [];
        List formats =
            (jsonDecode(response.body)['data']['video_formats'] as List);
        qualities.addAll(formats
            .where((e) => e['quality'] != 360)
            .toList()
            .map((e) => e['quality'].toString()));
        final key = jsonDecode(response.body)['data']['key'];
        if (qualities.isNotEmpty) {
          for (var element in qualities) {
            final url = await getDownloadUrl(
              url: "https://cdn35.savetube.me/download/video/$element/$key",
            );
            if (url != null) {
              videosList.add(
                VideoData(
                  url: url,
                  quality: "${element}p",
                  format: "mp4",
                  size: "0",
                ),
              );
            }
          }
          videosList.refresh();
        }
        sortByQuality();
      }
    } catch (e) {
      log("Error $e");
    }
  }

  Future<String?> getDownloadUrl({
    required String url,
  }) async {
    try {
      final response = await get(Uri.parse(url));
      final parsed = jsonDecode(response.body);
      return parsed['data']['downloadUrl'];
    } catch (e) {
      return null;
    }
  }

  sortByQuality() {
    videosList.sort((a, b) {
      return int.parse(a.quality.split("p").first) -
          int.parse(b.quality.split("p").first);
    });
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
  final String size;
  final bool isLive;

  VideoData({
    required this.url,
    required this.quality,
    this.format = "",
    this.size = "",
    this.isLive = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'url': url,
      'quality': quality,
      'format': format,
      'size': size,
      'isLive': isLive,
    };
  }

  factory VideoData.fromMap(Map<String, dynamic> map) {
    return VideoData(
      url: map['url'],
      quality: map['quality'],
      format: map['format'],
      size: map['size'],
      isLive: map['isLive'],
    );
  }
}
