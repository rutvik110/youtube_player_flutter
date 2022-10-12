// Copyright 2020 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/src/utils/youtube_player_controller.dart';

/// A widget to display darkened translucent overlay, when video area is touched.
///
/// Also provides ability to seek video by dragging horizontally.
class TouchShutter extends StatefulWidget {
  /// Overrides the default [YoutubePlayerController].
  final YoutubePlayerController controller;

  /// If true, disables the drag to seek functionality.
  ///
  /// Default is false.
  final bool disableDragSeek;

  /// Sets the timeout until when the controls hide.
  final Duration timeOut;

  /// Creates [TouchShutter] widget.
  TouchShutter({
    required this.controller,
    this.disableDragSeek = false,
    required this.timeOut,
  });

  @override
  _TouchShutterState createState() => _TouchShutterState();
}

class _TouchShutterState extends State<TouchShutter> {
  double dragStartPos = 0.0;
  double delta = 0.0;
  double scaleAmount = 0.0;
  int seekToPosition = 0;
  String seekDuration = "";
  String seekPosition = "";
  final bool _dragging = false;
  Timer? _timer;

  bool isControllsVisible = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // final controller = YoutubePlayerController.of(context);
    // if (controller == null) {
    //   widget.controller = widget.controller;
    // } else {
    //   widget.controller = controller;
    // }
  }

  @override
  void dispose() {
    _timer?.cancel();
    // widget.controller.dispose();
    super.dispose();
  }

  void _toggleControls() {
    setState(() {
      isControllsVisible = !isControllsVisible;
    });
    widget.controller.updateValue(
      widget.controller.value.copyWith(
        isControlsVisible: isControllsVisible,
      ),
    );
    _timer?.cancel();
    _timer = Timer(widget.timeOut, () {
      if (!widget.controller.value.isDragging) {
        widget.controller.updateValue(
          widget.controller.value.copyWith(
            isControlsVisible: false,
          ),
        );
        if (mounted) {
          setState(() {
            isControllsVisible = false;
          });
          widget.controller.updateValue(
            widget.controller.value.copyWith(
              isControlsVisible: false,
            ),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return
        //  widget.disableDragSeek
        //     ? GestureDetector(onTap: _toggleControls)
        //     :
        GestureDetector(
      onTap: _toggleControls,
      // onHorizontalDragStart: (details) {
      //   // setState(() {
      //   //   _dragging = true;
      //   // });
      //   // dragStartPos = details.globalPosition.dx;
      // },
      // onHorizontalDragUpdate: (details) {
      //   widget.controller.updateValue(
      //     widget.controller.value.copyWith(
      //       isControlsVisible: false,
      //     ),
      //   );
      //   delta = details.globalPosition.dx - dragStartPos;
      //   seekToPosition =
      //       (widget.controller.value.position.inMilliseconds + delta * 1000)
      //           .round();
      //   setState(() {
      //     seekDuration = (delta < 0 ? "- " : "+ ") +
      //         durationFormatter((delta < 0 ? -1 : 1) * (delta * 1000).round());
      //     if (seekToPosition < 0) seekToPosition = 0;
      //     seekPosition = durationFormatter(seekToPosition);
      //   });
      // },
      // onHorizontalDragEnd: (_) {
      //   widget.controller.seekTo(Duration(milliseconds: seekToPosition));
      //   setState(() {
      //     _dragging = false;
      //   });
      // },
      // onScaleUpdate: (details) {
      //   scaleAmount = details.scale;
      // },
      // onScaleEnd: (_) {
      //   if (widget.controller.value.isFullScreen) {
      //     if (scaleAmount > 1) {
      //       widget.controller.fitWidth(MediaQuery.of(context).size);
      //     }
      //     if (scaleAmount < 1) {
      //       widget.controller.fitHeight(MediaQuery.of(context).size);
      //     }
      //   }
      // },
      child: ColoredBox(
        color: widget.controller.value.isControlsVisible
            ? Colors.black.withAlpha(150)
            : Colors.transparent,
        child: _dragging
            ? Center(
                child: Container(
                  padding: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                    color: Colors.black.withAlpha(150),
                  ),
                  child: Text(
                    "$seekDuration ($seekPosition)",
                    style: const TextStyle(
                      fontSize: 26.0,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
