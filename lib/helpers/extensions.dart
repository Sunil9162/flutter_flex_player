import 'package:flutter/material.dart';

extension ContextExtensio on BuildContext {
  double get width => MediaQuery.of(this).size.width;
  double get height => MediaQuery.of(this).size.height;
}

extension SizedBoxExtensio on double {
  Widget get heightBox => SizedBox(height: this);
  Widget get widthBox => SizedBox(width: this);
}
