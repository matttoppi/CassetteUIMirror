import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' show min;
import '../env.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class ApiService {
  String? _spotifyAccessToken;
  DateTime? _tokenExpiryTime;
  String? _appleMusicToken;
  DateTime? _appleMusicTokenExpiryTime;

  // API URLs for different environments
  static const String _prodBaseUrl =
      'https://nm2uheummh.us-east-1.awsapprunner.com';
  static const String _localBaseUrl = 'http://localhost:5173';

  // Get the base URL from environment configuration
  static String get baseUrl {
    // Read the API_ENV from dart-define, default to 'prod' if not set
    final apiEnv =
        const String.fromEnvironment('API_ENV', defaultValue: 'prod');
    print('Current API Environment: $apiEnv'); // Helpful for debugging
    final baseDomain = apiEnv == 'local' ? _localBaseUrl : _prodBaseUrl;
    return '$baseDomain/api/v1';
  }

  // Base domain without path for connection testing
  static String get baseDomain {
    final apiEnv =
        const String.fromEnvironment('API_ENV', defaultValue: 'prod');
    return apiEnv == 'local' ? _localBaseUrl : _prodBaseUrl;
  }

  // Test function to verify API connection using root endpoint
  Future<bool> testConnection() async {
    try {
      // Test with root endpoint GET request
      final response = await http.get(
        Uri.parse(baseDomain), // Root URL without /api/v1
      );
      print('API test connection status: ${response.statusCode}');
      print('API info: ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      print('API test connection error: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> convertMusicLink(String sourceLink) async {
    print('Converting link: $sourceLink');

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/convert'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'sourceLink': sourceLink}),
      );

      print('Request URL: ${Uri.parse('$baseUrl/convert')}');
      print('Request headers: ${response.request?.headers}');
      print('Request body: ${json.encode({'sourceLink': sourceLink})}');
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Raw response data keys: ${data.keys.toList()}');
        print('Raw response data: $data');

        if (data['success'] == true) {
          print('API confirmed success=true');

          // Check for required fields
          final requiredFields = [
            'elementType',
            'musicElementId',
            'postId',
            'details'
          ];
          final missingFields = requiredFields
              .where((field) => !data.containsKey(field) || data[field] == null)
              .toList();

          if (missingFields.isNotEmpty) {
            print(
                'WARNING: Missing required fields in API response: $missingFields');
            throw Exception(
                'API response missing required fields: ${missingFields.join(", ")}');
          }

          // Validate details structure
          final details = data['details'] as Map<String, dynamic>?;
          if (details == null) {
            print('ERROR: details field is null or not a map');
            throw Exception('API response has invalid details structure');
          }

          // Validate element type is one of the supported types
          final elementType = data['elementType']?.toString().toLowerCase();
          if (elementType != 'track' &&
              elementType != 'artist' &&
              elementType != 'album' &&
              elementType != 'playlist') {
            print('ERROR: Unsupported element type: $elementType');
            throw Exception('Unsupported element type: $elementType');
          }

          // Ensure required fields in details based on element type
          final detailsRequiredFields = ['title'];
          if (elementType != 'artist') {
            detailsRequiredFields.add('artist');
          }

          final coverArtField =
              elementType == 'artist' ? 'imageUrl' : 'coverArtUrl';
          detailsRequiredFields.add(coverArtField);

          final missingDetailsFields = detailsRequiredFields
              .where((field) =>
                  !details.containsKey(field) || details[field] == null)
              .toList();

          if (missingDetailsFields.isNotEmpty) {
            print(
                'WARNING: Missing required fields in details: $missingDetailsFields');
            // Try to fix missing fields with defaults or from platforms data if possible
            // ...
          }

          // Validate and transform the response
          final responseData = {
            'elementType': data['elementType'],
            'musicElementId': data['musicElementId'],
            'postId': data['postId'],
            'details': {
              'title': data['elementType']?.toLowerCase() == 'artist'
                  ? details['name']?.toString() ??
                      details['title']?.toString() ??
                      'Unknown Artist'
                  : details['title']?.toString() ?? 'Unknown Title',
              'artist': data['elementType']?.toLowerCase() == 'artist'
                  ? '' // Artists don't have an artist field
                  : details['artist']?.toString() ?? 'Unknown Artist',
              'coverArtUrl': data['elementType']?.toLowerCase() == 'artist'
                  ? details['imageUrl']?.toString() ?? ''
                  : details['coverArtUrl']?.toString() ?? '',
              // Add additional artist-specific fields
              if (data['elementType']?.toLowerCase() ==
                  'artist') ...<String, dynamic>{
                'followers': details['followers'],
                'genres': details['genres'],
                'popularity': details['popularity'],
              },
              // Optional fields for collections
              if (details['tracks'] != null) 'tracks': details['tracks'],
            },
            'platforms': data['platforms'],
            'userId': data['userId'],
            'username': data['username'],
            'caption': data['caption'],
          };

          print('Transformed response keys: ${responseData.keys.toList()}');
          print('Transformed response: $responseData');

          // Final validation before returning
          final transformedMissingFields = requiredFields
              .where((field) =>
                  !responseData.containsKey(field) ||
                  responseData[field] == null)
              .toList();

          if (transformedMissingFields.isNotEmpty) {
            print(
                'ERROR: Transformed response missing fields: $transformedMissingFields');
            throw Exception(
                'Failed to create valid response data: missing ${transformedMissingFields.join(", ")}');
          }

          return responseData;
        } else {
          final error = data['errorMessage'] ?? 'Failed to convert link';
          print('API error: $error');
          throw Exception(error);
        }
      } else {
        final error = 'Failed to convert link: ${response.statusCode}';
        print(error);
        throw Exception(error);
      }
    } catch (e) {
      print('API request error: $e');
      throw Exception('Failed to connect to API: $e');
    }
  }

  Future<Map<String, dynamic>> fetchTrackData(String trackId) async {
    final response = await http.get(Uri.parse('$baseUrl/tracks/$trackId'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print('Failed to load track data: ${response.statusCode}');
      throw Exception('Failed to load track data: ${response.statusCode}');
    }
  }

  // Get Spotify access token using Client Credentials flow
  Future<String> _getSpotifyAccessToken() async {
    // Check if we have a valid token
    if (_spotifyAccessToken != null && _tokenExpiryTime != null) {
      if (_tokenExpiryTime!.isAfter(DateTime.now())) {
        return _spotifyAccessToken!;
      }
    }

    try {
      final credentials = base64Encode(
        utf8.encode('${Env.spotifyClientId}:${Env.spotifyClientSecret}'),
      );

      print('Using Client ID: ${Env.spotifyClientId}'); // Debug log

      final response = await http.post(
        Uri.parse('https://accounts.spotify.com/api/token'),
        headers: {
          'Authorization': 'Basic $credentials',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'grant_type': 'client_credentials',
        },
      );

      print('Token response status: ${response.statusCode}'); // Debug log
      print('Token response body: ${response.body}'); // Debug log

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _spotifyAccessToken = data['access_token'];
        _tokenExpiryTime = DateTime.now().add(const Duration(minutes: 50));
        return _spotifyAccessToken!;
      } else {
        throw Exception('Failed to get Spotify access token: ${response.body}');
      }
    } catch (e) {
      print('Error getting Spotify token: $e'); // Debug log
      rethrow;
    }
  }

  // Helper method to get default headers for API requests
  Map<String, String> getDefaultHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  // Search using Spotify API directly
  Future<Map<String, dynamic>> searchMusic(String query) async {
    print('===== searchMusic =====');
    print('Searching Spotify for: $query');

    try {
      final token = await _getSpotifyAccessToken();
      print(
          'Making request to Spotify API with token: ${token.substring(0, 10)}...');

      final url = Uri.parse('https://api.spotify.com/v1/search').replace(
        queryParameters: {
          'q': query,
          'type': 'track,artist,album', // Removed playlist type
          'limit': '10',
        },
      );
      print('Request URL: $url');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Spotify search response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('Response body length: ${response.body.length}');
        final data = json.decode(response.body);

        print('Raw response structure: ${data.runtimeType}');
        print('Raw response keys: ${data.keys.toList()}');

        // Transform Spotify response to our format
        final List<Map<String, dynamic>> results = [];

        // Add tracks
        if (data['tracks'] != null) {
          print('Found ${data['tracks']['items'].length} tracks');
          for (var item in data['tracks']['items']) {
            results.add({
              'type': 'track',
              'id': item['id'],
              'title': item['name'],
              'artist': item['artists'][0]['name'],
              'album': item['album']['name'], // Added album name
              'coverArtUrl': item['album']['images'].isNotEmpty
                  ? item['album']['images'][0]['url']
                  : null,
              'previewUrl':
                  item['preview_url'], // Added preview URL if available
            });
          }
        }

        // Add artists
        if (data['artists'] != null) {
          print('Found ${data['artists']['items'].length} artists');
          for (var item in data['artists']['items']) {
            results.add({
              'type': 'artist',
              'id': item['id'],
              'title': item['name'],
              'artist': '', // Artists don't have an artist field
              'coverArtUrl':
                  item['images'].isNotEmpty ? item['images'][0]['url'] : null,
              'genres': item['genres'] ?? [], // Added genres
              'popularity': item['popularity'], // Added popularity
            });
          }
        }

        // Add albums
        if (data['albums'] != null) {
          print('Found ${data['albums']['items'].length} albums');
          for (var item in data['albums']['items']) {
            results.add({
              'type': 'album',
              'id': item['id'],
              'title': item['name'],
              'artist': item['artists'][0]['name'],
              'releaseDate': item['release_date'], // Added release date
              'totalTracks': item['total_tracks'], // Added total tracks
              'coverArtUrl':
                  item['images'].isNotEmpty ? item['images'][0]['url'] : null,
            });
          }
        }

        final transformedResponse = {
          'success': true,
          'results': results,
        };

        print('Transformed ${results.length} results');
        return transformedResponse;
      } else {
        print('ERROR: Spotify returned status code ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to search Spotify: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('ERROR in searchMusic: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to search Spotify: $e');
    }
  }

  // Generate Apple Music developer token
  Future<String> _getAppleMusicToken() async {
    // Check if we have a valid token that's not expired
    // We'll refresh the token when it's within 24 hours of expiry
    if (_appleMusicToken != null && _appleMusicTokenExpiryTime != null) {
      final now = DateTime.now();
      if (_appleMusicTokenExpiryTime!
          .isAfter(now.add(const Duration(hours: 24)))) {
        return _appleMusicToken!;
      }
    }

    try {
      // Verify environment variables
      final teamId = Env.appleMusicTeamId;
      final keyId = Env.appleMusicKeyId;

      print('Apple Music Environment Variables:');
      print('Team ID: ${teamId.isEmpty ? 'EMPTY' : teamId}');
      print('Key ID: ${keyId.isEmpty ? 'EMPTY' : keyId}');

      if (teamId.isEmpty || keyId.isEmpty) {
        throw Exception(
            'Apple Music credentials not properly configured. Please check your environment variables.');
      }

      // Get the raw key content with proper line breaks
      final rawKey = '''-----BEGIN PRIVATE KEY-----
MIGTAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBHkwdwIBAQQggOXvS/JS+Edal6Nm
DMaf28O+Dry7Vzc8JL7eeq9+E36gCgYIKoZIzj0DAQehRANCAAQv23Z+0/dPzL1i
lk0xocL2QK0Ug83lqRQYDEiJIGGGB16oGN9EfM2Ek/Q7MWeNfqB+ZKdoiMSQ+sUN
XLYa3Ssm
-----END PRIVATE KEY-----''';

      print('Using private key:');
      print(rawKey);

      // Prepare the claims for the JWT
      final claims = {
        'iss': teamId,
        'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        'exp': DateTime.now()
                .add(const Duration(days: 180))
                .millisecondsSinceEpoch ~/
            1000,
      };

      // Create the JWT
      final jwt = JWT(
        claims,
        header: {'alg': 'ES256', 'kid': keyId, 'typ': 'JWT'},
      );

      print('JWT Header: ${jwt.header}');
      print('JWT Claims: $claims');

      // Sign the JWT with the private key
      final token = jwt.sign(
        ECPrivateKey(rawKey),
        algorithm: JWTAlgorithm.ES256,
      );

      print('JWT Claims: $claims'); // Debug log to verify claims

      // Store the token and its expiry time
      _appleMusicToken = token;
      _appleMusicTokenExpiryTime =
          DateTime.now().add(const Duration(days: 180));

      print('Generated new Apple Music token');
      return token;
    } catch (e, stackTrace) {
      print('ERROR generating Apple Music token: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Fetch Apple Music Top Charts
  Future<Map<String, dynamic>> fetchTop50USAPlaylist() async {
    print('===== fetchAppleMusicCharts =====');

    try {
      final token = await _getAppleMusicToken();
      print('Generated Apple Music token length: ${token.length}');
      print(
          'Token starts with: ${token.substring(0, min(50, token.length))}...');

      // Construct URL with required parameters
      final url = Uri.parse(
        'https://api.music.apple.com/v1/catalog/us/charts',
      ).replace(
        queryParameters: {
          'types': 'songs', // Required parameter
          'limit': '50',
          'chart': 'most-played',
          'with': 'dailyGlobalTopCharts', // Add this to get global charts
        },
      );
      print('Request URL: $url');
      print('Request headers:');
      print(
          'Authorization: Bearer ${token.substring(0, min(20, token.length))}...');
      print('Music-User-Token: [Not required for catalog endpoints]');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Apple Music charts response status: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Parsed response data: $data');

        if (data['results'] == null || !data['results'].containsKey('songs')) {
          print('Invalid response structure. Data: $data');
          throw Exception('Invalid response structure from Apple Music API');
        }

        final charts = data['results']['songs'] as List;
        if (charts.isEmpty) {
          print('No charts data found in response');
          throw Exception('No charts data found in response');
        }

        final tracks = charts[0]['data'] as List;
        print('Number of tracks received: ${tracks.length}');

        // Transform tracks to match our search results format
        final List<Map<String, dynamic>> results = tracks.map((track) {
          final attributes = track['attributes'];
          print('Full track attributes:');
          print(json.encode(attributes));

          return {
            'type': 'track',
            'id': track['id'],
            'title': attributes['name'],
            'artist': attributes['artistName'],
            'album': attributes['albumName'],
            'url': attributes['url'], // Add the direct URL from Apple Music
            'coverArtUrl': attributes['artwork']['url']
                .toString()
                .replaceAll('{w}x{h}', '500x500'),
            'previewUrl': attributes['previews']?.first?['url'],
            'popularity': track['rank'] ?? 0,
          };
        }).toList();

        print('Successfully transformed ${results.length} tracks');
        return {
          'success': true,
          'results': results,
          'source': 'apple_music' // Add this to identify the source
        };
      } else {
        print('ERROR: Apple Music returned status code ${response.statusCode}');
        print('Response headers: ${response.headers}');
        print('Response body: ${response.body}');
        throw Exception(
            'Failed to fetch charts: ${response.statusCode} - ${response.body}');
      }
    } catch (e, stackTrace) {
      print('ERROR in fetchAppleMusicCharts: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to fetch charts: $e');
    }
  }
}
