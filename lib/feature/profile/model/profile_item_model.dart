/// Represents an item in a user's profile such as a playlist, song, artist, or album
class ProfileItemsJson {
  String? type; // Type of item (Song, Playlist, Artist, Album)
  String? title; // Title of the item
  num? songCount; // Number of songs (for playlists and albums)
  String? duration; // Duration of the item
  String? artist; // Artist name (for songs)
  String? album; // Album name (for songs)
  String? description; // Description of the item
  String? username; // Username of the creator
  String? source; // Image source URL
  String? shareLink; // Link to share this item

  /// Creates a ProfileItemsJson instance with optional parameters
  ProfileItemsJson({
    this.type,
    this.title,
    this.songCount,
    this.duration,
    this.artist,
    this.album,
    this.description,
    this.shareLink,
    this.username,
    this.source,
  });

  /// Creates a ProfileItemsJson from a JSON map
  ProfileItemsJson.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    title = json['title'];
    songCount = json['song_count'];
    duration = json['duration'];
    artist = json['artist'];
    album = json['album'];
    description = json['description'];
    username = json['username'];
    source = json['source'];
    shareLink = json['share_link'];
  }

  /// Converts this ProfileItemsJson to a JSON map
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['type'] = type;
    data['title'] = title;
    data['song_count'] = songCount;
    data['duration'] = duration;
    data['artist'] = artist;
    data['album'] = album;
    data['description'] = description;
    data['username'] = username;
    data['source'] = source;
    data['share_link'] = shareLink;
    return data;
  }
}
