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
  // late AnimationController _animController;
  bool isPlaying = true;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    if (_controller.value.playerState == PlayerState.paused) {
      isPlaying = false;
    }
    // _controller.addListener(_playPauseListener);

    // _animController = AnimationController(
    //   vsync: this,
    //   value: 0,
    //   duration: const Duration(milliseconds: 300),
    // );
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
    // _controller.removeListener(_playPauseListener);
    // _controller.dispose();
    // _animController.dispose();
    super.dispose();
  }

  // void _playPauseListener() => _controller.value.isPlaying
  //     ? _animController.forward()
  //     : _animController.reverse();

  @override
  Widget build(BuildContext context) {
    log('message');
    final _playerState = _controller.value.playerState;
    if (_playerState == PlayerState.buffering) {
      return widget.bufferIndicator ?? const SizedBox.shrink();
    }
    if ((!_controller.flags.autoPlay && _controller.value.isReady) ||
        _playerState == PlayerState.playing ||
        _playerState == PlayerState.paused) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Material(
            shape: const CircleBorder(),
            color: Colors.transparent,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () {
                final currentPosition =
                    widget.controller.durationNotifier.value.position;
                final backToDuration =
                    Duration(seconds: currentPosition.inSeconds - 10);
                widget.controller.seekTo(backToDuration);
                // if (!isPlaying) {
                //   widget.controller.pause();
                // }
              },
              child: const Padding(
                padding: EdgeInsets.all(5.0),
                child: Icon(
                  Icons.replay_10_outlined,
                  size: 36,
                ),
              ),
            ),
          ),
          Material(
            shape: const CircleBorder(),
            color: Colors.transparent,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () {
                isPlaying ? _controller.pause() : _controller.play();
                if (mounted) {
                  setState(() {
                    isPlaying = !isPlaying;
                  });
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: isPlaying
                    ? const Icon(
                        Icons.pause,
                        size: 36,
                      )
                    : const Icon(
                        Icons.play_arrow,
                        size: 36,
                      ),
              ),
              //  AnimatedIcon(
              //   icon: AnimatedIcons.play_pause,
              //   progress: _animController.view,
              //   color: Colors.white,
              //   size: 60.0,
              // ),
            ),
          ),
          Material(
            shape: const CircleBorder(),
            color: Colors.transparent,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () {
                final currentPosition =
                    widget.controller.durationNotifier.value.position;
                final forwardToDuration =
                    Duration(seconds: currentPosition.inSeconds + 10);
                widget.controller.seekTo(forwardToDuration);
                // if (!isPlaying) {
                //   widget.controller.pause();
                // }
              },
              child: const Padding(
                padding: EdgeInsets.all(5),
                child: Icon(
                  Icons.forward_10,
                  size: 36,
                ),
              ),
            ),
          ),
        ],
      );
    }
    if (_controller.value.hasError) return const SizedBox.shrink();
    return widget.bufferIndicator ?? const SizedBox.shrink();
    // Container(
    //   width: 70.0,
    //   height: 70.0,
    //   child: const CircularProgressIndicator(
    //     valueColor: AlwaysStoppedAnimation(Colors.white),
    //   ),
    // );
  }
}
