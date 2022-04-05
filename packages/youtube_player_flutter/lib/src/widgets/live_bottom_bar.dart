// Copyright 2020 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import '../utils/youtube_player_controller.dart';
import 'duration_widgets.dart';
import 'full_screen_button.dart';

/// A widget to display bottom controls bar on Live Video Mode.
class LiveBottomBar extends StatefulWidget {
  /// Overrides the default [YoutubePlayerController].
  final YoutubePlayerController controller;

  /// Defines color for UI.
  final Color liveUIColor;

  /// Defines whether to show or hide the fullscreen button
  final bool showLiveFullscreenButton;

  /// Creates [LiveBottomBar] widget.
  LiveBottomBar({
    required this.controller,
    required this.liveUIColor,
    required this.showLiveFullscreenButton,
  });

  @override
  _LiveBottomBarState createState() => _LiveBottomBarState();
}

class _LiveBottomBarState extends State<LiveBottomBar> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = widget.controller;
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: _controller.value.isControlsVisible,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SizedBox(
            width: 14.0,
          ),
          CurrentPosition(
            _controller,
          ),
          Expanded(
            child: Padding(
              child: ValueListenableBuilder(
                  valueListenable: _controller.durationNotifier,
                  builder: (context, position, child) {
                    final currentSliderPosition =
                        _controller.metadata.duration.inMilliseconds == 0
                            ? 0
                            : _controller.durationNotifier.value.position
                                    .inMilliseconds /
                                _controller.metadata.duration.inMilliseconds;
                    return Slider(
                      value: currentSliderPosition.clamp(0, 1).toDouble(),
                      onChanged: (value) {
                        _controller.seekTo(
                          Duration(
                            milliseconds: (_controller.durationNotifier.value
                                        .position.inMilliseconds *
                                    value)
                                .toInt(),
                          ),
                        );
                      },
                      activeColor: widget.liveUIColor,
                      inactiveColor: Theme.of(context).colorScheme.secondary,
                    );
                  }),
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
              ),
            ),
          ),
          InkWell(
            onTap: () => _controller.seekTo(_controller.metadata.duration),
            child: Material(
              color: widget.liveUIColor,
              child: const Text(
                ' LIVE ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.0,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
          ),
          widget.showLiveFullscreenButton
              ? FullScreenButton(controller: _controller)
              : const SizedBox(width: 14.0),
        ],
      ),
    );
  }
}
