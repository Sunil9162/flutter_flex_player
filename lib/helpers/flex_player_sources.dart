import 'dart:io';

abstract class FlexPlayerSource {}

class AssetFlexPlayerSource extends FlexPlayerSource {
  /// The asset to play.
  final String asset;
  AssetFlexPlayerSource(this.asset);
}

class NetworkFlexPlayerSource extends FlexPlayerSource {
  /// The URL to play.
  final String url;
  NetworkFlexPlayerSource(this.url);
}

class FileFlexPlayerSource extends FlexPlayerSource {
  /// The file to play.
  final File file;
  FileFlexPlayerSource(this.file);
}

class YouTubeFlexPlayerSource extends FlexPlayerSource {
  /// The YouTube video ID to play.
  final String videoId;
  YouTubeFlexPlayerSource(this.videoId);
}
