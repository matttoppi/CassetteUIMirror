import 'package:supabase_flutter/supabase_flutter.dart';

class ReportService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Create a service role client for operations that need to bypass RLS
  // Note: You'll need to add your service role key to your app's configuration
  // This is typically stored in a secure environment variable or config file
  SupabaseClient get _adminClient {
    // For development purposes only - in production, use secure methods to store keys
    const serviceRoleKey =
        String.fromEnvironment('SUPABASE_SERVICE_ROLE_KEY', defaultValue: '');
    const supabaseUrl =
        String.fromEnvironment('SUPABASE_URL', defaultValue: '');

    if (serviceRoleKey.isNotEmpty && supabaseUrl.isNotEmpty) {
      return SupabaseClient(
        supabaseUrl,
        serviceRoleKey,
      );
    }
    // Fallback to regular client if service role key is not available
    return _supabase;
  }

  /// Submit a report for a post
  Future<void> submitReport({
    required String postId,
    required String issueType,
    required String elementType,
    required String elementId,
    String? description,
    String? originalLink,
    Map<String, dynamic>? apiResponse,
  }) async {
    try {
      print('Submitting report with data:');
      print('Post ID: $postId');
      print('Issue Type: $issueType');
      print('Element Type: $elementType');
      print('Element ID: $elementId');
      print('Description: $description');
      print('Original Link: $originalLink');
      print('API Response: $apiResponse');

      // Get current user ID if authenticated
      final userId = _supabase.auth.currentUser?.id;

      final reportData = {
        'post_id': postId,
        'issue_type': issueType.toLowerCase().replaceAll(' ', '_'),
        'description': description,
        'element_type': elementType.toLowerCase(),
        'element_id': elementId,
        'status': 'pending',
        // Only include user_id if authenticated
        if (userId != null) 'user_id': userId,
        // Add original link and API response if provided
        if (originalLink != null) 'original_link': originalLink,
        if (apiResponse != null) 'api_response': apiResponse,
      };

      print('Formatted report data: $reportData');

      // Try a simpler approach - direct insert without select
      try {
        await _supabase.from('post_reports').insert(reportData);

        print('Report submitted successfully');
      } catch (e) {
        print('Error with insert: $e');
        rethrow;
      }
    } catch (e, stackTrace) {
      print('Error submitting report: $e');
      print('Stack trace: $stackTrace');
      if (e is PostgrestException) {
        print('Postgrest error code: ${e.code}');
        print('Postgrest error message: ${e.message}');
        print('Postgrest error details: ${e.details}');
      }
      rethrow;
    }
  }

  /// Get reports for a specific post
  Future<List<Map<String, dynamic>>> getReportsForPost(String postId) async {
    try {
      final response = await _supabase
          .from('post_reports')
          .select()
          .eq('post_id', postId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching reports: $e');
      rethrow;
    }
  }

  /// Get all reports for the current user
  Future<List<Map<String, dynamic>>> getUserReports() async {
    try {
      final response = await _supabase
          .from('post_reports')
          .select()
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching user reports: $e');
      rethrow;
    }
  }
}
