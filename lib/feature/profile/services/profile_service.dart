import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cassettefrontend/core/services/api_service.dart';
import 'package:cassettefrontend/feature/profile/model/user_profile_models.dart';

class ProfileService {
  final ApiService _apiService;
  // Cache for user bios and activities
  final Map<String, ({UserBio bio, DateTime timestamp})> _bioCache = {};
  final Map<String,
          ({PaginatedResponse<ActivityPost> activity, DateTime timestamp})>
      _activityCache = {};
  // Cache expiration time (5 minutes)
  static const cacheDuration = Duration(minutes: 5);

  ProfileService(this._apiService);

  // Fetch both bio and activity in parallel
  Future<({UserBio bio, PaginatedResponse<ActivityPost> activity})>
      fetchUserProfile(String userIdentifier) async {
    try {
      final now = DateTime.now();
      final bioFuture = _getCachedOrFetchBio(userIdentifier, now);
      final activityFuture = _getCachedOrFetchActivity(userIdentifier, now);

      final results = await Future.wait<dynamic>([bioFuture, activityFuture]);
      return (
        bio: results[0] as UserBio,
        activity: results[1] as PaginatedResponse<ActivityPost>
      );
    } catch (e) {
      print('❌ Error fetching profile: $e');
      rethrow;
    }
  }

  Future<UserBio> _getCachedOrFetchBio(
      String userIdentifier, DateTime now) async {
    final cached = _bioCache[userIdentifier];
    if (cached != null && now.difference(cached.timestamp) < cacheDuration) {
      print('📝 Using cached bio for user: $userIdentifier');
      return cached.bio;
    }
    final bio = await fetchUserBio(userIdentifier);
    _bioCache[userIdentifier] = (bio: bio, timestamp: now);
    return bio;
  }

  Future<PaginatedResponse<ActivityPost>> _getCachedOrFetchActivity(
    String userIdentifier,
    DateTime now, {
    int page = 1,
    int pageSize = 20,
    String? elementType,
  }) async {
    final cacheKey = '$userIdentifier:$page:$pageSize:$elementType';
    final cached = _activityCache[cacheKey];
    if (cached != null && now.difference(cached.timestamp) < cacheDuration) {
      print('📝 Using cached activity for user: $userIdentifier');
      return cached.activity;
    }
    final activity = await fetchUserActivity(
      userIdentifier,
      page: page,
      pageSize: pageSize,
      elementType: elementType,
    );
    _activityCache[cacheKey] = (activity: activity, timestamp: now);
    return activity;
  }

  Future<UserBio> fetchUserBio(String userIdentifier) async {
    try {
      // Handle edit path
      final path = userIdentifier == 'edit'
          ? '/profile/edit/bio'
          : '/profile/$userIdentifier/bio';

      print('🔍 Fetching bio from: $path');
      final response = await _apiService.get(path);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UserBio.fromJson(data);
      } else if (response.statusCode == 404) {
        print('❌ User not found: $userIdentifier');
        throw Exception('User not found');
      } else {
        print('❌ Error fetching bio: ${response.statusCode}');
        throw Exception('Failed to load profile');
      }
    } catch (e) {
      print('❌ Bio fetch error: $e');
      rethrow;
    }
  }

  Future<PaginatedResponse<ActivityPost>> fetchUserActivity(
    String userIdentifier, {
    required int page,
    int pageSize = 20,
    String? elementType,
  }) async {
    try {
      // Handle edit path
      final path = userIdentifier == 'edit'
          ? '/profile/edit/activity'
          : '/profile/$userIdentifier/activity';

      final queryParams = {
        'page': page.toString(),
        'pageSize': pageSize.toString(),
        if (elementType != null) 'elementType': elementType,
      };

      print('🔍 Fetching activity from: $path');
      final response = await _apiService.get(
        path,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return PaginatedResponse<ActivityPost>.fromJson(
          json,
          (obj) => ActivityPost.fromJson(obj as Map<String, dynamic>),
        );
      } else if (response.statusCode == 404) {
        print('❌ User not found: $userIdentifier');
        throw Exception('User not found');
      } else {
        print('❌ Error fetching activity: ${response.statusCode}');
        throw Exception('Failed to load activity');
      }
    } catch (e) {
      print('❌ Activity fetch error: $e');
      rethrow;
    }
  }

  // Convenience methods for specific element types
  Future<PaginatedResponse<ActivityPost>> fetchUserTracks(
    String userIdentifier, {
    required int page,
    int pageSize = 20,
  }) async {
    return fetchUserActivity(
      userIdentifier,
      page: page,
      pageSize: pageSize,
      elementType: 'Track',
    );
  }

  Future<PaginatedResponse<ActivityPost>> fetchUserAlbums(
    String userIdentifier, {
    required int page,
    int pageSize = 20,
  }) async {
    return fetchUserActivity(
      userIdentifier,
      page: page,
      pageSize: pageSize,
      elementType: 'Album',
    );
  }

  Future<PaginatedResponse<ActivityPost>> fetchUserArtists(
    String userIdentifier, {
    required int page,
    int pageSize = 20,
  }) async {
    return fetchUserActivity(
      userIdentifier,
      page: page,
      pageSize: pageSize,
      elementType: 'Artist',
    );
  }

  Future<PaginatedResponse<ActivityPost>> fetchUserPlaylists(
    String userIdentifier, {
    required int page,
    int pageSize = 20,
  }) async {
    return fetchUserActivity(
      userIdentifier,
      page: page,
      pageSize: pageSize,
      elementType: 'Playlist',
    );
  }
}
