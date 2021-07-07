import 'package:flutter/material.dart';

@immutable
class OverlayServices {
  static OverlayEntry? _overlayEntry;

  static void insertOverlay(
      BuildContext context, Function(BuildContext) builder) {
    _overlayEntry = OverlayEntry(builder: builder as Widget Function(BuildContext));
    Overlay.of(context)!.insert(_overlayEntry!);
  }

  static void dismissOverlay() {
    if (_overlayEntry != null) _overlayEntry!.remove();
  }
}
