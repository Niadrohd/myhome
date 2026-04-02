import 'package:flutter/material.dart';

Widget wrapSemantics({
  String? label,
  required Widget child,
  bool isTextField = false,
  bool isButton = false,
  bool isText = false,
  bool isTile = false,
}) {
  if (label == null) {
    return child;
  }

  if (isTextField) {
    return Semantics(
      identifier: label,
      container: true,
      child: child,
    );
  }

  if (isButton) {
    return Semantics(
      label: label,
      container: true,
      child: child,
    );
  }

  if (isTile) {
    return Semantics(
      explicitChildNodes: true,
      label: label,
      container: true,
      child: child,
    );
  }

  return Semantics(
    label: label,
    container: true,
    excludeSemantics: true,
    child: child,
  );
}
