class PlayBackDurationStream {
  final Duration duration;
  final Duration position;
  final Duration buffered;

  PlayBackDurationStream({
    required this.duration,
    required this.position,
    required this.buffered,
  });
}
