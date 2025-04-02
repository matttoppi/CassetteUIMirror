// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserBio _$UserBioFromJson(Map<String, dynamic> json) => UserBio(
      userId: json['userId'] as String,
      username: json['username'] as String,
      bio: json['bio'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      isOwnProfile: json['isOwnProfile'] as bool,
      connectedServices: (json['connectedServices'] as List<dynamic>)
          .map((e) => ConnectedService.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$UserBioToJson(UserBio instance) => <String, dynamic>{
      'userId': instance.userId,
      'username': instance.username,
      'bio': instance.bio,
      'avatarUrl': instance.avatarUrl,
      'isOwnProfile': instance.isOwnProfile,
      'connectedServices': instance.connectedServices,
    };

ConnectedService _$ConnectedServiceFromJson(Map<String, dynamic> json) =>
    ConnectedService(
      serviceType: json['serviceType'] as String,
      connectedAt: DateTime.parse(json['connectedAt'] as String),
    );

Map<String, dynamic> _$ConnectedServiceToJson(ConnectedService instance) =>
    <String, dynamic>{
      'serviceType': instance.serviceType,
      'connectedAt': instance.connectedAt.toIso8601String(),
    };

ActivityPost _$ActivityPostFromJson(Map<String, dynamic> json) => ActivityPost(
      postId: json['postId'] as String,
      elementType: json['elementType'] as String,
      elementId: json['elementId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      username: json['username'] as String,
      userAvatarUrl: json['userAvatarUrl'] as String?,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String?,
      imageUrl: json['imageUrl'] as String?,
      description: json['description'] as String,
    );

Map<String, dynamic> _$ActivityPostToJson(ActivityPost instance) =>
    <String, dynamic>{
      'postId': instance.postId,
      'elementType': instance.elementType,
      'elementId': instance.elementId,
      'createdAt': instance.createdAt.toIso8601String(),
      'username': instance.username,
      'userAvatarUrl': instance.userAvatarUrl,
      'title': instance.title,
      'subtitle': instance.subtitle,
      'imageUrl': instance.imageUrl,
      'description': instance.description,
    };

PaginatedResponse<T> _$PaginatedResponseFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) =>
    PaginatedResponse<T>(
      items: (json['items'] as List<dynamic>).map(fromJsonT).toList(),
      totalItems: (json['totalItems'] as num).toInt(),
      page: (json['page'] as num).toInt(),
      pageSize: (json['pageSize'] as num).toInt(),
    );

Map<String, dynamic> _$PaginatedResponseToJson<T>(
  PaginatedResponse<T> instance,
  Object? Function(T value) toJsonT,
) =>
    <String, dynamic>{
      'items': instance.items.map(toJsonT).toList(),
      'totalItems': instance.totalItems,
      'page': instance.page,
      'pageSize': instance.pageSize,
    };

ProfileItem _$ProfileItemFromJson(Map<String, dynamic> json) => ProfileItem(
      type: json['type'] as String,
      title: json['title'] as String,
      songCount: (json['songCount'] as num?)?.toInt(),
      duration: json['duration'] as String?,
      artist: json['artist'] as String?,
      album: json['album'] as String?,
      description: json['description'] as String?,
      username: json['username'] as String?,
      imageUrl: json['imageUrl'] as String?,
      shareLink: json['shareLink'] as String?,
    );

Map<String, dynamic> _$ProfileItemToJson(ProfileItem instance) =>
    <String, dynamic>{
      'type': instance.type,
      'title': instance.title,
      'songCount': instance.songCount,
      'duration': instance.duration,
      'artist': instance.artist,
      'album': instance.album,
      'description': instance.description,
      'username': instance.username,
      'imageUrl': instance.imageUrl,
      'shareLink': instance.shareLink,
    };
