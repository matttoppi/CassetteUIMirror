class ProfileItemsJson {
  String? type;
  String? title;
  num? songCount;
  String? duration;
  String? artist;
  String? album;
  String? description;
  String? username;
  String? source;
  String? shareLink;

  ProfileItemsJson(
      {this.type,
      this.title,
      this.songCount,
      this.duration,
      this.artist,
      this.album,
      this.description,
      this.shareLink,
      this.username,
      this.source});

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

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['title'] = this.title;
    data['song_count'] = this.songCount;
    data['duration'] = this.duration;
    data['artist'] = this.artist;
    data['album'] = this.album;
    data['description'] = this.description;
    data['username'] = this.username;
    data['source'] = this.source;
    data['share_link'] = this.shareLink;
    return data;
  }
}
