class PlaylistItemModel {
  String? title;
  String? artist;
  String? duration;

  PlaylistItemModel({this.title, this.artist, this.duration});

  PlaylistItemModel.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    artist = json['artist'];
    duration = json['duration'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['artist'] = this.artist;
    data['duration'] = this.duration;
    return data;
  }
}
