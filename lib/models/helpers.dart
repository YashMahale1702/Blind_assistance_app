import 'package:flutter/material.dart';
import 'package:highlight_text/highlight_text.dart';

class Helpers {
  static final Map<String, HighlightedWord> highlights = {
    'Flutter': HighlightedWord(
      onTap: () {},
      textStyle: const TextStyle(
        color: Colors.blue,
        fontWeight: FontWeight.bold,
      ),
    ),
    'Navigate to': HighlightedWord(
      onTap: () {},
      textStyle: const TextStyle(
        color: Colors.blue,
        fontWeight: FontWeight.bold,
      ),
    ),
  };

  static String removeAllHtmlTags(String htmlText) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    return htmlText.replaceAll(exp, '');
  }
}
