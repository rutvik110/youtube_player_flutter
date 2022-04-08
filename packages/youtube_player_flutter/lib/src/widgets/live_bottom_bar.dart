// Copyright 2020 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/src/utils/duration_notifier.dart';

import '../utils/youtube_player_controller.dart';
import 'duration_widgets.dart';
import 'full_screen_button.dart';

class LiveBottomBar extends StatelessWidget {
  /// Overrides the default [YoutubePlayerController].
  final YoutubePlayerController controller;

  /// Defines color for UI.
  final Color liveUIColor;

  /// Defines whether to show or hide the fullscreen button
  final bool showLiveFullscreenButton;

  /// Creates [LiveBottomBar]
  const LiveBottomBar({
    required this.controller,
    required this.liveUIColor,
    required this.showLiveFullscreenButton,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const SizedBox(
          width: 14.0,
        ),
        CurrentPosition(
          controller,
        ),
        Expanded(
          child: Padding(
            child: ValueListenableBuilder<VideoDurations>(
                valueListenable: controller.durationNotifier,
                builder: (context, position, child) {
                  final currentSliderPosition =
                      controller.metadata.duration.inMilliseconds == 0
                          ? 0
                          : position.position.inMilliseconds /
                              controller.metadata.duration.inMilliseconds;
                  return Slider(
                    value: currentSliderPosition >= 1.0
                        ? 1.0
                        : currentSliderPosition.toDouble(),
                    onChanged: (value) {
                      controller.seekTo(
                        Duration(
                          milliseconds:
                              (controller.metadata.duration.inMilliseconds *
                                      value)
                                  .toInt(),
                        ),
                      );
                    },
                    activeColor: liveUIColor,
                    inactiveColor: Theme.of(context).colorScheme.secondary,
                  );
                }),
            padding: const EdgeInsets.symmetric(
              horizontal: 8.0,
            ),
          ),
        ),
        // InkWell(
        //   onTap: () =>
        //     controller.seekTo(controller.metadata.duration),
        //   child: Material(
        //     color: liveUIColor,
        //     child: const Text(
        //       ' LIVE ',
        //       style: TextStyle(
        //         color: Colors.white,
        //         fontSize: 12.0,
        //         fontWeight: FontWeight.w300,
        //       ),
        //     ),
        //   ),
        // ),
        showLiveFullscreenButton
            ? FullScreenButton(controller: controller)
            : const SizedBox(width: 14.0),
      ],
    );
  }
}
