import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' show min;
import '../env.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'dart:async'; // Add for cancellation support

class MusicSearchService {
  String? _spotifyAccessToken;
  DateTime? _tokenExpiryTime;
  String? _appleMusicToken;
  DateTime? _appleMusicTokenExpiryTime;

  // Cache for charts data
  Map<String, dynamic>? _cachedChartsData;
  DateTime? _chartsLastFetched;
  static const Duration _chartsCacheDuration = Duration(minutes: 30);

  // Track ongoing requests to allow cancellation
  Map<String, bool> _activeRequests = {};

  // Add request timeout duration
  static const Duration requestTimeout = Duration(seconds: 15);

  // Add helper function for string similarity
  double _calculateSimilarity(String str1, String str2) {
    // Convert both strings to lowercase for case-insensitive comparison
    str1 = str1.toLowerCase();
    str2 = str2.toLowerCase();

    // Check for substring match first
    if (str1.contains(str2) || str2.contains(str1)) {
      return 1.0;
    }

    // Calculate Levenshtein distance
    var distance = _levenshteinDistance(str1, str2);
    var maxLength = str1.length > str2.length ? str1.length : str2.length;

    // Convert distance to similarity score (0-1)
    return 1 - (distance / maxLength);
  }

  int _levenshteinDistance(String str1, String str2) {
    var m = str1.length;
    var n = str2.length;
    List<List<int>> dp = List.generate(m + 1, (_) => List.filled(n + 1, 0));

    for (var i = 0; i <= m; i++) {
      dp[i][0] = i;
    }
    for (var j = 0; j <= n; j++) {
      dp[0][j] = j;
    }

    for (var i = 1; i <= m; i++) {
      for (var j = 1; j <= n; j++) {
        if (str1[i - 1] == str2[j - 1]) {
          dp[i][j] = dp[i - 1][j - 1];
        } else {
          dp[i][j] = [
            dp[i - 1][j - 1] + 1, // substitution
            dp[i - 1][j] + 1, // deletion
            dp[i][j - 1] + 1 // insertion
          ].reduce(min);
        }
      }
    }
    return dp[m][n];
  }

  // Add helper function to determine if item should be prioritized
  bool _shouldPrioritizeResult(Map<String, dynamic> item, String query) {
    final matchScore = item['matchScore'] as double;
    final queryLower = query.toLowerCase();

    // Check if query contains type hints
    final bool hasTrackHint =
        queryLower.contains('track') || queryLower.contains('song');
    final bool hasAlbumHint = queryLower.contains('album');
    final bool hasArtistHint = queryLower.contains('artist');

    // If type is explicitly mentioned in query, prioritize those results regardless of popularity
    if (hasTrackHint &&
        (item['type'] == 'track' ||
            item['type'] == 'song' ||
            item['type'] == 'tracks' ||
            item['type'] == 'songs')) return true;
    if (hasAlbumHint && (item['type'] == 'album' || item['type'] == 'albums'))
      return true;
    if (hasArtistHint &&
        (item['type'] == 'artist' || item['type'] == 'artists')) return true;

    // Must have good match score as baseline
    if (matchScore < 0.75) return false;

    if (item['source'] == 'spotify') {
      // For Spotify, use popularity score
      final popularity = item['popularity'] ?? 0;
      return popularity >= 60;
    } else {
      // For Apple Music, use ranking and other signals
      final ranking =
          item['ranking'] ?? 999; // Default to high number if not ranked

      if (ranking <= 3) return true; // Top 3 in their category
    }

    return false;
  }

  // Get Spotify access token using Client Credentials flow
  Future<String> _getSpotifyAccessToken() async {
    // Use cached token if valid
    if (_spotifyAccessToken != null && _tokenExpiryTime != null) {
      // Add buffer time to prevent token expiration during requests (5 minutes)
      if (_tokenExpiryTime!
          .isAfter(DateTime.now().add(const Duration(minutes: 5)))) {
        return _spotifyAccessToken!;
      }
    }

    try {
      final requestId =
          'spotify_token_${DateTime.now().millisecondsSinceEpoch}';
      _activeRequests[requestId] = true;

      final credentials = base64Encode(
        utf8.encode('${Env.spotifyClientId}:${Env.spotifyClientSecret}'),
      );

      final response = await http.post(
        Uri.parse('https://accounts.spotify.com/api/token'),
        headers: {
          'Authorization': 'Basic $credentials',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'grant_type': 'client_credentials',
        },
      ).timeout(requestTimeout);

      // Check if this request is still relevant
      if (!_activeRequests.containsKey(requestId) ||
          _activeRequests[requestId] == false) {
        print('⚠️ [Spotify] Token request was cancelled or superseded');
        throw Exception('Request cancelled');
      }
      _activeRequests.remove(requestId);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _spotifyAccessToken = data['access_token'];
        // Use actual expiry time from response with small safety buffer
        final expiresIn = data['expires_in'] as int? ?? 3600;
        _tokenExpiryTime =
            DateTime.now().add(Duration(seconds: expiresIn - 60));
        return _spotifyAccessToken!;
      } else {
        print(
            '❌ [Spotify] Token error: ${response.statusCode}, ${response.body}');
        throw Exception(
            'Failed to get Spotify access token: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ [Spotify] Authentication error: $e');
      rethrow;
    }
  }

