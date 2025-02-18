/// Constants for different types of music elements
class ElementType {
  /// Represents a single track/song
  static const int track = 0;
  static const String trackStr = 'Track';

  /// Represents an album
  static const int album = 1;
  static const String albumStr = 'Album';

  /// Represents an artist
  static const int artist = 2;
  static const String artistStr = 'Artist';

  /// Represents a playlist
  static const int playlist = 3;
  static const String playlistStr = 'Playlist';

  /// Convert API response value to element type int
  static int fromResponse(dynamic value) {
    // If it's already an int, return it
    if (value is int) return value;

    // If it's a string, convert it
    if (value is String) {
      switch (value) {
        case trackStr:
          return track;
        case albumStr:
          return album;
        case artistStr:
          return artist;
        case playlistStr:
          return playlist;
        default:
          throw Exception('Unknown element type string: $value');
      }
    }

    throw Exception('Unsupported element type value: $value');
  }
}
