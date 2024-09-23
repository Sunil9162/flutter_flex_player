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
  YouTubeFlexPlayerSource(
    this.videoId,
  );
}

class PlayerSources {
  static FlexPlayerSource youtube({
    required String videoId,
  }) {
    return YouTubeFlexPlayerSource(
      videoId,
    );
  }

  static FlexPlayerSource network(String url) {
    return NetworkFlexPlayerSource(url);
  }

  static FlexPlayerSource asset(String asset) {
    return AssetFlexPlayerSource(asset);
  }

  static FlexPlayerSource file(File file) {
    return FileFlexPlayerSource(file);
  }
}
