class CollectionItem {
  final String title;
  final String artist;
  final String? duration;
  final String coverArtUrl;
  final int? trackNumber;
  final String? previewUrl;

  CollectionItem({
    required this.title,
    required this.artist,
    this.duration,
    required this.coverArtUrl,
    this.trackNumber,
    this.previewUrl,
  });

  factory CollectionItem.fromJson(Map<String, dynamic> json) {
    return CollectionItem(
      title: json['title'] as String? ?? 'Unknown Title',
      artist: json['artist'] as String? ?? 'Unknown Artist',
      duration: json['duration'] as String?,
      coverArtUrl: json['coverArtUrl'] as String? ?? '',
      trackNumber: json['trackNumber'] as int?,
      previewUrl: json['previewUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['artist'] = this.artist;
    data['duration'] = this.duration;
    data['coverArtUrl'] = this.coverArtUrl;
    data['trackNumber'] = this.trackNumber;
    data['previewUrl'] = this.previewUrl;
    return data;
  }
}