  // Generate Apple Music developer token
  Future<String> _getAppleMusicToken() async {
    // Use cached token if valid with buffer time (1 day)
    if (_appleMusicToken != null && _appleMusicTokenExpiryTime != null) {
      final now = DateTime.now();
      if (_appleMusicTokenExpiryTime!
          .isAfter(now.add(const Duration(days: 1)))) {
        return _appleMusicToken!;
      }
    }

    try {
      final teamId = Env.appleMusicTeamId;
      final keyId = Env.appleMusicKeyId;
      String privateKey = Env.appleMusicPrivateKey;

      if (teamId.isEmpty || keyId.isEmpty || privateKey.isEmpty) {
        throw Exception(
            'Apple Music credentials not properly configured. Please check your environment variables.');
      }

      // Clean up the private key - handle both \n and actual newlines
      privateKey = privateKey
          .replaceAll('\\n', '\n') // Replace \n with actual newlines
          .trim(); // Remove any extra whitespace

      // Verify the private key is in PEM format
      if (!privateKey.contains('-----BEGIN PRIVATE KEY-----') ||
          !privateKey.contains('-----END PRIVATE KEY-----')) {
        throw Exception(
            'Invalid private key format. Must be in PEM format with BEGIN and END markers.');
      }

      final claims = {
        'iss': teamId,
        'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        'exp': DateTime.now()
                .add(const Duration(days: 180))
                .millisecondsSinceEpoch ~/
            1000,
      };

      final jwt = JWT(
        claims,
        header: {'alg': 'ES256', 'kid': keyId, 'typ': 'JWT'},
      );

      try {
        final token = jwt.sign(
          ECPrivateKey(privateKey),
          algorithm: JWTAlgorithm.ES256,
        );

        _appleMusicToken = token;
        _appleMusicTokenExpiryTime =
            DateTime.now().add(const Duration(days: 180));

        return token;
      } catch (e) {
        print('❌ [Apple Music] Token signing error: $e');
        throw Exception(
            'Failed to sign Apple Music token. Please check your private key format.');
      }
    } catch (e) {
      print('❌ [Apple Music] Authentication error: $e');
      throw Exception('Failed to generate Apple Music token: $e');
    }
  }

  // Cancel any active search requests
  void cancelActiveRequests() {
    for (var key in _activeRequests.keys) {
      _activeRequests[key] = false;
    }
    print('⚠️ Cancelled all active music service requests');
  }

