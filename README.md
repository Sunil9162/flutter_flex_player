# Flutter Flex Player
[![Visits Badge](https://badges.pufler.dev/visits/Sunil9162/flutter_flex_player)]([https://badges.pufler.dev](https://badges.pufler.dev/visits/Sunil9162/flutter_flex_player))
[![Updated Badge](https://badges.pufler.dev/updated/Sunil9162/flutter_flex_player)](https://badges.pufler.dev)

**Flutter Flex Player** is a Flutter package for playing videos. It provides a flexible video player widget that supports various video sources including assets, network, file, and YouTube. Built with Dart and Flutter, this package allows you to integrate video playback easily into your Flutter applications.

## Features

- Play videos from assets, network URLs, files, and YouTube.
- Customizable aspect ratio for video playback.
- Fullscreen mode support.
- Various player controls including play, pause, seek, volume, and playback speed.
- Stream events for initialization, position changes, duration updates, and player state.

## Installation

Add `flutter_flex_player` to your `pubspec.yaml` file:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_flex_player: ^1.0.0 # Replace with the latest version
```

Run `flutter pub get` to install the package.

## Usage

### Import the Package

```dart
import 'package:flutter_flex_player/flutter_flex_player.dart';
import 'package:flutter_flex_player/flutter_flex_player_controller.dart';
import 'package:flutter_flex_player/helpers/flex_player_sources.dart';
```

### Create a Video Player Controller

```dart
FlutterFlexPlayerController _controller = FlutterFlexPlayerController();
```

### Initialize the Video Player

In your widget's `initState`, load the video source:

```dart
@override
void initState() {
  super.initState();
  _controller.load(
    NetworkFlexPlayerSource(
      "https://example.com/video.mp4",
    ),
    autoPlay: false,
    loop: true,
  );
}
```

### Build the Video Player Widget

Use the `FlutterFlexPlayer` widget to display the player:

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('VideoPlayerScreen'),
    ),
    body: Column(
      children: [
        FlutterFlexPlayer(
          _controller,
        ),
        const SizedBox(
          height: 50,
        ),
      ],
    ),
  );
}
```

## Classes and Methods

### `FlutterFlexPlayerController`

- `load(FlexPlayerSource source, {bool autoPlay = false, bool loop = false})`: Loads a video source.
- `play()`: Plays the video.
- `pause()`: Pauses the video.
- `stop()`: Stops the video.
- `seekTo(Duration position)`: Seeks to a specific position in the video.
- `setVolume(double volume)`: Sets the volume of the video player.
- `setPlaybackSpeed(double speed)`: Sets the playback speed.
- `setLooping(bool looping)`: Enables or disables looping.
- `setMute(bool mute)`: Mutes or unmutes the video player.
- `dispose()`: Disposes of the controller.
- `enterFullScreen(BuildContext context)`: Enters fullscreen mode.
- `exitFullScreen(BuildContext context)`: Exits fullscreen mode.
- `reload()`: Reloads the current video.
- `setQuality(String quality)`: Sets the video quality.

### `FlexPlayerSource`

- `AssetFlexPlayerSource(String asset)`: Source for video assets.
- `NetworkFlexPlayerSource(String url)`: Source for network URLs.
- `FileFlexPlayerSource(File file)`: Source for local files.
- `YouTubeFlexPlayerSource(String videoId, {bool isLive = false, bool useIframe = false})`: Source for YouTube videos.

### Enums

- `InitializationEvent`: Represents the initialization state of the player.
  - `initializing`
  - `initialized`
  - `uninitialized`

- `PlayerState`: Represents the state of the player.
  - `playing`
  - `paused`
  - `stopped`
  - `buffering`
  - `ended`

## Example

Check out the `example` directory for a complete example of how to use `flutter_flex_player` in a Flutter application.
 

## Contributing

Feel free to contribute to this package by submitting issues or pull requests. 

## Contact

For any questions or feedback, please reach out to [me@sunilflutter.in](mailto:me@sunilflutter.in).