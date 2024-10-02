abstract class PlayerException implements Exception {
  final String message;
  PlayerException(this.message);
}

class NoLiveStreamFound extends PlayerException {
  NoLiveStreamFound(super.message);
}

class NoVideoFound extends PlayerException {
  NoVideoFound(super.message);
}

class PlayerError extends PlayerException {
  PlayerError(super.message);
}