  // Search using Apple Music API
  Future<Map<String, dynamic>> _searchAppleMusic(String query) async {
    final String requestId =
        'apple_search_${DateTime.now().millisecondsSinceEpoch}';
    _activeRequests[requestId] = true;

    print('🎵 [Apple Music] Searching for: "$query"');

    try {
      final token = await _getAppleMusicToken();

      // Check if this request is still relevant
      if (!_activeRequests.containsKey(requestId) ||
          _activeRequests[requestId] == false) {
        print('⚠️ [Apple Music] Search was cancelled');
        throw Exception('Request cancelled');
      }

      final url = Uri.parse(
        'https://api.music.apple.com/v1/catalog/us/search',
      ).replace(
        queryParameters: {
          'term': query,
          'types': 'songs,artists,albums',
          'limit': '10',
        },
      );

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(requestTimeout);

      // Check again if this request is still relevant
      if (!_activeRequests.containsKey(requestId) ||
          _activeRequests[requestId] == false) {
        print('⚠️ [Apple Music] Search was cancelled after API call');
        throw Exception('Request cancelled');
      }
      _activeRequests.remove(requestId);

      if (response.statusCode != 200) {
        print('❌ [Apple Music] Search failed: ${response.statusCode}');
        print('Response: ${response.body}');
        throw Exception('Failed to search Apple Music: ${response.statusCode}');
      }

      final data = json.decode(response.body);
      final List<Map<String, dynamic>> results = [];

      // Track category rankings
      Map<String, List<String>> categoryIds = {
        'track': [],
        'artist': [],
        'album': [],
      };

      // First pass: collect category rankings
      if (data['results']?['songs']?['data'] != null) {
        categoryIds['track'] = (data['results']['songs']['data'] as List)
            .map((item) => item['id'].toString())
            .toList();
      }
      if (data['results']?['artists']?['data'] != null) {
        categoryIds['artist'] = (data['results']['artists']['data'] as List)
            .map((item) => item['id'].toString())
            .toList();
      }
      if (data['results']?['albums']?['data'] != null) {
        categoryIds['album'] = (data['results']['albums']['data'] as List)
            .map((item) => item['id'].toString())
            .toList();
      }

      // Process all items with rankings
      if (data['results']?['songs']?['data'] != null) {
        final songs = data['results']['songs']['data'];
        print('📝 [Apple Music] Found ${songs.length} songs');
        for (var item in songs) {
          final attributes = item['attributes'];
          final ranking =
              categoryIds['track']!.indexOf(item['id'].toString()) + 1;
          results.add({
            'type': 'track',
            'id': item['id'],
            'title': attributes['name'],
            'artist': attributes['artistName'],
            'album': attributes['albumName'],
            'url': attributes['url'],
            'coverArtUrl': attributes['artwork']['url']
                .toString()
                .replaceAll('{w}x{h}', '500x500'),
            'previewUrl': attributes['previews']?.first?['url'],
            'ranking': ranking,
            'matchScore': _calculateSimilarity(attributes['name'], query),
          });
        }
      }

      if (data['results']?['artists']?['data'] != null) {
        final artists = data['results']['artists']['data'];
        print('👤 [Apple Music] Found ${artists.length} artists');
        for (var item in artists) {
          final attributes = item['attributes'];
          final name = attributes['name'];
          final ranking =
              categoryIds['artist']!.indexOf(item['id'].toString()) + 1;
          results.add({
            'type': 'artist',
            'id': item['id'],
            'title': name,
            'artist': '',
            'coverArtUrl': attributes['artwork']?['url']
                ?.toString()
                .replaceAll('{w}x{h}', '500x500'),
            'genres': attributes['genreNames'] ?? [],
            'ranking': ranking,
            'matchScore': _calculateSimilarity(name, query),
            'url': attributes['url'],
          });
        }
      }

      if (data['results']?['albums']?['data'] != null) {
        final albums = data['results']['albums']['data'];
        print('💿 [Apple Music] Found ${albums.length} albums');
        for (var item in albums) {
          final attributes = item['attributes'];
          final title = attributes['name'];
          final ranking =
              categoryIds['album']!.indexOf(item['id'].toString()) + 1;
          results.add({
            'type': 'album',
            'id': item['id'],
            'title': title,
            'artist': attributes['artistName'],
            'releaseDate': attributes['releaseDate'],
            'coverArtUrl': attributes['artwork']['url']
                .toString()
                .replaceAll('{w}x{h}', '500x500'),
            'url': attributes['url'],
            'trackCount': attributes['trackCount'],
            'tracks': [],
            'ranking': ranking,
            'matchScore': _calculateSimilarity(title, query),
          });
        }
      }

      // Sort results based on type hints, match score, and popularity
      results.sort((a, b) {
        a['source'] = 'apple_music';
        b['source'] = 'apple_music';

        // First compare if both are high priority items
        final aHighPriority = _shouldPrioritizeResult(a, query);
        final bHighPriority = _shouldPrioritizeResult(b, query);

        if (aHighPriority && !bHighPriority) return -1;
        if (!aHighPriority && bHighPriority) return 1;

        // If both are high priority or both are low priority, sort by match score
        if ((a['type'] == 'artist' || a['type'] == 'album') &&
            (b['type'] == 'artist' || b['type'] == 'album')) {
          return (b['matchScore'] as double)
              .compareTo(a['matchScore'] as double);
        }

        return 0;
      });

      print('✅ [Apple Music] Search completed successfully');
      final processedResults = {
        'success': true,
        'results': results,
        'source': 'apple_music'
      };
      return processedResults;
    } catch (e) {
      // Clean up request tracking
      _activeRequests.remove(requestId);

      // Handle timeout separately for better error messages
      if (e is TimeoutException) {
        print('⏱️ [Apple Music] Search timed out');
        throw Exception('Apple Music search timed out. Please try again.');
      }

      print('❌ [Apple Music] Search error: $e');
      throw Exception('Failed to search Apple Music: $e');
    }
  }

