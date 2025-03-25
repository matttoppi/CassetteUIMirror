import 'package:json_annotation/json_annotation.dart';

part 'user_profile_models.g.dart';

@JsonSerializable()
class UserBio {
  final String userId;
  final String username;
  final String? fullName;
  final String bio;
  final String? avatarUrl;
  final String? profilePath;
  final String? link;
  final ConversionStats conversionStats;
  final List<ConnectedService> connectedServices;

  UserBio({
    required this.userId,
    required this.username,
    this.fullName,
    required this.bio,
    this.avatarUrl,
    this.profilePath,
    this.link,
    required this.conversionStats,
    required this.connectedServices,
  });

  factory UserBio.fromJson(Map<String, dynamic> json) =>
      _$UserBioFromJson(json);
  Map<String, dynamic> toJson() => _$UserBioToJson(this);
}

@JsonSerializable()
class ConversionStats {
  final int tracksConverted;
  final int albumsConverted;
  final int artistsConverted;
  final int playlistsConverted;

  ConversionStats({
    required this.tracksConverted,
    required this.albumsConverted,
    required this.artistsConverted,
    required this.playlistsConverted,
  });

  factory ConversionStats.fromJson(Map<String, dynamic> json) =>
      _$ConversionStatsFromJson(json);
  Map<String, dynamic> toJson() => _$ConversionStatsToJson(this);
}

@JsonSerializable()
class ConnectedService {
  final String serviceType;
  final DateTime connectedAt;

  ConnectedService({
    required this.serviceType,
    required this.connectedAt,
  });

  factory ConnectedService.fromJson(Map<String, dynamic> json) =>
      _$ConnectedServiceFromJson(json);
  Map<String, dynamic> toJson() => _$ConnectedServiceToJson(this);
}

@JsonSerializable()
class ActivityPost {
  final String postId;
  final String elementType; // 'Track' | 'Album' | 'Artist' | 'Playlist'
  final String elementId;
  final DateTime createdAt;
  final String username;
  final String? userAvatarUrl;
  final String title;
  final String? subtitle;
  final String? imageUrl;
  final String description;

  ActivityPost({
    required this.postId,
    required this.elementType,
    required this.elementId,
    required this.createdAt,
    required this.username,
    this.userAvatarUrl,
    required this.title,
    this.subtitle,
    this.imageUrl,
    required this.description,
  });

  factory ActivityPost.fromJson(Map<String, dynamic> json) =>
      _$ActivityPostFromJson(json);
  Map<String, dynamic> toJson() => _$ActivityPostToJson(this);
}

@JsonSerializable(genericArgumentFactories: true)
class PaginatedResponse<T> {
  final List<T> items;
  final int totalItems;
  final int page;
  final int pageSize;

  PaginatedResponse({
    required this.items,
    required this.totalItems,
    required this.page,
    required this.pageSize,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$PaginatedResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$PaginatedResponseToJson(this, toJsonT);
}

@JsonSerializable()
class ProfileItem {
  final String type;
  final String title;
  final int? songCount;
  final String? duration;
  final String? artist;
  final String? album;
  final String? description;
  final String? username;
  final String? imageUrl;
  final String? shareLink;

  ProfileItem({
    required this.type,
    required this.title,
    this.songCount,
    this.duration,
    this.artist,
    this.album,
    this.description,
    this.username,
    this.imageUrl,
    this.shareLink,
  });

  factory ProfileItem.fromJson(Map<String, dynamic> json) =>
      _$ProfileItemFromJson(json);
  Map<String, dynamic> toJson() => _$ProfileItemToJson(this);
}
