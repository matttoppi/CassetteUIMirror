class CollectionItem {
  final String title;
  final String artist;
  final String duration;
  final String coverArtUrl;

  CollectionItem({
    required this.title,
    required this.artist,
    required this.duration,
    required this.coverArtUrl,
  });

  factory CollectionItem.fromJson(Map<String, dynamic> json) {
    return CollectionItem(
      title: json['title'] as String,
      artist: json['artist'] as String,
      duration: json['duration'] as String,
      coverArtUrl: json['coverArtUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['artist'] = this.artist;
    data['duration'] = this.duration;
    data['coverArtUrl'] = this.coverArtUrl;
    return data;
  }
}