  // Search Spotify API
  Future<Map<String, dynamic>> _searchSpotify(String query) async {
    final String requestId =
        'spotify_search_${DateTime.now().millisecondsSinceEpoch}';
    _activeRequests[requestId] = true;

    print('🎵 [Spotify] Searching for: "$query"');

    try {
      final token = await _getSpotifyAccessToken();

      // Check if this request is still relevant
      if (!_activeRequests.containsKey(requestId) ||
          _activeRequests[requestId] == false) {
        print('⚠️ [Spotify] Search was cancelled');
        throw Exception('Request cancelled');
      }

      final url = Uri.parse('https://api.spotify.com/v1/search').replace(
        queryParameters: {
          'q': query,
          'type': 'track,artist,album',
          'limit': '10',
        },
      );

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(requestTimeout);

      // Check again if this request is still relevant
      if (!_activeRequests.containsKey(requestId) ||
          _activeRequests[requestId] == false) {
        print('⚠️ [Spotify] Search was cancelled after API call');
        throw Exception('Request cancelled');
      }
      _activeRequests.remove(requestId);

      if (response.statusCode != 200) {
        print('❌ [Spotify] Search failed: ${response.statusCode}');
        print('Response: ${response.body}');
        throw Exception('Failed to search Spotify: ${response.statusCode}');
      }

      final data = json.decode(response.body);
      final List<Map<String, dynamic>> results = [];

      if (data['tracks']?['items'] != null) {
        final tracks = data['tracks']['items'];
        print('📝 [Spotify] Found ${tracks.length} tracks');
        for (var item in tracks) {
          results.add({
            'type': 'track',
            'id': item['id'],
            'title': item['name'],
            'artist': item['artists'][0]['name'],
            'album': item['album']['name'],
            'coverArtUrl': item['album']['images'].isNotEmpty
                ? item['album']['images'][0]['url']
                : null,
            'previewUrl': item['preview_url'],
            'matchScore': 0.0,
          });
        }
      }

      if (data['artists']?['items'] != null) {
        final artists = data['artists']['items'];
        print('👤 [Spotify] Found ${artists.length} artists');
        for (var item in artists) {
          final name = item['name'];
          results.add({
            'type': 'artist',
            'id': item['id'],
            'title': name,
            'artist': '',
            'coverArtUrl':
                item['images'].isNotEmpty ? item['images'][0]['url'] : null,
            'genres': item['genres'] ?? [],
            'popularity': item['popularity'],
            'matchScore': _calculateSimilarity(name, query),
            'url': 'https://open.spotify.com/artist/${item['id']}',
          });
        }
      }

      if (data['albums']?['items'] != null) {
        final albums = data['albums']['items'];
        print('💿 [Spotify] Found ${albums.length} albums');
        for (var item in albums) {
          final title = item['name'];
          results.add({
            'type': 'album',
            'id': item['id'],
            'title': title,
            'artist': item['artists'][0]['name'],
            'coverArtUrl':
                item['images'].isNotEmpty ? item['images'][0]['url'] : null,
            'tracks': [],
            'total_tracks': item['total_tracks'],
            'matchScore': _calculateSimilarity(title, query),
            'url': 'https://open.spotify.com/album/${item['id']}',
          });
        }
      }

      // Sort results based on type hints, match score, and popularity
      results.sort((a, b) {
        a['source'] = 'spotify';
        b['source'] = 'spotify';

        // First compare if both are high priority items
        final aHighPriority = _shouldPrioritizeResult(a, query);
        final bHighPriority = _shouldPrioritizeResult(b, query);

        if (aHighPriority && !bHighPriority) return -1;
        if (!aHighPriority && bHighPriority) return 1;

        // If both are high priority or both are low priority, sort by match score
        if ((a['type'] == 'artist' || a['type'] == 'album') &&
            (b['type'] == 'artist' || b['type'] == 'album')) {
          return (b['matchScore'] as double)
              .compareTo(a['matchScore'] as double);
        }

        return 0;
      });

      print('✅ [Spotify] Search completed successfully');
      return {'success': true, 'results': results, 'source': 'spotify'};
    } catch (e) {
      // Clean up request tracking
      _activeRequests.remove(requestId);

      // Handle timeout separately
      if (e is TimeoutException) {
        print('⏱️ [Spotify] Search timed out');
        throw Exception('Spotify search timed out. Please try again.');
      }

      print('❌ [Spotify] Search error: $e');
      throw Exception('Failed to search Spotify: $e');
    }
  }

