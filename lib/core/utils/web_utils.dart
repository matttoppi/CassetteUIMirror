import 'dart:html' as html;
import 'package:flutter/foundation.dart';

class WebUtils {
  // Sets the document title for web platform
  static void setDocumentTitle(String title) {
    if (kIsWeb) {
      html.document.title = title;
    }
  }
}
