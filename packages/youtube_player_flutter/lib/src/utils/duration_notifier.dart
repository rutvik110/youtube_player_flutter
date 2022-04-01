// ignore_for_file: public_member_api_docs, avoid_setters_without_getters

import 'package:flutter/material.dart';

class DurationNotifier extends ValueNotifier<VideoDurations> {
  DurationNotifier()
      : super(
          VideoDurations(
            position: Duration.zero,
            bufferPosition: 0,
          ),
        );

  void updateDuration(VideoDurations newValue) {
    value = newValue;
  }
}

class VideoDurations {
  VideoDurations({
    required this.position,
    required this.bufferPosition,
  });
  final Duration position;
  final double bufferPosition;
}
