// Copyright 2020 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:developer';

import 'package:flutter/material.dart';

import '../enums/player_state.dart';
import '../utils/youtube_player_controller.dart';

/// A widget to display play/pause button.
class PlayPauseButton extends StatefulWidget {
  /// Overrides the default [YoutubePlayerController].
  final YoutubePlayerController controller;

  /// Defines placeholder widget to show when player is in buffering state.
  final Widget? bufferIndicator;

  /// Creates [PlayPauseButton] widget.
  PlayPauseButton({
    required this.controller,
    this.bufferIndicator,
  });

  @override
  _PlayPauseButtonState createState() => _PlayPauseButtonState();
}

class _PlayPauseButtonState extends State<PlayPauseButton>
    with TickerProviderStateMixin {
  late YoutubePlayerController _controller;
  late AnimationController _animController;
  bool isPlaying = true;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    _controller.addListener(_playPauseListener);

    _animController = AnimationController(
      vsync: this,
      value: 0,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // final controller = YoutubePlayerController.of(context);
    // if (controller == null) {
    //   _controller = widget.controller;
    // } else {
    //   _controller = controller;
    // }
    // _controller.removeListener(_playPauseListener);
    // _controller.addListener(_playPauseListener);
  }

  @override
  void dispose() {
    _controller.removeListener(_playPauseListener);
    // _controller.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _playPauseListener() => _controller.value.isPlaying
      ? _animController.forward()
      : _animController.reverse();

  @override
  Widget build(BuildContext context) {
    log('message');
    final _playerState = _controller.value.playerState;
    if ((!_controller.flags.autoPlay && _controller.value.isReady) ||
        _playerState == PlayerState.playing ||
        _playerState == PlayerState.paused) {
      return InkWell(
        borderRadius: BorderRadius.circular(50.0),
        onTap: () {
          isPlaying ? _controller.pause() : _controller.play();
          setState(() {
            isPlaying = !isPlaying;
          });
        },
        child: isPlaying
            ? const Icon(
                Icons.pause,
                size: 60.0,
              )
            : const Icon(
                Icons.play_arrow,
                size: 60.0,
              ),
        //  AnimatedIcon(
        //   icon: AnimatedIcons.play_pause,
        //   progress: _animController.view,
        //   color: Colors.white,
        //   size: 60.0,
        // ),
      );
    }
    if (_controller.value.hasError) return const SizedBox();
    return widget.bufferIndicator ?? const SizedBox();
    // Container(
    //   width: 70.0,
    //   height: 70.0,
    //   child: const CircularProgressIndicator(
    //     valueColor: AlwaysStoppedAnimation(Colors.white),
    //   ),
    // );
  }
}
