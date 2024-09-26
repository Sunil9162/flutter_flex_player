import 'dart:core';

import 'package:flutter/material.dart';

extension ContextExtensions on BuildContext {
  double get width => MediaQuery.of(this).size.width;
  double get height => MediaQuery.of(this).size.height;
  Orientation get orientation => MediaQuery.of(this).orientation;
}

extension SizedBoxExtensio on num {
  Widget get heightBox => SizedBox(height: toDouble());
  Widget get widthBox => SizedBox(width: toDouble());
}
