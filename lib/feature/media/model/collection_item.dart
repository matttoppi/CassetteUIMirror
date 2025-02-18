class CollectionItem {
  String? type;
  String? title;
  String? artist;
  String? album;
  String? duration;
  int? songCount;
  String? description;
  String? username;

  CollectionItem({
    this.type,
    this.title,
    this.artist,
    this.album,
    this.duration,
    this.songCount,
    this.description,
    this.username,
  });

  CollectionItem.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    title = json['title'];
    artist = json['artist'];
    album = json['album'];
    duration = json['duration'];
    songCount = json['songCount'];
    description = json['description'];
    username = json['username'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['title'] = this.title;
    data['artist'] = this.artist;
    data['album'] = this.album;
    data['duration'] = this.duration;
    data['songCount'] = this.songCount;
    data['description'] = this.description;
    data['username'] = this.username;
    return data;
  }
}
