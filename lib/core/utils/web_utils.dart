import 'dart:html' as html;
import 'package:flutter/foundation.dart';

class WebUtils {
  // Track current title to avoid unnecessary updates
  static String _currentTitle = 'Cassette';

  // Gets the current document title
  static String get currentTitle => _currentTitle;

  // Sets the document title for web platform
  static void setDocumentTitle(String title) {
    // If the title is the same as current, no need to update
    if (title == _currentTitle) return;

    try {
      if (kIsWeb) {
        // Keep track of the title we're setting
        _currentTitle = title;

        // Update the document title
        html.document.title = title;

        // Log title change in debug mode
        if (kDebugMode) {
          print('📝 Page title set to: $title');
        }
      }
    } catch (e) {
      // Handle errors gracefully
      if (kDebugMode) {
        print('Error setting document title: $e');
      }
    }
  }
}
