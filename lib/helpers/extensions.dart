import 'dart:core';

import 'package:flutter/material.dart';

extension ContextExtensions on BuildContext {
  double get width => MediaQuery.of(this).size.width;
  double get height => MediaQuery.of(this).size.height;
}

extension SizedBoxExtensio on num {
  Widget get heightBox => SizedBox(height: toDouble());
  Widget get widthBox => SizedBox(width: toDouble());
}

extension UrlConverter on String {
  // Function to convert a relative URL to a full URL
  String toFullUrl(String originalM3u8Url) {
    // Extract base URL from the original full URL
    if (contains("https://")) {
      return this;
    }
    Uri uri = Uri.parse(originalM3u8Url);
    String baseUrl =
        '${uri.scheme}://${uri.authority}/${uri.pathSegments.take(uri.pathSegments.length - 1).join('/')}';

    // Check if the URL already contains the protocol (is a full URL)
    if (!startsWith('http://') && !startsWith('https://')) {
      // Append the relative URL to the base URL
      if (!startsWith('/')) {
        return '$baseUrl/$this';
      } else {
        return baseUrl + this;
      }
    }
    // If already a full URL, return it as is
    return this;
  }
}