  // Search music using multiple services
  Future<Map<String, dynamic>> searchMusic(String query) async {
    print('🔍 Starting music search for: "$query"');

    // Cancel any previous searches
    cancelActiveRequests();

    try {
      return await _searchAppleMusic(query);
    } catch (e) {
      print('⚠️ Apple Music search failed, trying Spotify');

      // Only try Spotify if the error wasn't a cancellation
      if (e.toString().contains('cancelled')) {
        rethrow; // Propagate cancellation
      }

      try {
        return await _searchSpotify(query);
      } catch (e) {
        print('❌ Both search services failed');
        throw Exception('Failed to search music (both services failed): $e');
      }
    }
  }

  // Fetch Apple Music Top Charts with caching
  Future<Map<String, dynamic>> fetchTop50USAPlaylist() async {
    print('🎵 [Charts] Requesting top charts');

    // Check if we have valid cached data
    if (_cachedChartsData != null && _chartsLastFetched != null) {
      final cacheAge = DateTime.now().difference(_chartsLastFetched!);
      if (cacheAge < _chartsCacheDuration) {
        print('📦 [Charts] Using cached data (${cacheAge.inMinutes}m old)');
        return _cachedChartsData!;
      } else {
        print('⌛ [Charts] Cache expired (${cacheAge.inMinutes}m old)');
      }
    }

    final String requestId = 'charts_${DateTime.now().millisecondsSinceEpoch}';
    _activeRequests[requestId] = true;

    try {
      final token = await _getAppleMusicToken();

      // Check if this request is still relevant
      if (!_activeRequests.containsKey(requestId) ||
          _activeRequests[requestId] == false) {
        print('⚠️ [Charts] Request was cancelled');
        throw Exception('Request cancelled');
      }

      final url = Uri.parse(
        'https://api.music.apple.com/v1/catalog/us/charts',
      ).replace(
        queryParameters: {
          'types': 'songs',
          'limit': '50',
          'chart': 'most-played',
          'with': 'dailyGlobalTopCharts',
        },
      );

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(requestTimeout);

      // Check if request is still active
      if (!_activeRequests.containsKey(requestId) ||
          _activeRequests[requestId] == false) {
        print('⚠️ [Charts] Request was cancelled after API call');
        throw Exception('Request cancelled');
      }
      _activeRequests.remove(requestId);

      if (response.statusCode != 200) {
        print('❌ [Charts] Failed to fetch: ${response.statusCode}');
        print('Response: ${response.body}');
        throw Exception('Failed to fetch charts: ${response.statusCode}');
      }

      final data = json.decode(response.body);
      if (data['results'] == null || !data['results'].containsKey('songs')) {
        throw Exception('Invalid response structure from Apple Music API');
      }

      final charts = data['results']['songs'] as List;
      if (charts.isEmpty) {
        throw Exception('No charts data found in response');
      }

      final tracks = charts[0]['data'] as List;
      print('📝 [Charts] Processing ${tracks.length} tracks');

      final List<Map<String, dynamic>> results = tracks.map((track) {
        final attributes = track['attributes'];
        return {
          'type': 'track',
          'id': track['id'],
          'title': attributes['name'],
          'artist': attributes['artistName'],
          'album': attributes['albumName'],
          'url': attributes['url'],
          'coverArtUrl': attributes['artwork']['url']
              .toString()
              .replaceAll('{w}x{h}', '500x500'),
          'previewUrl': attributes['previews']?.first?['url'],
          'popularity': track['rank'] ?? 0,
        };
      }).toList();

      final transformedData = {
        'success': true,
        'results': results,
        'source': 'apple_music'
      };

      // Cache the data
      _cachedChartsData = transformedData;
      _chartsLastFetched = DateTime.now();
      print('✅ [Charts] Data cached successfully');

      return transformedData;
    } catch (e) {
      // Clean up request tracking
      _activeRequests.remove(requestId);

      // Handle timeout
      if (e is TimeoutException) {
        print('⏱️ [Charts] Request timed out');

        // Return cached data on timeout if available
        if (_cachedChartsData != null) {
          print('📦 [Charts] Timeout occurred, using cached data');
          return _cachedChartsData!;
        }

        throw Exception('Charts request timed out. Please try again.');
      }

      print('❌ [Charts] Error: $e');

      // If we have cached data and encounter an error, return the cached data
      if (_cachedChartsData != null) {
        print('⚠️ [Charts] Error occurred, falling back to cached data');
        return _cachedChartsData!;
      }

      throw Exception('Failed to fetch charts: $e');
    }
  }
}
