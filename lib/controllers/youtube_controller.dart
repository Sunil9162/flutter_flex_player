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

  String cleanHtmlString(String html) {
    // Remove \n and replace \/ with /
    String cleaned =
        html.replaceAll(RegExp(r'\n'), '').replaceAll(RegExp(r'\/'), '/');

    cleaned = cleaned.split('<script')[0];
    return cleaned;
  }

  Future<void> getInitialUrl(String videoId) async {
    try {
      videosList.clear();
      final videoinfo = await YoutubeExplode().videos.streamsClient.getManifest(
            videoId,
          );
      if (videoinfo.muxed.isNotEmpty) {
        final video = VideoData(
          url: videoinfo.muxed.first.url.toString(),
          quality: videoinfo.muxed.first.qualityLabel,
          format: 'mp4',
          size: '${videoinfo.muxed.first.size.totalMegaBytes} MB',
        );
        videosList.add(video);
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
        log(qualities.toString());
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

    // try {
    //   final response = await post(
    //     Uri.parse(
    //       "https://yt5s.biz/mates/en/analyze/ajax?retry=undefined&platform=youtube",
    //     ),
    //     body: {
    //       'url': 'https://www.youtube.com/watch?v=$videoId',
    //       'ajax': '1',
    //       'lang': 'en',
    //     },
    //   );
    //   final html = cleanHtmlString(jsonDecode(response.body)['result']);
    //   final parsed = parse('''
    //                     <html>
    //                       <body>
    //                         $html
    //                       </body>
    //                     </html>
    //                 ''');

    //   var rows = parsed.getElementsByTagName('tr').where((element) {
    //     return element.getElementsByTagName('td').length >= 3 &&
    //         element.getElementsByTagName('td').first.text.trim() != 'MP3';
    //   });
    //   for (var row in rows) {
    //     var cells = row.getElementsByTagName('td');
    //     if (cells.isNotEmpty) {
    //       var quality = cells[0].text.trim();
    //       var format = cells[2].text.trim();
    //       var size = cells[1].text.trim();
    //       var linkElement = cells[2].querySelector('a');
    //       var buttonElement = cells[2].querySelector('button');
    //       var downloadUrl = linkElement?.attributes['href'] ??
    //           buttonElement?.attributes['onclick'];
    //       log("Download URL: $downloadUrl");
    //       if (downloadUrl != null) {
    //         if (downloadUrl.contains("download(")) {
    //           downloadUrl = await getDownloadUrl(
    //             ext: downloadUrl.split(",")[3],
    //             format: downloadUrl.split(",").last,
    //             id: videoId,
    //             note: downloadUrl.split(",")[5],
    //             title: downloadUrl.split(",")[1],
    //             url: "https://www.youtube.com/watch?v=$videoId",
    //           );
    //           videosList.add(
    //             VideoData(
    //               url: downloadUrl ?? '',
    //               quality: quality
    //                   .replaceAll("(", "")
    //                   .replaceAll(")", "")
    //                   .replaceAll(".mp4", "")
    //                   .trim(),
    //               format: format,
    //               size: size,
    //             ),
    //           );
    //         }
    //       }
    //     }
    //   }
    //   videosList.removeWhere((element) => element.url == '');
    //   sortByQuality();
    // } catch (e) {
    //   log("Error: $e");
    //   throw Exception(e);
    // }
  }

  Future<String?> getDownloadUrl({
    // required String note,
    required String url,
    // required String ext,
    // required String format,
    // required String id,
    // required String title,
  }) async {
    try {
      log("Url $url");
      final response = await get(Uri.parse(url));
      // final data = {
      //   'url': url,
      //   'ext': ext.replaceAll("'", ""),
      //   'format': format.replaceAll(")", "").replaceAll("'", ""),
      //   'id': id,
      //   'title': title.replaceAll("'", ""),
      //   'note': note.split("(").first.trim().replaceAll("'", ""),
      //   'platform': "youtube",
      // };
      // final response = await post(
      //   Uri.parse(
      //     "https://sss.instasaverpro.com/mates/en/convert?id=$id",
      //   ),
      //   headers: {
      //     'Content-Type': 'application/x-www-form-urlencoded',
      //   },
      //   body: data,
      // );
      // log(response.body);
      final parsed = jsonDecode(response.body);
      log(parsed['data']['downloadUrl']);
      return parsed['data']['downloadUrl'];
    } catch (e) {
      log("Error in getting downloadurl $e");
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

class VideoData {
  final String url;
  final String quality;
  final String format;
  final String size;

  VideoData({
    required this.url,
    required this.quality,
    required this.format,
    required this.size,
  });

  Map<String, dynamic> toMap() {
    return {
      'url': url,
      'quality': quality,
      'format': format,
      'size': size,
    };
  }

  factory VideoData.fromMap(Map<String, dynamic> map) {
    return VideoData(
      url: map['url'],
      quality: map['quality'],
      format: map['format'],
      size: map['size'],
    );
  }
}
